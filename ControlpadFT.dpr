program ControlpadFT;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Verify},
  Unit3 in 'Unit3.pas' {barcode},
  Unit4 in 'Unit4.pas' {Configuration},
  Unit5 in 'Unit5.pas' {usenamepassword},
  LCDverify in 'LCDverify.pas' {LCDverifyDlg};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TVerify, Verify);
  Application.CreateForm(Tbarcode, barcode);
  Application.CreateForm(TConfiguration, Configuration);
  Application.CreateForm(TLCDverifyDlg, LCDverifyDlg);
//  Application.CreateForm(TForm1, Form1);
//  Application.CreateForm(TVerify, Verify);
  Application.CreateForm(Tbarcode, barcode);
//  Application.CreateForm(TConfiguration, Configuration);
  Application.CreateForm(Tusenamepassword, usenamepassword);
  Application.Run;
end.
