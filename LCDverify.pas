unit LCDverify;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  TLCDverifyDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LCDverifyDlg: TLCDverifyDlg;

implementation

{$R *.DFM}

procedure TLCDverifyDlg.FormActivate(Sender: TObject);
begin
     OKBtn.SetFocus;
end;

end.
