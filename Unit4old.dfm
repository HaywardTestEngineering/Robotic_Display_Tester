object Configuration: TConfiguration
  Left = 827
  Top = 119
  Width = 257
  Height = 347
  Caption = 'Configuration Menu'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 59
    Height = 13
    Caption = 'Valid models'
  end
  object Memo1: TMemo
    Left = 8
    Top = 24
    Width = 233
    Height = 144
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Button1: TButton
    Left = 40
    Top = 279
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Save'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 128
    Top = 279
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Close'
    TabOrder = 2
    OnClick = Button2Click
  end
end
