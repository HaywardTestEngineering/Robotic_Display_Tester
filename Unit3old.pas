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
    procedure FormShow(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Get_Serial_Number:string;
    function Get_Model_Number:string;
  end;

var
  barcode: Tbarcode;
  serial_number : string;
  model_number  : string;


implementation

{$R *.DFM}

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
     serial_number := '';
     model_number  := '';

     Edit1.SetFocus;
end;

procedure Tbarcode.Edit2Exit(Sender: TObject);
begin
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure Tbarcode.OKBtnClick(Sender: TObject);
begin
     model_number  := Edit1.text;
     serial_number := Edit2.text;
     modalresult   := mrOK;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure Tbarcode.CancelBtnClick(Sender: TObject);
begin
     Edit1.Text    := '';
     Edit2.Text    := '';
     serial_number := '';
     model_number  := '';
end;

end.
