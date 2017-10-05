unit robotpositionunit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Menus;

//-----------------------------------------------------------------------------------------
//-- position table format: comma separated variable (*.csv)
//--  Column Description
//--  ------ ------------------------------------------------------------------------------
//--     1   Switch ID.  ['SW1','SW2','SW3','SW4','SW5',...]
//--     2   X Position
//--     3   Y Position
//--     4   Z Position
//--     5   Button Name ['SERVICE','FILTER','LIGHTS',.....]
//-----------------------------------------------------------------------------------------
CONST
  POSITIONTABLENAME = 'positiontable.dat';
  XMAX = 6.00;
  YMAX = 6.00;
  ZMAX = 14.00;

type
  Trobotposition = class(TForm)
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    Panel1: TPanel;
    savebtn: TButton;
    closebtn: TButton;
    modelnumber: TComboBox;
    PopupMenu1: TPopupMenu;
    NewTable1: TMenuItem;
    DeleteTable1: TMenuItem;
    newmodeltype: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    homebtn: TButton;
    movebtn: TButton;
    xstr: TEdit;
    ystr: TEdit;
    zstr: TEdit;
    pressbtn: TButton;
    releasebtn: TButton;
    N1: TMenuItem;
    RobotControl1: TMenuItem;
    pwmonbtn: TButton;
    pwmoffbtn: TButton;
    jogleftbtn: TButton;
    jogdownbtn: TButton;
    jogrightbtn: TButton;
    jogupbtn: TButton;
    jogfactor: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure savebtnClick(Sender: TObject);
    procedure closebtnClick(Sender: TObject);
    procedure NewTable1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure modelnumberChange(Sender: TObject);
    procedure RobotControl1Click(Sender: TObject);
    procedure homebtnClick(Sender: TObject);
    procedure movebtnClick(Sender: TObject);
    procedure pressbtnClick(Sender: TObject);
    procedure releasebtnClick(Sender: TObject);
    procedure pwmonbtnClick(Sender: TObject);
    procedure pwmoffbtnClick(Sender: TObject);
    procedure jogleftbtnClick(Sender: TObject);
    procedure jogrightbtnClick(Sender: TObject);
    procedure jogupbtnClick(Sender: TObject);
    procedure jogdownbtnClick(Sender: TObject);
  private
    { Private declarations }
    homedir : ansistring;
    current_positiontable : ansistring;
    function load_position_table_names:boolean;
  public
    { Public declarations }
    procedure get_position(switchname:ansistring;var X,Y,Z : real);       overload;
    procedure get_position(switchname:ansistring;var X,Y,Z : ansistring); overload;
    function load_position_table(modelstr:ansistring):boolean;
    function get_current_positiontable_name:ansistring;
    function get_switch_name(swx:ansistring):ansistring;
    function get_count:integer;
    procedure get_line(i:integer;var x,y,z:real; var sw_id,sw_name:ansistring);  overload;
    procedure get_line(i:integer;var x,y,z:ansistring; var sw_id,sw_name:ansistring); overload;
  end;

var
  robotposition: Trobotposition;

implementation

{$R *.dfm}

uses Unit1;
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
//-----------------------------------------------------------------------------------------
procedure Trobotposition.Button1Click(Sender: TObject);
var
    filenamestr : ansistring;
begin
    filenamestr := homedir+'\'+newmodeltype.text+'_'+POSITIONTABLENAME;

    if fileexists(filenamestr) then
      begin
        if messagedlg('Table already exists.  Replace it?',mtconfirmation,[mbYes,mbNo],0) = mrYes then
          begin
            memo1.Clear;
            memo1.Lines.SaveToFile(filenamestr);
            current_positiontable := newmodeltype.text;
            modelnumber.ItemIndex := modelnumber.Items.add(newmodeltype.text);
            modelnumber.Items.SaveToFile(homedir+'\'+POSITIONTABLENAME);
          end;
      end
    else
      begin
        memo1.Clear;
        memo1.Lines.SaveToFile(filenamestr);
        current_positiontable := newmodeltype.text;
        modelnumber.ItemIndex := modelnumber.Items.add(newmodeltype.text);
        modelnumber.Items.SaveToFile(homedir+'\'+POSITIONTABLENAME);
        memo1.Clear;
      end;


    newmodeltype.Visible := false;
    Label1.Visible       := false;
    Button1.Visible      := false;
    Button2.Visible      := false;

end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.Button2Click(Sender: TObject);
begin
    newmodeltype.Visible := false;
    Label1.Visible       := false;
    Button1.Visible      := false;
    Button2.Visible      := false;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.closebtnClick(Sender: TObject);
begin
    close;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.FormCreate(Sender: TObject);
begin
    homedir := getcurrentdir;
    memo1.Clear;
    load_position_table_names;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function Trobotposition.get_count: integer;
begin
    result := memo1.Lines.Count;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function Trobotposition.get_current_positiontable_name: ansistring;
begin
    result := current_positiontable;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.get_line(i: integer; var x, y, z: real; var sw_id,
  sw_name: ansistring);
begin
     if i < memo1.lines.Count then
       begin
         sw_id   := parse(1,memo1.Lines.Strings[i],',');

         //-- Watch for any inadvertant blank lines.
         if sw_id <> '' then
           begin
             sw_name := parse(5,memo1.Lines.Strings[i],',');
             x := strtofloat(parse(2,memo1.Lines.Strings[i],','));
             y := strtofloat(parse(3,memo1.Lines.Strings[i],','));
             z := strtofloat(parse(4,memo1.Lines.Strings[i],','));
           end
         else
           begin
             sw_name := '';
             x := -1;
             y := -1;
             z := -1;
           end;
       end
     else
       begin
         sw_id   := '';
         sw_name := '';
         x := -1;
         y := -1;
         z := -1;
       end;
end;

//-----------------------------------------------------------------------------------------
//-- Same as above but returns X,Y,Z as ansistrings
//-----------------------------------------------------------------------------------------
procedure Trobotposition.get_line(i: integer; var x, y, z: ansistring; var sw_id,
  sw_name: ansistring);
begin
     if i < memo1.lines.Count then
       begin
         sw_id   := parse(1,memo1.Lines.Strings[i],',');

         //-- Watch for any inadvertant blank lines.
         if sw_id <> '' then
           begin
             sw_name := parse(5,memo1.Lines.Strings[i],',');
             x := parse(2,memo1.Lines.Strings[i],',');
             y := parse(3,memo1.Lines.Strings[i],',');
             z := parse(4,memo1.Lines.Strings[i],',');
           end
         else
           begin
             sw_name := '';
             x := '';
             y := '';
             z := '';
           end;
       end
     else
       begin
         sw_id   := '';
         sw_name := '';
         x := '';
         y := '';
         z := '';
       end;
end;

//-----------------------------------------------------------------------------------------
//-- returns position of switchname button.
//-- returns X=-1, Y=-1, Z=-1 if switchname not found.
//-- NOTE: procedure 'load_position_table' must be called with modelstr in order
//--       to load the correct table.
//-----------------------------------------------------------------------------------------
procedure Trobotposition.get_position(switchname: ansistring; var X, Y, Z: real);
var
  i : integer;
  txt : ansistring;
begin
    //-- default to unknown modelstr
    X := -1;
    Y := -1;
    Z := -1;

    for i := 0 to memo1.Lines.Count -1 do
      begin
        txt := uppercase(parse(1,memo1.Lines.Strings[i],','));
        if txt = uppercase(switchname) then
          begin
            X := strtofloat(parse(2,memo1.Lines.Strings[i],','));
            Y := strtofloat(parse(3,memo1.Lines.Strings[i],','));
            Z := strtofloat(parse(4,memo1.Lines.Strings[i],','));
            exit;
          end;
      end;
end;
//-----------------------------------------------------------------------------------------
//-- Same as above but returns X,Y,Z as ansistrings
//-----------------------------------------------------------------------------------------
procedure Trobotposition.get_position(switchname: ansistring; var X, Y, Z: ansistring);
var
  i : integer;
  txt : ansistring;
begin
    //-- default to unknown modelstr
    X := '';
    Y := '';
    Z := '';

    for i := 0 to memo1.Lines.Count -1 do
      begin
        txt := uppercase(parse(1,memo1.Lines.Strings[i],','));
        if txt = uppercase(switchname) then
          begin
            X := parse(2,memo1.Lines.Strings[i],',');
            Y := parse(3,memo1.Lines.Strings[i],',');
            Z := parse(4,memo1.Lines.Strings[i],',');
            exit;
          end;
      end;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function Trobotposition.get_switch_name(swx: ansistring): ansistring;
var
  i : integer;
  txt : ansistring;
begin
    result := '';

    for i := 0 to memo1.Lines.Count -1 do
      begin
        txt := uppercase(parse(1,memo1.Lines.Strings[i],','));
        if txt = uppercase(swx) then
          begin
            result := parse(5,memo1.Lines.Strings[i],',');
            exit;
          end;
      end;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.homebtnClick(Sender: TObject);
begin
    form1.robotcomport.WriteText('home'+LF);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.jogdownbtnClick(Sender: TObject);
var
    cmdstr : ansistring;
    x,y : real;
begin
    if xstr.text = '' then xstr.text := '0.00';
    if ystr.text = '' then ystr.text := '0.00';

    x := strtofloat(xstr.text);
    y := strtofloat(ystr.text);

    case jogfactor.ItemIndex of
      0 : if (y + 0.01 <= YMAX) then y := y + 0.01;
      1 : if (y + 0.10 <= YMAX) then y := y + 0.10;
      2 : if (y + 1.00 <= YMAX) then y := y + 1.00;
    end;

    xstr.text := formatfloat('0.00',x);
    ystr.text := formatfloat('0.00',y);

    //-- Build command string
    cmdstr := 'moveXY='+xstr.text+','+ystr.text+LF;
    form1.robotcomport.WriteText(cmdstr);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.jogleftbtnClick(Sender: TObject);
var
    cmdstr : ansistring;
    x,y : real;
begin
    if xstr.text = '' then xstr.text := '0.00';
    if ystr.text = '' then ystr.text := '0.00';

    x := strtofloat(xstr.text);
    y := strtofloat(ystr.text);

    case jogfactor.ItemIndex of
      0 : if (x - 0.01 >= 0) then x := x - 0.01;
      1 : if (x - 0.10 >= 0) then x := x - 0.10;
      2 : if (x - 1.00 >= 0) then x := x - 1.00;
    end;

    xstr.text := formatfloat('0.00',x);
    ystr.text := formatfloat('0.00',y);

    //-- Build command string
    cmdstr := 'moveXY='+xstr.text+','+ystr.text+LF;
    form1.robotcomport.WriteText(cmdstr);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.jogrightbtnClick(Sender: TObject);
var
    cmdstr : ansistring;
    x,y : real;
begin
    if xstr.text = '' then xstr.text := '0.00';
    if ystr.text = '' then ystr.text := '0.00';

    x := strtofloat(xstr.text);
    y := strtofloat(ystr.text);

    case jogfactor.ItemIndex of
      0 : if (x + 0.01 <= XMAX) then x := x + 0.01;
      1 : if (x + 0.10 <= XMAX) then x := x + 0.10;
      2 : if (x + 1.00 <= XMAX) then x := x + 1.00;
    end;

    xstr.text := formatfloat('0.00',x);
    ystr.text := formatfloat('0.00',y);

    //-- Build command string
    cmdstr := 'moveXY='+xstr.text+','+ystr.text+LF;
    form1.robotcomport.WriteText(cmdstr);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.jogupbtnClick(Sender: TObject);
var
    cmdstr : ansistring;
    x,y : real;
begin
    if xstr.text = '' then xstr.text := '0.00';
    if ystr.text = '' then ystr.text := '0.00';

    x := strtofloat(xstr.text);
    y := strtofloat(ystr.text);

    case jogfactor.ItemIndex of
      0 : if (y - 0.01 >= 0) then y := y - 0.01;
      1 : if (y - 0.10 >= 0) then y := y - 0.10;
      2 : if (y - 1.00 >= 0) then y := y - 1.00;
    end;

    xstr.text := formatfloat('0.00',x);
    ystr.text := formatfloat('0.00',y);

    //-- Build command string
    cmdstr := 'moveXY='+xstr.text+','+ystr.text+LF;
    form1.robotcomport.WriteText(cmdstr);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function Trobotposition.load_position_table(modelstr:ansistring):boolean;
var
    filenamestr : ansistring;
begin
    result := false;
    filenamestr := homedir+'\'+modelstr+'_'+POSITIONTABLENAME;

    if fileexists(filenamestr) then
      begin
        memo1.lines.LoadFromFile(filenamestr);
        current_positiontable := modelstr;

        modelnumber.ItemIndex := modelnumber.Items.IndexOf(modelstr);
        result := true;
      end;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function Trobotposition.load_position_table_names: boolean;
var
    filenamestr : ansistring;
begin
    result := false;
    filenamestr := homedir+'\'+POSITIONTABLENAME;

    if fileexists(filenamestr) then
      begin
        modelnumber.Items.LoadFromFile(filenamestr);

        if modelnumber.Items.Count > 0 then
          modelnumber.ItemIndex := 0;

        result := true;
      end;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.modelnumberChange(Sender: TObject);
begin
    if modelnumber.ItemIndex <> -1 then
      begin
        load_position_table(modelnumber.Text);
      end;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.movebtnClick(Sender: TObject);
var
    cmdstr : ansistring;
begin
    if xstr.text = '' then xstr.text := '0.00';
    if ystr.text = '' then ystr.text := '0.00';
    if zstr.text = '' then zstr.text := '20.00';

    //-- Build command string
    cmdstr := 'moveXY='+xstr.text+','+ystr.text+LF;
    form1.robotcomport.WriteText(cmdstr);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.NewTable1Click(Sender: TObject);
begin
    newmodeltype.Visible := true;
    Label1.Visible       := true;
    Button1.Visible      := true;
    Button2.Visible      := true;

    newmodeltype.Text := '';
    newmodeltype.SetFocus;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.pressbtnClick(Sender: TObject);
var
    cmdstr : ansistring;
begin
    if zstr.Text = '' then zstr.Text := '20.00';

    //-- Build command string
    cmdstr := 'moveZ='+zstr.text+LF;

    form1.robotcomport.WriteText(cmdstr);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.pwmoffbtnClick(Sender: TObject);
begin
    form1.robotcomport.WriteText('pwmOFF'+LF);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.pwmonbtnClick(Sender: TObject);
begin
    form1.robotcomport.WriteText('pwmON'+LF);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.releasebtnClick(Sender: TObject);
begin
    form1.robotcomport.WriteText('release'+LF);
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.RobotControl1Click(Sender: TObject);
begin
    RobotControl1.Checked := not(RobotControl1.Checked);

    if RobotControl1.Checked then
      begin
        newmodeltype.Visible := false;
        Label1.Visible       := false;
        Button1.Visible      := false;
        Button2.Visible      := false;

        homebtn.Visible := true;
        movebtn.Visible := true;
        pressbtn.Visible := true;
        releasebtn.Visible := true;
        xstr.Visible := true;
        ystr.Visible := true;
        zstr.Visible := true;
        pwmonbtn.visible := true;
        pwmoffbtn.visible := true;
        jogupbtn.visible := true;
        jogdownbtn.visible := true;
        jogleftbtn.visible := true;
        jogrightbtn.visible := true;
        jogfactor.Visible := true;
      end
    else
      begin
        homebtn.Visible := false;
        movebtn.Visible := false;
        pressbtn.Visible := false;
        releasebtn.Visible := false;
        xstr.Visible := false;
        ystr.Visible := false;
        zstr.Visible := false;
        pwmonbtn.visible := false;
        pwmoffbtn.visible := false;
        jogupbtn.visible := false;
        jogdownbtn.visible := false;
        jogleftbtn.visible := false;
        jogrightbtn.visible := false;
        jogfactor.Visible := false;
      end;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure Trobotposition.savebtnClick(Sender: TObject);
begin
    memo1.lines.SaveToFile( homedir+'\'+modelnumber.text+'_'+POSITIONTABLENAME);
end;


end.
