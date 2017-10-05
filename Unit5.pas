unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

const
     VALIDATE_EXECUTABLE   = 'C:\Program files\goldline\VALIDATE.EXE';
     VALIDATE_FILENAME     = 'C:\Program files\goldline\USERDATA.TXT';
     VALIDATE_RESPONSE     = 'C:\Program files\goldline\VALIDATE.TXT';
     USERNAME_FILENAME     = 'C:\Program files\goldline\USERNAME.DAT';

     DELIMITER             = #9;  //-- #9 = tab

type
  Tusenamepassword = class(TForm)
    Panel1: TPanel;
    Username: TComboBox;
    Password: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Load_Username_Table;
    procedure update_username_list;

    function Valid:boolean;
    function Password_Valid:boolean;
    function Get_Username:String;
    function Username_Valid:boolean;

  end;

var
  usenamepassword: Tusenamepassword;
  valid_username : boolean;
  Validate_File : text;

implementation

{$R *.DFM}

//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
function Tusenamepassword.Get_Username:String;
begin
     result := Username.Text;
end;
//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
procedure Tusenamepassword.update_username_list;
Var
   userdata : TStringlist;
   i     : integer;
   found : boolean;
begin
     //-- See if text is in table.  Add it if not.
     found := false;

     for i := 0 to Username.Items.count-1 do
       if uppercase(Username.text) = uppercase(Username.Items.Strings[i]) then found := true;

     if not found then
       Username.Items.Add(uppercase(Username.text));


     //-- Save usernames
     userdata := TStringlist.create;

     //-- Copy the pulldown list to the stringlist.
     for i := 0 to username.Items.count-1 do
       userdata.Add(username.Items.Strings[i]);

     userdata.SaveToFile(USERNAME_FILENAME);
     userdata.destroy;
end;

//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
procedure Tusenamepassword.Load_Username_Table;
Var
   userdata : TStringlist;
   i : integer;
begin
     userdata := TStringlist.create;

     if FileExists(USERNAME_FILENAME) then
       begin
         userdata.LoadFromFile(USERNAME_FILENAME);

         //-- copy the usernames to the puldown box.
         Username.Clear;
         for i := 0 to userdata.Count-1 do
           Username.Items.Add(userdata.Strings[i]);

       end;

       
     userdata.destroy;
end;



//-----------------------------------------------------------------------------------------
//-- Performs validation check of Username and Password
//-----------------------------------------------------------------------------------------
function Tusenamepassword.Valid:boolean;
Var
   Done        : boolean;
   dummy_list  : TStringlist;
   Save_Cursor : TCursor;
   dummy_str : string;
begin
     result := false;
     
     //-- Delete the file used to verify username and password.
     If FileExists(VALIDATE_RESPONSE) then
       DeleteFile(VALIDATE_RESPONSE);

     //-- Call VALIDATE executable.
     if FileExists(VALIDATE_EXECUTABLE) then
       Winexec(VALIDATE_EXECUTABLE, 1)    //-- 1 = application is visible, 0 = in background.
     else
       begin
         Showmessage('Unable to find : '+VALIDATE_EXECUTABLE);
         result := false;
         exit;
       end;

     Save_Cursor    := Screen.Cursor;
     Screen.Cursor  := crHourglass;    //-- Show hourglass cursor
     Label3.caption := 'VALIDATING';

     try
         //-- Wait for response.
         Done := false;
         Repeat
           Application.ProcessMessages;

           If FileExists(VALIDATE_RESPONSE) then
             begin
               dummy_list := TStringlist.create;
               dummy_list.LoadFromFile(VALIDATE_RESPONSE);
               dummy_str := dummy_list.Strings[0];
               
               if uppercase(dummy_str) = 'PASS' then  result := true
               else result := false;

               dummy_list.free;
               Done := true;
             end;

         Until Done;

     finally
       Screen.Cursor := Save_Cursor;  //-- Always restore to normal
     end;

end;


//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
procedure Tusenamepassword.FormCreate(Sender: TObject);
begin
    valid_username := false;
end;


//-----------------------------------------------------------------------------------------
//-- OK button
//-----------------------------------------------------------------------------------------
procedure Tusenamepassword.Button1Click(Sender: TObject);
begin

     //-- Write Username and Password to 'USERDATA.TXT' file.
     AssignFile(Validate_File,VALIDATE_FILENAME);
     Rewrite(Validate_File);

     Write(Validate_File,Username.text + DELIMITER + Password.Text);
     CloseFile(Validate_File);

end;


//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
function Tusenamepassword.Username_Valid:boolean;
begin
     if (Username.text = '') then  result := true
     else result := false;
end;

//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
function Tusenamepassword.Password_Valid:boolean;
begin
     Password.Text := trim(Password.Text);

     if (Password.Text <> '') then result := true
     else result := false;
end;


//-----------------------------------------------------------------------------------------
//--
//-----------------------------------------------------------------------------------------
procedure Tusenamepassword.FormShow(Sender: TObject);
begin
     label3.caption := '';
end;

end.




