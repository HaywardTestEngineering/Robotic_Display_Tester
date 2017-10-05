object Verify: TVerify
  Left = 7
  Top = 9
  Width = 462
  Height = 303
  Caption = 'Verify'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StaticText1: TStaticText
    Left = 16
    Top = 8
    Width = 425
    Height = 62
    Alignment = taCenter
    AutoSize = False
    Caption = 'Verify Connectors'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -48
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 0
  end
  object StaticText2: TStaticText
    Left = 16
    Top = 65
    Width = 425
    Height = 64
    Alignment = taCenter
    AutoSize = False
    Caption = 'are placed'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -48
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 1
  end
  object StaticText3: TStaticText
    Left = 16
    Top = 128
    Width = 425
    Height = 62
    Alignment = taCenter
    AutoSize = False
    Caption = 'into TB1 and TB2'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -48
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 2
  end
  object Button1: TButton
    Left = 56
    Top = 200
    Width = 329
    Height = 65
    Caption = 'OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -48
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = Button1Click
  end
end
