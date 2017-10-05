program AquaProCtrlPadFT;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Verify},
  Unit3 in 'Unit3.pas' {barcode},
  Unit4 in 'Unit4.pas' {Configuration},
  Unit5 in 'Unit5.pas' {usenamepassword},
  robotpositionunit in 'robotpositionunit.pas' {robotposition},
  LCDverify in 'LCDverify.pas' {LCDverifyDlg},
  dbunit in 'dbunit.pas' {dbinterface},
  Unit7 in 'Unit7.pas' {Form7};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TVerify, Verify);
  Application.CreateForm(Tbarcode, barcode);
  Application.CreateForm(TConfiguration, Configuration);
  Application.CreateForm(Tusenamepassword, usenamepassword);
  Application.CreateForm(Trobotposition, robotposition);
  Application.CreateForm(TLCDverifyDlg, LCDverifyDlg);
  Application.CreateForm(Tdbinterface, dbinterface);
  Application.CreateForm(Tdbinterface, dbinterface);
  Application.CreateForm(TForm7, Form7);
  Application.Run;
end.
