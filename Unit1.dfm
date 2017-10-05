object Form1: TForm1
  Left = 499
  Top = 110
  Caption = 'Aqua Logic Control Pad Final Test'
  ClientHeight = 419
  ClientWidth = 398
  Color = clBtnFace
  Constraints.MinHeight = 477
  Constraints.MinWidth = 380
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    398
    419)
  PixelsPerInch = 96
  TextHeight = 13
  object Ver_Label: TLabel
    Left = 317
    Top = 8
    Width = 78
    Height = 17
    Anchors = [akTop, akRight]
    AutoSize = False
    ExplicitLeft = 292
  end
  object Label1: TLabel
    Left = 172
    Top = 372
    Width = 33
    Height = 13
    Anchors = [akBottom]
    AutoSize = False
    ExplicitLeft = 160
    ExplicitTop = 410
  end
  object Label2: TLabel
    Left = 24
    Top = 238
    Width = 344
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = 'Symptom'
    ExplicitTop = 276
    ExplicitWidth = 318
  end
  object Label3: TLabel
    Left = 24
    Top = 187
    Width = 344
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    ExplicitTop = 225
    ExplicitWidth = 318
  end
  object Start: TButton
    Left = 74
    Top = 294
    Width = 248
    Height = 97
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Start'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = StartClick
  end
  object closebtn: TButton
    Left = 335
    Top = 346
    Width = 55
    Height = 48
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 1
    OnClick = closebtnClick
  end
  object Memo1: TMemo
    Left = 23
    Top = 31
    Width = 345
    Height = 140
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Symptom: TStaticText
    Left = 24
    Top = 254
    Width = 344
    Height = 25
    Alignment = taCenter
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    BorderStyle = sbsSunken
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 3
  end
  object Stop: TButton
    Left = 12
    Top = 347
    Width = 49
    Height = 44
    Anchors = [akLeft, akBottom]
    Caption = 'Stop'
    TabOrder = 4
    OnClick = StopClick
  end
  object PassFail: TStaticText
    Left = 24
    Top = 208
    Width = 344
    Height = 25
    Alignment = taCenter
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    BorderStyle = sbsSunken
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 5
  end
  object StaticText1: TStaticText
    Left = 182
    Top = 8
    Width = 31
    Height = 17
    Anchors = [akTop]
    AutoSize = False
    TabOrder = 6
  end
  object Status: TButton
    Left = 8
    Top = 296
    Width = 49
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Status'
    TabOrder = 7
    Visible = False
    OnClick = StatusClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 400
    Width = 398
    Height = 19
    Panels = <>
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 16
    Top = 120
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 8
    object Settings1: TMenuItem
      Caption = 'Settings'
      OnClick = Settings1Click
      object Comport1RS4821: TMenuItem
        Caption = 'Comport1(RS482)'
        OnClick = Comport1RS4821Click
      end
      object Configuration1: TMenuItem
        Caption = 'Configuration'
        OnClick = Configuration1Click
      end
      object Database1: TMenuItem
        Caption = 'Database'
        OnClick = Database1Click
      end
      object Positiontable1: TMenuItem
        Caption = 'Position table'
        OnClick = Positiontable1Click
      end
      object robotOFF1: TMenuItem
        Caption = 'robot OFF'
        OnClick = robotOFF1Click
      end
    end
  end
  object Timer2: TTimer
    Interval = 100
    OnTimer = Timer2Timer
    Left = 16
    Top = 184
  end
  object DisplayComport: TVaComm
    Baudrate = br19200
    FlowControl.OutCtsFlow = False
    FlowControl.OutDsrFlow = False
    FlowControl.ControlDtr = dtrDisabled
    FlowControl.ControlRts = rtsDisabled
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    FlowControl.DsrSensitivity = False
    FlowControl.TxContinueOnXoff = False
    DeviceName = 'COM%d'
    SettingsStore.RegRoot = rrCURRENTUSER
    SettingsStore.Location = slINIFile
    Version = '2.0.3.0'
    Left = 56
    Top = 56
  end
  object DisplayComDataPacket1: TVaCapture
    Comm = DisplayComport
    OnMessage = DisplayComDataPacket1Message
    Active = True
    Left = 200
    Top = 56
  end
  object displayprogcomport: TVaComm
    Baudrate = br19200
    FlowControl.OutCtsFlow = False
    FlowControl.OutDsrFlow = False
    FlowControl.ControlDtr = dtrDisabled
    FlowControl.ControlRts = rtsDisabled
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    FlowControl.DsrSensitivity = False
    FlowControl.TxContinueOnXoff = False
    DeviceName = 'COM%d'
    SettingsStore.RegRoot = rrCURRENTUSER
    SettingsStore.Location = slINIFile
    Version = '2.0.3.0'
    Left = 72
    Top = 192
  end
  object genIbasecomport: TVaComm
    Baudrate = br19200
    FlowControl.OutCtsFlow = False
    FlowControl.OutDsrFlow = False
    FlowControl.ControlDtr = dtrDisabled
    FlowControl.ControlRts = rtsDisabled
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    FlowControl.DsrSensitivity = False
    FlowControl.TxContinueOnXoff = False
    DeviceName = 'COM%d'
    SettingsStore.RegRoot = rrCURRENTUSER
    SettingsStore.Location = slINIFile
    Version = '2.0.3.0'
    Left = 120
    Top = 192
  end
  object genIIbasecomport: TVaComm
    Baudrate = br19200
    FlowControl.OutCtsFlow = False
    FlowControl.OutDsrFlow = False
    FlowControl.ControlDtr = dtrDisabled
    FlowControl.ControlRts = rtsDisabled
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    FlowControl.DsrSensitivity = False
    FlowControl.TxContinueOnXoff = False
    DeviceName = 'COM%d'
    SettingsStore.RegRoot = rrCURRENTUSER
    SettingsStore.Location = slINIFile
    Version = '2.0.3.0'
    Left = 200
    Top = 128
  end
  object robotcomport: TVaComm
    Baudrate = br115200
    FlowControl.OutCtsFlow = False
    FlowControl.OutDsrFlow = False
    FlowControl.ControlDtr = dtrDisabled
    FlowControl.ControlRts = rtsDisabled
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    FlowControl.DsrSensitivity = False
    FlowControl.TxContinueOnXoff = False
    DeviceName = 'COM%d'
    SettingsStore.RegRoot = rrCURRENTUSER
    SettingsStore.Location = slINIFile
    OnRxChar = robotcomportRxChar
    Version = '2.0.3.0'
    Left = 128
    Top = 56
  end
end
