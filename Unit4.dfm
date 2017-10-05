object Configuration: TConfiguration
  Left = 768
  Top = 161
  Caption = 'Configuration Menu'
  ClientHeight = 355
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    480
    355)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 192
    Top = 10
    Width = 59
    Height = 13
    Caption = 'Valid models'
  end
  object Memo1: TMemo
    Left = 192
    Top = 24
    Width = 280
    Height = 252
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitWidth = 254
    ExplicitHeight = 173
  end
  object Button1: TButton
    Left = 192
    Top = 282
    Width = 102
    Height = 48
    Anchors = [akLeft, akBottom]
    Caption = 'Save'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button1Click
    ExplicitTop = 203
  end
  object Button2: TButton
    Left = 295
    Top = 282
    Width = 99
    Height = 48
    Anchors = [akLeft, akBottom]
    Caption = 'Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = Button2Click
    ExplicitTop = 203
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 8
    Width = 89
    Height = 17
    Caption = 'Qdb enabled'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object Displaycomportlist: TComboBox
    Left = 8
    Top = 46
    Width = 73
    Height = 21
    TabOrder = 4
  end
  object robotcomportlist: TComboBox
    Left = 8
    Top = 226
    Width = 73
    Height = 21
    TabOrder = 5
  end
  object GenIbasecomportlist: TComboBox
    Left = 8
    Top = 134
    Width = 73
    Height = 21
    TabOrder = 6
  end
  object GenIIbasecomportlist: TComboBox
    Left = 8
    Top = 180
    Width = 73
    Height = 21
    TabOrder = 7
  end
  object Displayprogcomportlist: TComboBox
    Left = 8
    Top = 92
    Width = 73
    Height = 21
    TabOrder = 8
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 336
    Width = 480
    Height = 19
    Panels = <>
    ExplicitTop = 257
    ExplicitWidth = 454
  end
  object DisplayComport: TCheckBox
    Left = 8
    Top = 29
    Width = 145
    Height = 17
    Caption = 'Display Comport Enabled'
    TabOrder = 10
  end
  object DisplayProgComport: TCheckBox
    Left = 8
    Top = 75
    Width = 169
    Height = 17
    Caption = 'Display Prog Comport Enabled'
    TabOrder = 11
  end
  object GenIbaseComport: TCheckBox
    Left = 8
    Top = 117
    Width = 169
    Height = 17
    Caption = 'Gen I base Comport Enabled'
    TabOrder = 12
  end
  object GenIIbaseComport: TCheckBox
    Left = 8
    Top = 162
    Width = 161
    Height = 17
    Caption = 'Gen II base Comport Enabled'
    TabOrder = 13
  end
  object RobotComport: TCheckBox
    Left = 8
    Top = 209
    Width = 137
    Height = 17
    Caption = 'Robot Comport Enabled'
    TabOrder = 14
  end
  object homerobotbeforetest: TCheckBox
    Left = 8
    Top = 256
    Width = 161
    Height = 17
    Caption = 'Home robot before LCD Test'
    TabOrder = 15
  end
  object VaComm1: TVaComm
    FlowControl.OutCtsFlow = False
    FlowControl.OutDsrFlow = False
    FlowControl.ControlDtr = dtrDisabled
    FlowControl.ControlRts = rtsDisabled
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    FlowControl.DsrSensitivity = False
    FlowControl.TxContinueOnXoff = False
    DeviceName = 'COM%d'
    Version = '1.9.4.2'
    Left = 264
    Top = 88
  end
end
