unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  
  TConfiguration = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function parse(i:integer;tstr:string):string;
  public
    { Public declarations }
    function Init_Configuration:boolean;
    function Get_Unit_Type(model_number:string):string;
    function valid_model(temp_str:string):boolean;
  end;

var
  Configuration: TConfiguration;

implementation

{$R *.DFM}


//------------------------------------------------------------------------------
//-- Returns Display unit type as a string
//--   nullstring   = UNKNOWN
//--   PS4LOCAL     = PS4 local
//--   PS4REMOTE    = PS4 remote
//--   PS4REMOTERF  = PS4 RF
//--
//--   PS8LOCAL     = PS8 local
//--   PS8REMOTE    = PS8 remote
//--   PS8REMOTERF  = PS8 RF
//--
//--   PS16LOCAL    = PS16 local
//--   PS16REMOTE   = PS16 remote
//--   PS16REMOTERF = PS16 RF
//--
//--   PS32LOCAL    = PS32 local
//--   PS32REMOTE   = PS32 remote
//--   PS32REMOTERF = PS32 RF
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
         item_str := parse(1,memo1.Lines.Strings[i]);

         if item_str = model_number then
           begin
             //-- get the 2nd item in the row
             result := parse(2,memo1.Lines.Strings[i]);
             exit;
           end;
       end;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function TConfiguration.Init_Configuration:boolean;
begin
     memo1.clear;
     
     if FileExists('Valid_models.dat') then
       begin
          memo1.Lines.LoadFromFile('Valid_models.dat');
          result := true;
       end
     else
       begin
          result := false;
       end;

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
         
         if response = MrYes then memo1.Lines.SaveToFile('Valid_models.dat')
         else if response = MrCancel then exit;
       end;

     Close;
end;

//------------------------------------------------------------------------------
//-- Save button.
//------------------------------------------------------------------------------
procedure TConfiguration.Button1Click(Sender: TObject);
begin
     if memo1.Modified then
       begin
         memo1.Lines.SaveToFile('Valid_models.dat');
         memo1.Modified := false;
       end;
end;

//------------------------------------------------------------------------------
//-- Returns the ith item from a string.
//------------------------------------------------------------------------------
function TConfiguration.parse(i:integer;tstr:string):string;
Var
   x,n : integer;
   astr : string;
begin
     x := 1;
     n := 1;
     result := '';
     astr   := '';
     
     //-- remove any leading white space.
     tstr := trimleft(tstr);

     //-- scan until we reach the next space or EOL and build the parsed string item.
     while x <= length(tstr) do
       begin
         if tstr[x] <> ' ' then
           begin
             astr := astr + tstr[x];
             inc(x);
           end
         else
           begin

             //-- if this is the item we want the exit, Else get the next item.
             if i=n then
               begin
                 result := astr;
                 exit;
               end
             else
               begin
                 //-- scan until we get to the next non-blank character.
                 repeat
                   inc(x);
                 until (x=length(tstr)) or (tstr[x] <> ' ');

                 inc(n);
                 astr := '';
               end;
           end;

       end;

     if i=n then result := astr;
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
         item_str := parse(1,memo1.Lines.Strings[i]);

         if item_str = temp_str then
           begin
             result := true;
             exit;
           end;
       end;
end;


end.
