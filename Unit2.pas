unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TVerify = class(TForm)
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Set_Color(Blink_Flag:boolean);
  end;

var
  Verify: TVerify;

implementation

{$R *.DFM}

procedure TVerify.Set_Color(Blink_Flag:boolean);
begin
     if Blink_Flag then
       begin
         StaticText1.Color := clRed;
         StaticText2.Color := clRed;
         StaticText3.Color := clRed;
       end
     else
       begin
         StaticText1.Color := clWhite;
         StaticText2.Color := clWhite;
         StaticText3.Color := clWhite;
      end;
end;

procedure TVerify.Button1Click(Sender: TObject);
begin
     Verify.Close;
end;

end.
