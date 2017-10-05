program controlpadFT_newver_may2015;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit4 in 'Unit4.pas' {Configuration},
  Unit5 in 'Unit5.pas' {usenamepassword},
  Unit2 in 'Unit2.pas' {Verify},
  Unit3 in 'Unit3.pas' {barcode},
  LCDverify in 'LCDverify.pas' {LCDverifyDlg},
  dbunit in 'dbunit.pas' {dbinterface};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TConfiguration, Configuration);
  Application.CreateForm(Tusenamepassword, usenamepassword);
  Application.CreateForm(TVerify, Verify);
  Application.CreateForm(Tbarcode, barcode);
  Application.CreateForm(TLCDverifyDlg, LCDverifyDlg);
  Application.CreateForm(Tdbinterface, dbinterface);
  Application.Run;
end.
