object usenamepassword: Tusenamepassword
  Left = 556
  Top = 105
  Caption = 'Username/Password'
  ClientHeight = 221
  ClientWidth = 290
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
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 40
    Top = 24
    Width = 209
    Height = 125
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 0
    object Label1: TLabel
      Left = 72
      Top = 64
      Width = 46
      Height = 13
      Caption = 'Password'
    end
    object Label2: TLabel
      Left = 72
      Top = 8
      Width = 48
      Height = 13
      Caption = 'Username'
    end
    object Label3: TLabel
      Left = 16
      Top = 112
      Width = 177
      Height = 25
      Alignment = taCenter
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Username: TComboBox
      Left = 32
      Top = 24
      Width = 145
      Height = 21
      TabOrder = 0
    end
    object Password: TEdit
      Left = 32
      Top = 80
      Width = 145
      Height = 21
      AutoSize = False
      PasswordChar = '*'
      TabOrder = 1
    end
  end
  object Button1: TButton
    Left = 40
    Top = 157
    Width = 129
    Height = 52
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 174
    Top = 157
    Width = 75
    Height = 52
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
