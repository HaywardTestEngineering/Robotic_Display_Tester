unit dbunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, ADODB, Menus, ComCtrls, StdCtrls, Mask,
  DBCtrls, ExtCtrls;

type
  Tdbinterface = class(TForm)
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    File1: TMenuItem;
    exit1: TMenuItem;
    ADOConnection1: TADOConnection;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    ADOQuery1: TADOQuery;
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    DBGrid3: TDBGrid;
    Label4: TLabel;
    DataSource3: TDataSource;
    ADODataSet2: TADODataSet;
    ADOQuery2: TADOQuery;
    Memo1: TMemo;
    DBText1: TDBText;
    Edit3: TEdit;
    Label5: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    ADODataSet1: TADODataSet;
    ComboBox1: TComboBox;
    Label7: TLabel;
    Button2: TButton;
    Edit2: TEdit;
    Upload1: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure exit1Click(Sender: TObject);
    procedure ADOConnection1ConnectComplete(Connection: TADOConnection;
      const Error: Error; var EventStatus: TEventStatus);
    procedure Button2Click(Sender: TObject);
    procedure Upload1Click(Sender: TObject);
  private
    { Private declarations }
    procedure Post_Connection_Stuff;

    function Insert_Test_Result(sn,process_step,fixture_id,loop,part_id,
                                symptom_id:string):boolean;
    function Insert_New_Keyword(txt,type_txt:string):boolean;
    function parse(i:integer;tstr:string;pchr:char):string;

  public
    { Public declarations }
    procedure Logout;

    function Keyword_Found(temp_txt:string):boolean;
    function SN_Found(sn_txt:string):boolean;
    function Get_Keyword_ID(keyword_txt:string):string;
    function Get_Next_Available_Keyword_ID(type_txt:string):string;
    function Get_Last_Loop_Number(sn,ps:string):string;
    function Get_Symptom_ID(sn,ps,loop:string):string;
    function Get_Symptom_Text(id:string):string;
    function Get_Part_ID(mn:string):string;
    function Get_Part_ID_Text(Part_ID:string):string;
    function Save_Test_Result(sn,mn,process_step,fixture_id,symptom:string):boolean;
    function Username_Found(txt:string):boolean;
    function Successful_Login(username,password:string):boolean;
    function Set_Current_User(txt:string):boolean;
    function Get_Current_User:string;
    function Get_Username_List:Tstringlist;
    function DB_Connected:boolean;
    function Get_Process_Step_List:TStrings;
    function Previous_Step_Passed(sn,ps:string):boolean;
    function Get_Number_of_Records(sn,ps:string):integer;
    function Get_Data_for(c,r:integer):string;
    function Get_First_From_Table(c:integer):string;
    function Get_Next_From_Table(c:integer):string;
  end;

var
  dbinterface: Tdbinterface;
  current_user : string;
  username_List : Tstringlist;

implementation

uses Unit4;

{$R *.dfm}
//------------------------------------------------------------------------------
//-- Returns the ith item from a string.
//-- Returns '' if item not found.
//------------------------------------------------------------------------------
function Tdbinterface.parse(i:integer;tstr:string;pchr:char):string;
Var
   x,n : integer;
   astr : string;
begin
     n := 1;        //-- nth item of tstr found so far.
     result := '';
     astr   := '';

     //-- remove any leading white space.
     tstr := trimleft(tstr);

     for x := 1 to length(tstr) do
       begin
         if tstr[x] <> pchr then astr := astr + tstr[x]
         else
           begin
             if i=n then
               begin
                 result := astr;
                 exit;
               end
             else
               begin
                 inc(n);
                 astr := '';
               end;
           end;
       end;

     //-- Return the last item if it is the item requested.
     if i=n then result := astr
     else result := '';
end;

//------------------------------------------------------------------------------
//-- INPUTS  : sn            serial#  (such as '015008H-10 1234 56789')
//--           mn            model#   (such as '015008H-12',AQ-LOGIC-P-4',...)
//--           process_step           (such as '300', '1000',...)
//--           fixture_id             (such as '1','2','3',...)
//--           symptom                (such as 'PASS','FUNC TEST 1',...)
//--
//-- eg.  Save_Test_Result('015008H-10 9999 99999','300','1','FUNC TEST 1');
//------------------------------------------------------------------------------
function Tdbinterface.Save_Test_Result(sn,mn,process_step,fixture_id,symptom:string):boolean;

Var
   loop_txt,part_id,symptom_id : string;
begin
     //-- Skip this if we are not using a server for db stuff
     if not(Configuration.Qdb_enabled) then
       begin
         result := true;
         exit;
       end;

     result := false;

     //------------------------------------------------------
     //-- Get the next loop number for this serial number.
     //------------------------------------------------------
     loop_txt := Get_Last_Loop_Number(sn,process_step);

     if loop_txt = '' then
       loop_txt := '1'
     else
       begin
         loop_txt := IntToStr(StrToInt(loop_txt)+1);
       end;

     //------------------------------------------------------
     //-- Get the 'part_id number from the model# 'mn'.
     //------------------------------------------------------
     part_id := Get_Part_ID(mn);

     //------------------------------------------------------
     //-- Get the symptom_id code number from its description
     //-- If symptom_id = '' then we need to add this new
     //-- symptom to the keywords table.
     //------------------------------------------------------
     if not(Keyword_Found(symptom)) then
       begin
         if not(Insert_New_Keyword(symptom,'symptom')) then
           begin
             showmessage('Unable to create keyword : '+symptom+'  Call Engineer');
             showmessage('Test result data not saved.');
             exit;
           end;
       end;

     symptom_id := Get_Keyword_ID(symptom);

     //------------------------------------------------------
     //-- Save the data to the Test table.
     //------------------------------------------------------
     //--memo1.lines.add(sn+','+process_step+','+fixture_id+','+loop_txt+','+part_id+','+symptom_id);

     result := Insert_Test_Result(sn,process_step,fixture_id,loop_txt,part_id,symptom_id);
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.Insert_Test_Result(sn,process_step,fixture_id,loop,part_id,
                                         symptom_id:string):boolean;
Var
   txt1,txt2 : string;
begin
     //-- Skip this if we are not using a server for db stuff
     if not(Configuration.QDB_enabled) then
       begin
         result := true;
         exit;
       end;

     txt1 := 'INSERT INTO Test(sn,process_step,fixture_id,loop,part,symptom,author)';
     txt2 := 'VALUES('''+sn+''','''+process_step+''','''+fixture_id+''','''+
                         loop+''','''+part_id+''','''+symptom_id+''','''+
                         current_user+''')';
memo1.lines.add(txt1);
memo1.lines.add(txt2);

     ADOQuery1.Close;
     ADOQuery1.SQL.Clear;
     ADOQuery1.SQL.Add(txt1);
     ADOQuery1.SQL.Add(txt2);
     ADOQuery1.ExecSQL;

     result := true;
end;

//------------------------------------------------------------------------------
//-- Returns the part text from the PART_ID#.
//-- eg.
//-- if Part_ID = '886', the returned result would be '015008H-10'.
//--
//-- TABLE  : part
//-- INPUTS : part 'id' number   (such as '886')
//-- OUTPUT : 'part' text        (such as '015008H-10')
//------------------------------------------------------------------------------
function Tdbinterface.Get_Part_ID_Text(Part_ID:string):string;
Var
   txt : string;
begin
     result := '';

     if Part_ID <> '' then
       begin
         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         txt := 'select part from part where id = ';
         txt := txt + '''' + Part_ID + '''';

memo1.lines.add(txt);

         ADOQuery1.SQL.Add(txt);
         ADOQuery1.Open;

         if DBGrid2.Fields[0].AsString = '' then
           memo1.lines.add(Part_ID + ' not found.')
         else
           begin
             memo1.lines.add(DBGrid2.Fields[0].AsString+' found.');

             result := DBGrid2.Fields[0].AsString;
           end;

       end;
end;

//------------------------------------------------------------------------------
//-- Uses the Part table to get the 'id' number of the product being tested.
//--
//-- mn is the model # of the DUT being tested.
//--
//-- TABLE  : Test
//-- INPUTS : model number 'mn'    (such as '015008H-10')
//-- OUTPUT : 'part_id' text       (such as '886')
//--
//--          returns '' if nothing found.
//------------------------------------------------------------------------------
function Tdbinterface.Get_Part_ID(mn:string):string;
Var
   txt : string;
begin
     result := '';

     if mn <> '' then
       begin
         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         txt := 'select id from Part where part = ';
         txt := txt + '''' + mn + '''';
memo1.lines.add(txt);

         ADOQuery1.SQL.Add(txt);
         ADOQuery1.Open;

         if DBGrid2.Fields[0].AsString = '' then
           memo1.lines.add(mn + ' not found.')
         else
           begin
             memo1.lines.add(DBGrid2.Fields[0].AsString+' found.');

             result := DBGrid2.Fields[0].AsString;
           end;

       end;
end;

//------------------------------------------------------------------------------
//-- Returns the 'symptom' text parameter from the keywords table.
//--
//-- TABLE  : Keywords
//-- INPUTS : keyword 'id' number (such as '0','3','40'...)
//--          type                (forced to 'symptom')
//-- OUTPUT : symptom text        (such as 'FUNC TEST 1')
//--
//--          returns '' if nothing found.
//------------------------------------------------------------------------------
function Tdbinterface.Get_Symptom_Text(id:string):string;
Var
   txt : string;
begin
     result := '';

     if id <> '' then
       begin
         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         txt := 'select keyword from Keywords where id = ';
         txt := txt + '''' + id + '''';
         txt := txt + ' and type = ' +'''symptom''';
memo1.lines.add(txt);

         ADOQuery1.SQL.Add(txt);
         ADOQuery1.Open;

         if DBGrid2.Fields[0].AsString = '' then
           memo1.lines.add(id + ' not found.')
         else
           begin
             memo1.lines.add(DBGrid2.Fields[0].AsString+' found.');

             result := DBGrid2.Fields[0].AsString;
           end;

       end;
end;

//------------------------------------------------------------------------------
//-- Uses the 'Test' table to return the 'symptom' for a test result.
//--
//-- TABLE  : Test
//-- INPUTS : serial number 'sn'  (such as '015008H-10 1234 56789')
//--          'loop' number       (such as '1')
//--          process step# 'ps'  (such as 100, 300, 1000, 1305,...)
//-- OUTPUT : symptom text        (such as 'FUNC TEST 1')
//--
//--          returns '' if nothing found.
//------------------------------------------------------------------------------
function Tdbinterface.Get_Symptom_ID(sn,ps,loop:string):string;
Var
   txt : string;
begin
     result := '';

     if sn <> '' then
       begin
         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         txt := 'select symptom from Test where sn = ';
         txt := txt + '''' + sn + '''';
         txt := txt + ' and loop = ';
         txt := txt + '''' + loop + '''';
         txt := txt + ' and process_step = ';
         txt := txt + '''' + ps + '''';
memo1.lines.add(txt);

         ADOQuery1.SQL.Add(txt);
         ADOQuery1.Open;

         if DBGrid2.Fields[0].AsString = '' then
           memo1.lines.add(sn + ' not found.')
         else
           begin
             memo1.lines.add(DBGrid2.Fields[0].AsString+' found.');

             result := DBGrid2.Fields[0].AsString;
           end;

       end;
end;


//------------------------------------------------------------------------------
//-- Uses the 'Test' table to return the last loop# for a specific serial#.
//--
//-- TABLE  : Test
//-- INPUTS : serial number 'sn'  (such as '015008H-10 1234 56789')
//--          process step# 'ps'  (such as 100, 300, 1000, 1305,...)
//--
//-- OUTPUT : loop#               (such as '1','2','3',...)
//--
//--          returns '' if nothing found.
//------------------------------------------------------------------------------
function Tdbinterface.Get_Last_Loop_Number(sn,ps:string):string;
Var
   txt : string;
begin
     result := '';

     //-- Skip this if we are not using a server for db stuff
     if not(Configuration.Qdb_enabled) then  exit;

     if sn <> '' then
       begin
         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         txt := 'select max(loop) from Test where sn = ';
         txt := txt + '''' + sn + '''';
         txt := txt + ' and process_step = ';
         txt := txt + '''' + ps + '''';
memo1.lines.add(txt);

         ADOQuery1.SQL.Add(txt);
         ADOQuery1.Open;

         if DBGrid2.Fields[0].AsString = '' then
           memo1.lines.add(sn + ' not found.')
         else
           begin
             memo1.lines.add(DBGrid2.Fields[0].AsString+' found.');

             result := DBGrid2.Fields[0].AsString;
           end;

       end;
end;


//------------------------------------------------------------------------------
//-- Inserts a new keyword into the 'keywords' table.
//------------------------------------------------------------------------------
function Tdbinterface.Insert_New_Keyword(txt,type_txt:string):boolean;
Var
   txt1,txt2,ID_txt : string;
begin
     result := true;

     ID_txt := Get_Next_Available_Keyword_ID('symptom');

     if ID_txt <> '' then
       begin
         txt1 := 'INSERT INTO Keywords(type,id,keyword)';
         txt2 := 'VALUES(''' + type_txt + ''',''' + ID_txt + ''',''' + txt + ''')';
memo1.lines.add(txt);

         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         ADOQuery1.SQL.Add(txt1);
         ADOQuery1.SQL.Add(txt2);
         ADOQuery1.ExecSQL;
       end
     else
       begin
         //-- ERROR retrieving ID# for new keyword.
         memo1.lines.add('ERROR getting new ID# for '+txt);
         result := false;
       end;
end;

//------------------------------------------------------------------------------
//-- Returns the next available keyword id# for a particular type of keyword.
//--
//-- TABLE  : keywords
//-- INPUTS : type_txt  (such as 'symptom','diagnosis','part','process step',...)
//--
//-- OUTPUT : id#       (such as '1307','1308','1309',...)
//--
//--          returns '' if failure occurs.
//------------------------------------------------------------------------------
function Tdbinterface.Get_Next_Available_Keyword_ID(type_txt:string):string;
Var
   temp : integer;
   txt : string;
begin
     result := '';
     txt := 'select max(id) from keywords where type = ' + '''' +type_txt+ '''' ;
memo1.lines.add(txt);

     //-- Disassociate the datasource from the DBText object.
     DBText1.DataSource := nil;

     ADOQuery2.Close;
     ADOQuery2.SQL.Clear;
     ADOQuery2.SQL.Add(txt);

     DataSource3.DataSet := ADOQuery2;
     DBGrid3.DataSource := DataSource3;


     ADOQuery2.Open;

     if DBGrid3.Fields[0].AsString = '' then
       memo1.lines.add('Max(id) not found.')
     else
       begin
         memo1.lines.add(DBGrid3.Fields[0].AsString+' found.');
         temp := StrToInt(DBGrid3.Fields[0].AsString);
         result := IntToStr(temp+1);
       end;


end;

//------------------------------------------------------------------------------
//-- Returns the keyword id# from the keyword text.
//--
//-- TABLE  : keywords
//-- INPUTS : keyword_txt  (such as 'PASS','FUNC TEST 1','VISUAL TEST1',...)
//--
//-- OUTPUT : id#          (such as '0','40','1309',...)
//--
//--          returns '' if failure occurs.
//--
//-- Developmental notes:
//--   ADOConnection <-- ADOQuery --> ADODatasource --> DBGrid
//------------------------------------------------------------------------------
function Tdbinterface.Get_Keyword_ID(keyword_txt:string):string;
Var
   txt : string;
begin
     result := '';

     if keyword_txt <> '' then
       begin
         txt := 'select id,keyword from Keywords where keyword=';
         txt := txt + '''' + keyword_txt + '''';
memo1.lines.add(txt);

         ADOQuery2.Close;
         ADOQuery2.SQL.Clear;
         ADOQuery2.SQL.Add(txt);

         DataSource3.DataSet := ADOQuery2;
         DBGrid3.DataSource := DataSource3;

         ADOQuery2.Open;

(*
         if DBGrid3.Fields[0].AsString <> '' then
           result := DBGrid3.Fields[0].AsString;
*)

         if DBGrid3.Fields[0].AsString = '' then
           memo1.lines.add(keyword_txt + ' not found.')
         else
           begin
             memo1.lines.add(DBGrid3.Fields[0].AsString+' found.');

             result := DBGrid3.Fields[0].AsString;
           end;
       end;

end;

//------------------------------------------------------------------------------
//-- This routine Queries the keyword table and looks to see if the keyword exists.
//--
//-- TABLE  : keywords
//-- INPUTS : keyword_txt  (such as '015008H-10','FUNC TEST 1','Capacitor','NPF',...)
//--
//-- OUTPUT : TRUE or FALSE
//--
//-- Developmental notes:
//--   ADOConnection <-- ADOQuery --> ADODatasource --> DBText
//------------------------------------------------------------------------------
function Tdbinterface.Keyword_Found(temp_txt:string):boolean;
Var
   txt : string;
begin
     result := false;
     
     if temp_txt <> '' then
       begin
         txt := 'select keyword from Keywords where keyword=';
         txt := txt + '''' + temp_txt + '''';
memo1.lines.add(txt);

         ADOQuery2.Close;
         ADOQuery2.SQL.Clear;
         ADOQuery2.SQL.Add(txt);

         DataSource3.DataSet := ADOQuery2;
         DBText1.DataSource := DataSource3;

         ADOQuery2.Open;

         if DBText1.Field.AsString = '' then memo1.lines.add(temp_txt + ' not found.')
         else
           begin
             memo1.lines.add(DBText1.Field.AsString+' found.');
             result := true;
           end;

       end;
end;
//------------------------------------------------------------------------------
//-- This routine Queries the Test table and looks to see if the Serial# exists.
//--
//-- TABLE  : keywords
//-- INPUTS : sn_txt     (such as '015008H-10 1234 56789')
//--
//-- OUTPUT : TRUE or FALSE
//--
//-- Developmental notes:
//--   ADOConnection <-- ADOQuery --> ADODatasource --> DBText
//------------------------------------------------------------------------------
function Tdbinterface.SN_Found(sn_txt:string):boolean;
Var
   txt : string;
begin
     result := false;

     //-- Skip this if we are not using a server for db stuff
     if not(Configuration.Qdb_enabled) then exit;

     if sn_txt <> '' then
       begin
         txt := 'select sn,loop from Test where sn=';
         txt := txt + '''' + sn_txt + '''';

memo1.lines.add(txt);

         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         ADOQuery1.SQL.Add(txt);

         DataSource2.DataSet := ADOQuery1;
         DBGrid2.DataSource := DataSource2;

         ADOQuery1.Open;

         if DBGrid2.Fields[0].AsString = '' then
           memo1.lines.add(sn_txt + ' not found.')
         else
           begin
             memo1.lines.add(DBGrid2.Fields[0].AsString+' found.');
             result := true;
           end;

       end;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure Tdbinterface.Button1Click(Sender: TObject);
var
   n : integer;
begin
     //-- Skip this if we are not using a server for db stuff
     if not(Configuration.Qdb_enabled) then
       begin
         exit;
       end;

     if uppercase(parse(1, edit1.Text,' ')) = 'DELETE' then
       begin
         ADOQuery1.SQL.Clear;
         ADOQuery1.SQL.Add(edit1.Text);
         ADOQuery1.ExecSQL;
       end
     else
       begin
         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         ADOQuery1.SQL.Add(edit1.Text);
         ADOQuery1.Open;

         n := ADOQuery1.RecordCount;
         memo1.Lines.Add('found : '+inttostr(n));
       end;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure Tdbinterface.FormShow(Sender: TObject);
begin
  //   ADOConnection1.GetTableNames(ListBox1.Items);
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure Tdbinterface.Post_Connection_Stuff;
Var
   i : integer;
begin
     ADOConnection1.GetTableNames(ListBox1.Items);
     ADODataSet1.Active := true;

exit;
//todo 0: fix ADODataSet1.FindFirst code below

     //-------------------------------------------
     //-- Build the username list.
     //-------------------------------------------
     username_list.Clear;
     ADODataSet1.FindFirst;
     for i := 0 to ADODataSet1.RecordCount-2 do
       begin
         username_list.Add(DBGrid1.Fields[0].AsString);
         ADODataSet1.FindNext;
       end;

end;



//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.Username_Found(txt: string): boolean;
Var
   i : integer;
begin
     result := false;
     ADODataSet1.FindFirst;

     if uppercase(DBGrid1.Fields[0].AsString) = uppercase(txt) then
       begin
         result := true;
         exit;
       end;

     for i := 1 to ADODataSet1.RecordCount-1 do
       begin
         ADODataSet1.FindNext;
         if uppercase(DBGrid1.Fields[0].AsString) = uppercase(txt) then
           begin
             result := true;
             exit;
           end;
       end;

end;



//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure Tdbinterface.FormCreate(Sender: TObject);
begin
     current_user := '';
     username_List := Tstringlist.Create;
     username_List.Clear;
end;



//------------------------------------------------------------------------------
//-- Attempts to open a connection to the database.
//-- NOTE: The EOleException must be ignored in order for this to work.
//-- Use TOOLS --> DEBUGGER OPTIONS and on the 'Language Exceptions' tab,
//-- add 'EOleException'.  Make sure it is checked.
//--
//-- ALSO:
//--  In the object Inspector for ADOConnection object, make sure 'KeepConnection'
//--  is set to FALSE.
//------------------------------------------------------------------------------
function Tdbinterface.Successful_Login(username,password:string): boolean;
Var
   txt : string;
begin
     txt := 'Provider=SQLOLEDB.1;';
     txt := txt + 'User ID='+username+';';
     txt := txt + 'Password='+password+';';
     txt := txt + 'Persist Security Info=True;';
     txt := txt + 'Initial Catalog=quality;Data Source=GLSQL;';
     txt := txt + 'Use Procedure for Prepare=1;';
     txt := txt + 'Auto Translate=True;Packet Size=4096;';  
     txt := txt + 'Use Encryption for Data=False;Tag with column collation when possible=False;';

     try
//       begin
         ADOConnection1.ConnectionString := txt;
         ADOConnection1.open;
//       end;
     finally
//       begin
         //--ADOConnection1.Connected := true;
         if ADOConnection1.Connected then
           begin
             memo1.lines.add('Connected as '+username);
             Post_Connection_Stuff;
             current_user := username;
             result := true;
           end
         else
           begin
             memo1.lines.add('Connection failed for '+username);
             current_user := '';
             result := false;
           end;
//       end;
     end;


end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure Tdbinterface.Logout;
begin
     memo1.lines.add('Disconnecting '+current_user);
     ADOConnection1.Close;
     current_user := '';
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.Set_Current_User(txt: string): boolean;
begin
     result := false;

     if Username_Found(txt) then
       begin
         current_user := txt;
         result := true;
       end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.Get_Current_User: string;
begin
     result :=  current_user;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure Tdbinterface.exit1Click(Sender: TObject);
begin
     close;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.Get_Username_List: Tstringlist;
begin

     result := username_List;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.DB_Connected: boolean;
begin
     result := ADOConnection1.Connected;
end;

//------------------------------------------------------------------------------
//-- Returns the list of process_step id# and keywords from the keywords table.
//-- Resulting table looks like:
//--     100 Visual Inspect
//--     200 Touch-up
//--     300 PCB Test
//--     500 Conformal Coat
//--     600 Mod Test
//--        ...
//--       etc..
//------------------------------------------------------------------------------
function Tdbinterface.Get_Process_Step_List: TStrings;
Var
   txt : String;
   i : integer;
begin
     ComboBox1.Clear;

     ADOQuery1.Close;
     ADOQuery1.SQL.Clear;
     txt := 'select id,keyword from Keywords where type = ''process step''';
     memo1.lines.add(txt);

     ADOQuery1.SQL.Add(txt);
     ADOQuery1.Open;

     if DBGrid2.Fields[0].AsString <> '' then
       begin
         ComboBox1.Items.Add(DBGrid2.Fields[0].AsString+' '+DBGrid2.Fields[1].AsString);

         for i := 1 to ADOQuery1.RecordCount-1 do
           begin
             ADOQuery1.FindNext;
             ComboBox1.Items.Add(DBGrid2.Fields[0].AsString+' '+DBGrid2.Fields[1].AsString);
           end;

         if Combobox1.Items.Count > -1 then Combobox1.ItemIndex := 0;
       end;

     result := ComboBox1.Items;
end;


//------------------------------------------------------------------------------
//-- INPUTS: sn - serial#
//--         ps - process step  (such as 300,1000,1304,...)
//--
//-- OUTPUT: TRUE if the symptom id for the last loop for serial# 'sn' is 0.
//------------------------------------------------------------------------------
function Tdbinterface.Previous_Step_Passed(sn,ps: string): boolean;
Var
   loopnum,symptomnum : string;
begin
     //-- Skip this if we are not using a server for db stuff
     if not(Configuration.Qdb_enabled) then
       begin
         result := true;
         exit;
       end;

     result := false;
     loopnum := Get_Last_Loop_Number(sn,ps);
     symptomnum := Get_Symptom_ID(sn,ps,loopnum);
     
     if symptomnum = '0' then
       result := true;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure Tdbinterface.ADOConnection1ConnectComplete(
  Connection: TADOConnection; const Error: Error;
  var EventStatus: TEventStatus);
begin
(*
     case EventStatus of
       esOK : showmessage('esOK');
       esErrorsOccured : showmessage('esErrorsOccured');
       esCantDeny : showmessage('esCantDeny');
       esCancel : showmessage('esCancel');
       esUnwantedEvent : showmessage('esUnwantedEvent');
     end;
*)
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure Tdbinterface.Button2Click(Sender: TObject);
Var
   txt : string;
begin
     //-- Skip this if we are not using a server for db stuff
     if not(Configuration.Qdb_enabled) then
       begin
         exit;
       end;

     txt := 'select * from test where sn = '''+edit2.Text+'''';

     ADOQuery1.Close;
     ADOQuery1.SQL.Clear;
     ADOQuery1.SQL.Add(txt);
     ADOQuery1.Open;

end;


//------------------------------------------------------------------------------
//-- This routine is used to  upload data to the Qdb which somehow did not
//-- work the first time.
//------------------------------------------------------------------------------
procedure Tdbinterface.Upload1Click(Sender: TObject);
Var
   upload_list : TStringlist;
   sn_txt,model_txt,timestamp_txt,symptom_txt : string;
   i : integer;
begin
     //-- Skip this if we are not using a server for db stuff
     if not(Configuration.Qdb_enabled) then
       begin
         exit;
       end;

     upload_list := TStringlist.Create;

     if fileexists('dbupload.txt') then
       begin
         upload_list.LoadFromFile('dbupload.txt');

         for i := 0 to upload_list.Count-1 do
           begin
             sn_txt      := parse(1,upload_list[i],',');
             symptom_txt := parse(2,upload_list[i],',');
             model_txt   := parse(5,upload_list[i],',');
             timestamp_txt := parse(6,upload_list[i],',');

             if not(Save_Test_Result(sn_txt,model_txt,'300','1',symptom_txt)) then
               showmessage('Error uploading : '+sn_txt);
           end;

           
       end;
end;

//------------------------------------------------------------------------------
//-- Uses the 'Test' table to return the #records found for a specific serial#
//-- and process_step#.
//--
//-- TABLE  : Test
//-- INPUTS : serial number 'sn'  (such as '015008H-10 1234 56789')
//--          process step# 'ps'  (such as 100, 300, 1000, 1305,...)
//--
//-- OUTPUT : number of records found    (such as 1,2,3,...)
//--
//--          returns 0 if nothing found.
//------------------------------------------------------------------------------
function Tdbinterface.Get_Number_of_Records(sn, ps: string): integer;
Var
   txt : string;
   n : integer;
begin
     result := 0;

     //-- Skip this if we are not using a server for db stuff
     if not(configuration.Qdb_Enabled) then  exit;

     if sn <> '' then
       begin
         ADOQuery1.Close;
         ADOQuery1.SQL.Clear;
         txt := 'select * from Test where sn = ';
         txt := txt + '''' + sn + '''';
         txt := txt + ' and process_step = ';
         txt := txt + '''' + ps + '''';

memo1.lines.add(txt);

         ADOQuery1.SQL.Add(txt);
         ADOQuery1.Open;
         n := ADOQuery1.RecordCount;
         result := n;
memo1.lines.add('records found : '+inttostr(n));

       end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.Get_Data_for(c, r: integer): string;
begin

     
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.Get_First_From_Table(c: integer): string;
begin
     DBGrid2.SelectedIndex := 0;

     ADODataSet1.FindFirst;
     result := DBGrid2.Fields[c].AsString;

end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function Tdbinterface.Get_Next_From_Table(c: integer): string;
begin
     ADODataSet1.FindNext;

     DBGrid2.SelectedIndex := DBGrid2.SelectedIndex + 1;

     result := DBGrid2.Fields[c].AsString;
end;

end.
