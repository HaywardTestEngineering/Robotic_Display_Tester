unit Unit3;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  Tbarcode = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit3: TEdit;
    procedure FormShow(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit2Enter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Set_Display_Type(DT:integer);
    function Get_Serial_Number:string;
    function Get_Model_Number:string;
    function Get_Barcode_Scan:string;
  end;

var
  barcode: Tbarcode;
  serial_number : string;
  model_number  : string;
  barcode_Scan  : string;
  Display_Type  : integer;

implementation

{$R *.DFM}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure Tbarcode.Set_Display_Type(DT:integer);
begin
     if DT in [1..2] then
       Display_Type := DT
     else
       Display_Type := 2;

end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
function Tbarcode.Get_Barcode_Scan:string;
begin
     result := barcode_Scan;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
function Tbarcode.Get_Serial_Number:string;
begin
     result := serial_number;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
function Tbarcode.Get_Model_Number:string;
begin
     result := Model_number;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure Tbarcode.FormShow(Sender: TObject);
begin
     Edit1.Text    := '';
     Edit2.Text    := '';
     Edit3.Text    := '';
     serial_number := '';
     model_number  := '';
     barcode_Scan  := '';
     
     case Display_Type of
       1 : begin
             Label3.Visible := true;
             Edit3.Visible  := true;
             Edit3.SetFocus;

             Label1.Visible := false;
             Edit1.Visible  := false;
             Label2.Visible := false;
             Edit2.Visible  := false;
           end;
       2 : begin
             Label3.Visible := false;
             Edit3.Visible  := false;
             
             Label2.Visible := true;
             Edit2.Visible  := true;

             Label1.Visible := true;
             Edit1.Visible  := true;
             Edit1.SetFocus;
           end;
     end;

     
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure Tbarcode.Edit2Exit(Sender: TObject);
begin
end;

//-----------------------------------------------------------------------------
//-- This is a modified parse routine.
//-- It is different than parse routines used elsewhere.
//-- If x=1, only the 1st item is returned.
//-- If x=2, everything after the 1st item is returned.
//-----------------------------------------------------------------------------
function parse(txt:string;x:integer):string;
Var
   i : Integer;
   temp_str : string;
begin
     result   := '';
     temp_str := '';
     i        := 0;

     if x = 1 then
       begin
         //-- Get the 1st item from the txt string.
         if length(txt)>0 then
           begin
             while (i < length(txt)) do
               begin
                 inc(i);
                 if txt[i]<>' ' then temp_str := temp_str + txt[i]
                 else
                  begin
                    result := temp_str;
                    exit;
                  end;
               end;
           end;
       end

     else if x = 2 then
       begin
         //-- Get everything after the 1st item i txt string.
         if length(txt)>0 then
           begin
             i := 1;
             while (i <= length(txt)) do
               begin
                 if txt[i]<>' ' then inc(i)
                 else
                   begin
                     result := copy(txt,i+1,length(txt)-i);
                     exit;
                   end;
               end;
           end;

       end;
end;
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure Tbarcode.OKBtnClick(Sender: TObject);
begin
     case Display_Type of
       1 : begin
             Barcode_Scan  := Edit3.text;

             model_number  := parse(Barcode_Scan,1);
             serial_number := parse(Barcode_Scan,2);
           end;
       2 : begin
             model_number  := Edit1.text;
             serial_number := Edit2.text;
             Barcode_Scan  := '';
           end;
     end;
     modalresult   := mrOK;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure Tbarcode.CancelBtnClick(Sender: TObject);
begin
     Edit1.Text    := '';
     Edit2.Text    := '';
     Edit3.Text    := '';
     serial_number := '';
     model_number  := '';
     Barcode_Scan  := '';
end;

//-----------------------------------------------------------------------------
//-- Display_Type = 1
//--     Displays a single barcode scan Edit field
//--
//-- Display_Type = 2
//--     Displays 2 barcode scan Edit fields
//--     'Model#'
//--     'Serial#'
//-----------------------------------------------------------------------------
procedure Tbarcode.FormCreate(Sender: TObject);
begin
     Display_Type := 2;
end;


//-----------------------------------------------------------------------------
//-- If the first 3 characters of the model# are 'AQL' then we need to allow the
//-- operator to scan in the serial#.  If it's not 'AQL', then the operator
//-- must have scanned in a single model-serial number barcode scan such as
//-- '018005A-1 1234 56789'.  Exit if this is the case.
//-----------------------------------------------------------------------------
procedure Tbarcode.Edit2Enter(Sender: TObject);
begin
     case Display_Type of
       1 : begin
             Barcode_Scan  := Edit3.text;
             model_number  := parse(Barcode_Scan,1);
             serial_number := parse(Barcode_Scan,2);
           end;
       2 : begin
             if length(Edit1.text) > 7 then
               begin
                 if (uppercase(copy(Edit1.text,1,3)) = '018') or
                    (uppercase(copy(Edit1.text,1,4)) = 'G018') or
                    (uppercase(copy(Edit1.text,1,6)) = 'G1-018') then

               //--  if (uppercase(copy(Edit1.text,1,3)) <> 'AQL') and
               //--     (uppercase(copy(Edit1.text,1,3)) <> 'GLX') then
                   begin
                     Barcode_Scan  := Edit1.text;
                     model_number  := parse(Barcode_Scan,1);
                     serial_number := parse(Barcode_Scan,2);
                     modalresult   := mrOK;
                   end;
               end;

           end;
     end;
end;

end.
