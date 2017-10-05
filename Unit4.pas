unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, VaClasses, VaComm, Vcl.ComCtrls;
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
//-- VALIDMODELS.DAT table format:
//--  Column Description
//--  ------ ------------------------------------------------------------------------------
//--     1   Model number
//--     2   DUT type : P4LOCAL,P4REMOTE,PS4LOCAL,PS4REMOTE,PS8LOCAL,PS8REMOTE,
//--                    PS16LOCAL,PS16REMOTE,RITEPRO
//--     3   Expected firmware revision number of DUT
//--     4   Generation [GEN1,GEN2]. Determines which base radio to use for communications.
//--     5   Determines manual or robotic test method. Valid parameters are [MANUAL,ROBOT].
//-----------------------------------------------------------------------------------------

const
     QDB_FILENAME          = 'C:\Program files\goldline\TEST_UPDATES.TXT';
     QDB_EXECUTABLE        = 'C:\Program files\goldline\TEST_UPDATES.EXE';
     LOCAL_OUTPUT_FILENAME = 'LOCAL_TEST_UPDATES.TXT';
type
  
  TConfiguration = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    VaComm1: TVaComm;
    Displaycomportlist: TComboBox;
    robotcomportlist: TComboBox;
    GenIbasecomportlist: TComboBox;
    GenIIbasecomportlist: TComboBox;
    Displayprogcomportlist: TComboBox;
    StatusBar1: TStatusBar;
    DisplayComport: TCheckBox;
    DisplayProgComport: TCheckBox;
    GenIbaseComport: TCheckBox;
    GenIIbaseComport: TCheckBox;
    RobotComport: TCheckBox;
    homerobotbeforetest: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label6Click(Sender: TObject);
  private
    { Private declarations }
    homedir : ansistring;
    function Get_ATE_Comport: string;
  public
    { Public declarations }
    procedure Save_Config_Data;

    function Init_Configuration:boolean;
    function Get_Unit_Type(model_number:string):string;
    function valid_model(temp_str:string):boolean;
    function Qdb_Enabled:boolean;
    function Get_Qdb_Executable_Name:string;
    function Get_Qdb_Datalog_FileName:string;
    function Get_Display_Comport:string;
    function Get_Display_Programming_Comport:string;
    function Get_GenI_Base_Comport:string;
    function Get_GenII_Base_Comport:string;
    function Get_Robot_Comport:string;
    function Get_Version_Number(model_number:string):string;
    function Get_Testing_type(model_number:string):ansistring;
    function Get_Generation_type(model_number:string):ansistring;

    function Display_Comport_Enabled:boolean;
    function Display_Prog_Comport_Enabled:boolean;
    function GenI_Base_Comport_Enabled:boolean;
    function GenII_Base_Comport_Enabled:boolean;
    function Robot_Comport_Enabled:boolean;
    function home_robot_before_LCD_testing:boolean;
  end;

var
  Configuration: TConfiguration;

  Config_File   : text;
  Datalog_File  : text;
  
  ATE_Comport : string;
  Datalogging : boolean;

implementation

{$R *.DFM}

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function parse(i:integer;tstr:string;pchr:char):string;
Var
   x : integer;
   astr : string;
   plist : Tstringlist;
   space_found : boolean;
begin
     result := '';
     plist  := Tstringlist.Create;
     astr   := '';
     space_found := false;

     //-- remove any leading white space.
     tstr := trimleft(tstr);

     if tstr = '' then exit;

     for x := 1 to length(tstr) do
       begin
         if (tstr[x]=pchr) and not(space_found) then
           begin
             if pchr=' ' then space_found := true;     //-- White space needs to be handled differently.

             plist.Add(astr);
             astr := '';
           end
         else if (tstr[x]=pchr) and space_found then
           begin
             //-- do nothing
           end
         else if (tstr[x]<>pchr) and space_found then
           begin
             space_found := false;
             astr := astr + tstr[x];
           end
         else
           astr := astr + tstr[x];
       end;

     //-- the last item needs to be added to the list.
     if astr <> '' then plist.Add(astr);

     if i <= plist.Count then
       result := plist.Strings[i-1];

     plist.free;
end;


//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
function TConfiguration.Get_Version_Number(model_number:string):string;
Var
   i : integer;
   item_str : string;
begin
     result := '';

     //-- scan memo1 until we find model number.
     for i := 0 to memo1.Lines.Count do
       begin
         //-- Get the 1st item in this row. This is the model number
         item_str := parse(1,memo1.Lines.Strings[i],',');

         if item_str = model_number then
           begin
             //-- get the 3rd item in the row
             result := parse(3,memo1.Lines.Strings[i],',');
             exit;
           end;
       end;
end;

function TConfiguration.home_robot_before_LCD_testing: boolean;
begin
    result := homerobotbeforetest.checked;
end;

//-----------------------------------------------------------------------------------------
//-- Used to determine which base radio to use.
//-- Valid field data : GEN1,GEN2
//-----------------------------------------------------------------------------------------
function TConfiguration.Get_Generation_type(model_number: string): ansistring;
Var
   i : integer;
   item_str : string;
begin
     result := '';

     //-- scan memo1 until we find model number.
     for i := 0 to memo1.Lines.Count do
       begin
         //-- Get the 1st item in this row. This is the model number
         item_str := parse(1,memo1.Lines.Strings[i],',');

         if item_str = model_number then
           begin
             //-- get the 4th item in the row
             result := parse(4,memo1.Lines.Strings[i],',');
             exit;
           end;
       end;
end;


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure TConfiguration.FormCreate(Sender: TObject);
var
    i : integer;
    templist : TStringlist;
begin
    homedir := getcurrentdir;

    //-- Populate the comport dropdown lists.
    templist := TStringlist.create;

    Vacomm1.GetComPortNames(templist);
    for i := 1 to templist.Count do
      begin
        Displaycomportlist.Items.add(templist.Strings[i-1]);
        Displayprogcomportlist.Items.add(templist.Strings[i-1]);
        Robotcomportlist.Items.add(templist.Strings[i-1]);
        GenIbasecomportlist.Items.add(templist.Strings[i-1]);
        GenIIbasecomportlist.Items.add(templist.Strings[i-1]);
      end;

    templist.free;

end;

procedure TConfiguration.FormShow(Sender: TObject);
begin

end;

//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
function TConfiguration.Get_Qdb_Executable_Name:string;
begin
     result := QDB_EXECUTABLE;
end;

//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
function TConfiguration.Get_Qdb_Datalog_FileName:string;
begin
     result := QDB_FILENAME;
end;

//-----------------------------------------------------------------------------------------
//-- Returns whatever COM was entered in the Config file at startup
//-----------------------------------------------------------------------------------------
function TConfiguration.GenII_Base_Comport_Enabled: boolean;
begin
     result := GenIIbaseComport.Checked;
end;

function TConfiguration.GenI_Base_Comport_Enabled: boolean;
begin
     result := GenIbaseComport.Checked;
end;

function TConfiguration.Get_ATE_Comport:string;
begin
     result := ATE_Comport;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.Get_Display_Comport: string;
begin
    result := Displaycomportlist.Text;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.Get_Display_Programming_Comport: string;
begin
    result := DisplayProgcomportlist.Text;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.Get_GenII_Base_Comport: string;
begin
    result := GenIIbasecomportlist.Text;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.Get_GenI_Base_Comport: string;
begin
    result := GenIbasecomportlist.Text;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.Get_Robot_Comport: string;
begin
    result := Robotcomportlist.Text;
end;

//------------------------------------------------------------------------------
//-- Returns the 5th item in column. This is the testing type. (MANUAL or ROBOT)
//------------------------------------------------------------------------------
function TConfiguration.Get_Testing_type(model_number: string): ansistring;
Var
   i : integer;
   item_str : string;
begin
     result := '';

     //-- scan memo1 until we find model number.
     for i := 0 to memo1.Lines.Count do
       begin
         //-- Get the 1st item in this row. This is the model number
         item_str := parse(1,memo1.Lines.Strings[i],',');

         if item_str = model_number then
           begin
             //-- get the 5th item in the row
             result := parse(5,memo1.Lines.Strings[i],',');
             exit;
           end;
       end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.Qdb_Enabled:boolean;
begin
     result := CheckBox1.Checked;
end;

function TConfiguration.Robot_Comport_Enabled: boolean;
begin
     result := RobotComport.Checked;
end;

//------------------------------------------------------------------------------
//-- Returns Display unit type as a string
//--   nullstring   = UNKNOWN
//--   P4LOCAL     = P4 local
//--   P4REMOTE    = P4 remote
//------------------------------------------------------------------------------
function TConfiguration.Get_Unit_Type(model_number:string):string;
Var
   i : integer;
   item_str : string;
begin
     result := '';

     //-- scan memo1 until we find model number.
     for i := 0 to memo1.Lines.Count do
       begin
         //-- Get the 1st item in this row. This is the model number
         item_str := parse(1,memo1.Lines.Strings[i],',');

         if item_str = model_number then
           begin
             //-- get the 2nd item in the row
             result := parse(2,memo1.Lines.Strings[i],',');
             exit;
           end;
       end;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.Init_Configuration:boolean;
var
    i : integer;
    templist : TStringlist;
begin
     result := true;

     //-- Load Valid Model list
     memo1.clear;
     if FileExists(homedir+'\Valid_models.dat') then
       memo1.Lines.LoadFromFile(homedir+'\Valid_models.dat')
     else
       begin
         result := false;
         showmessage('Unable to load ''Valid_models.dat''');
       end;

     //-- Load configuration parameters
     if FileExists(homedir+'\ATECFG.DAT') then
       begin
         templist := TStringlist.create;
         templist.LoadFromFile(homedir+'\ATECFG.DAT');

         if templist.Values['DISPLAYCOMPORT'] <> '' then
           Displaycomportlist.ItemIndex := Displaycomportlist.Items.IndexOf(templist.Values['DISPLAYCOMPORT'])
         else
           Displaycomportlist.ItemIndex := 0;

         if templist.Values['DISPLAYPROGCOMPORT'] <> '' then
           Displayprogcomportlist.ItemIndex := Displayprogcomportlist.Items.IndexOf(templist.Values['DISPLAYPROGCOMPORT'])
         else
           Displayprogcomportlist.ItemIndex := 0;

         if templist.Values['ROBOTCOMPORT'] <> '' then
           Robotcomportlist.ItemIndex := Robotcomportlist.Items.IndexOf(templist.Values['ROBOTCOMPORT'])
         else
           Robotcomportlist.ItemIndex := 0;

         if templist.Values['GENIBASECOMPORT'] <> '' then
           GenIbasecomportlist.ItemIndex := GenIbasecomportlist.Items.IndexOf(templist.Values['GENIBASECOMPORT'])
         else
           GenIbasecomportlist.ItemIndex := 0;

         if templist.Values['GENIIBASECOMPORT'] <> '' then
           GenIIbasecomportlist.ItemIndex := GenIIbasecomportlist.Items.IndexOf(templist.Values['GENIIBASECOMPORT'])
         else
           GenIIbasecomportlist.ItemIndex := 0;


         CheckBox1.checked           := uppercase(templist.Values['QDBENABLED']) = 'TRUE';
         DisplayComport.checked      := uppercase(templist.Values['DISPLAYCOMPORTENABLED']) = 'TRUE';
         DisplayProgComport.checked  := uppercase(templist.Values['DISPLAYPROGCOMPORTENABLED']) = 'TRUE';
         GenIbaseComport.checked     := uppercase(templist.Values['GENIBASECOMPORTENABLED']) = 'TRUE';
         GenIIbaseComport.checked    := uppercase(templist.Values['GENIIBASECOMPORTENABLED']) = 'TRUE';
         RobotComport.checked        := uppercase(templist.Values['ROBOTCOMPORTENABLED']) = 'TRUE';
         homerobotbeforetest.checked := uppercase(templist.Values['HOMEROBOTBEFORETEST']) = 'TRUE';


         templist.Free;
       end
     else
       begin
         result := false;
         showmessage('Unable to load ''ATECFG.DAT''');
       end;




end;

procedure TConfiguration.Label6Click(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
//-- Close button.
//------------------------------------------------------------------------------
procedure TConfiguration.Button2Click(Sender: TObject);
Var
   response : word;
begin
     if memo1.Modified then
       begin
         response := MessageDlg('Save Changes?',mtConfirmation,mbYesNoCancel,0);
         
         if response = MrYes then memo1.Lines.SaveToFile(homedir+'\Valid_models.dat')
         else if response = MrCancel then exit;
       end;

     Close;
end;

function TConfiguration.Display_Comport_Enabled: boolean;
begin
     result := DisplayComport.Checked;
end;

function TConfiguration.Display_Prog_Comport_Enabled: boolean;
begin
    result := DisplayProgComport.Checked;
end;

//------------------------------------------------------------------------------
//-- Save button.
//------------------------------------------------------------------------------
procedure TConfiguration.Button1Click(Sender: TObject);
begin
     Save_Config_Data;

     memo1.Lines.SaveToFile(homedir+'\Valid_models.dat');

end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.valid_model(temp_str:string):boolean;
Var
   i : integer;
   item_str : string;
begin
     result := false;
     
     for i := 0 to memo1.Lines.Count do
       begin
         //-- Get the first item in this row.
         item_str := parse(1,memo1.Lines.Strings[i],',');

         if item_str = temp_str then
           begin
             result := true;
             exit;
           end;
       end;
end;

//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
procedure TConfiguration.Save_Config_Data;
Var
   config_data : TStringList;
begin
     config_data := TStringList.create;

     //-------------------------
     //-- Save all parameters.
     //-------------------------

     config_data.Add('DISPLAYCOMPORT='+Displaycomportlist.text);
     config_data.Add('DISPLAYPROGCOMPORT='+Displayprogcomportlist.text);
     config_data.Add('ROBOTCOMPORT='+Robotcomportlist.text);
     config_data.Add('GENIBASECOMPORT='+GenIbasecomportlist.text);
     config_data.Add('GENIIBASECOMPORT='+GenIIbasecomportlist.text);

     if CheckBox1.checked then
       config_data.Add('QDBENABLED=TRUE')
     else
       config_data.Add('QDBENABLED=FALSE');

     if DisplayComport.checked then
       config_data.Add('DISPLAYCOMPORTENABLED=TRUE')
     else
       config_data.Add('DISPLAYCOMPORTENABLED=FALSE');

     if DisplayProgComport.checked then
       config_data.Add('DISPLAYPROGCOMPORTENABLED=TRUE')
     else
       config_data.Add('DISPLAYPROGCOMPORTENABLED=FALSE');

     if GenIbaseComport.checked then
       config_data.Add('GENIBASECOMPORTENABLED=TRUE')
     else
       config_data.Add('GENIBASECOMPORTENABLED=FALSE');

     if GenIIbaseComport.checked then
       config_data.Add('GENIIBASECOMPORTENABLED=TRUE')
     else
       config_data.Add('GENIIBASECOMPORTENABLED=FALSE');

     if RobotComport.checked then
       config_data.Add('ROBOTCOMPORTENABLED=TRUE')
     else
       config_data.Add('ROBOTCOMPORTENABLED=FALSE');

     if homerobotbeforetest.checked then
       config_data.Add('HOMEROBOTBEFORETEST=TRUE')
     else
       config_data.Add('HOMEROBOTBEFORETEST=FALSE');



     config_data.SaveToFile(homedir+'\ATECFG.DAT');
     config_data.free;



(*
      //-- Firmware Ver#
     config_data.Add(Edit1.text);

     //-- Comport data
{
     if SpinEdit1.Value = 1 then config_data.Add('COM1')
     else if SpinEdit1.Value = 2 then config_data.Add('COM2')
     else if SpinEdit1.Value = 3 then config_data.Add('COM3')
     else if SpinEdit1.Value = 4 then config_data.Add('COM4')
     else if SpinEdit1.Value = 5 then config_data.Add('COM5');
 }
     config_data.Add('COM'+inttostr(SpinEdit1.Value));

     //-- Qdb stuff
     if Checkbox1.Checked then config_data.Add('TRUE') else config_data.Add('FALSE');

     //-- Testcode path.
     config_data.Add(testcodepath.Text);

     //-- Save config file.
     config_data.SaveToFile('ATECFG.DAT');
     config_data.Destroy;

     Clear_Modifies;

 *)
end;


end.
