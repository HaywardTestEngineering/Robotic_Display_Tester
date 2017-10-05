object robotposition: Trobotposition
  Left = 0
  Top = 0
  Caption = 'robotposition'
  ClientHeight = 372
  ClientWidth = 593
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 353
    Width = 593
    Height = 19
    Panels = <>
  end
  object Memo1: TMemo
    Left = 0
    Top = 73
    Width = 593
    Height = 280
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 593
    Height = 73
    Align = alTop
    BevelOuter = bvLowered
    PopupMenu = PopupMenu1
    TabOrder = 2
    object Label1: TLabel
      Left = 269
      Top = 4
      Width = 50
      Height = 13
      Caption = 'New name'
      Visible = False
    end
    object savebtn: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 71
      Align = alLeft
      Caption = 'Save'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = savebtnClick
    end
    object closebtn: TButton
      Left = 76
      Top = 1
      Width = 75
      Height = 71
      Align = alLeft
      Caption = 'Close'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = closebtnClick
    end
    object modelnumber: TComboBox
      Left = 157
      Top = 11
      Width = 100
      Height = 21
      TabOrder = 2
      Text = 'modelnumber'
      OnChange = modelnumberChange
    end
    object newmodeltype: TEdit
      Left = 267
      Top = 17
      Width = 102
      Height = 21
      TabOrder = 3
      Visible = False
    end
    object Button1: TButton
      Left = 375
      Top = 17
      Width = 35
      Height = 21
      Caption = 'Save'
      TabOrder = 4
      Visible = False
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 416
      Top = 17
      Width = 37
      Height = 21
      Caption = 'Cancel'
      TabOrder = 5
      Visible = False
      OnClick = Button2Click
    end
    object homebtn: TButton
      Left = 263
      Top = 9
      Width = 33
      Height = 25
      Caption = 'Home'
      TabOrder = 6
      Visible = False
      OnClick = homebtnClick
    end
    object movebtn: TButton
      Left = 298
      Top = 9
      Width = 33
      Height = 25
      Caption = 'Move'
      TabOrder = 7
      Visible = False
      OnClick = movebtnClick
    end
    object xstr: TEdit
      Left = 334
      Top = 9
      Width = 33
      Height = 21
      TabOrder = 8
      Visible = False
    end
    object ystr: TEdit
      Left = 368
      Top = 9
      Width = 33
      Height = 21
      TabOrder = 9
      Visible = False
    end
    object zstr: TEdit
      Left = 298
      Top = 46
      Width = 33
      Height = 21
      TabOrder = 10
      Visible = False
    end
    object pressbtn: TButton
      Left = 263
      Top = 42
      Width = 33
      Height = 25
      Caption = 'Press'
      TabOrder = 11
      Visible = False
      OnClick = pressbtnClick
    end
    object releasebtn: TButton
      Left = 355
      Top = 43
      Width = 46
      Height = 25
      Caption = 'Release'
      TabOrder = 12
      Visible = False
      OnClick = releasebtnClick
    end
    object pwmonbtn: TButton
      Left = 157
      Top = 43
      Width = 47
      Height = 21
      Caption = 'pwmON'
      TabOrder = 13
      Visible = False
      OnClick = pwmonbtnClick
    end
    object pwmoffbtn: TButton
      Left = 204
      Top = 43
      Width = 47
      Height = 21
      Caption = 'pwmOFF'
      TabOrder = 14
      Visible = False
      OnClick = pwmoffbtnClick
    end
    object jogleftbtn: TButton
      Left = 416
      Top = 25
      Width = 16
      Height = 16
      Caption = '<'
      TabOrder = 15
      Visible = False
      OnClick = jogleftbtnClick
    end
    object jogdownbtn: TButton
      Left = 433
      Top = 42
      Width = 16
      Height = 16
      Caption = 'V'
      TabOrder = 16
      Visible = False
      OnClick = jogdownbtnClick
    end
    object jogrightbtn: TButton
      Left = 449
      Top = 25
      Width = 16
      Height = 16
      Caption = '>'
      TabOrder = 17
      Visible = False
      OnClick = jogrightbtnClick
    end
    object jogupbtn: TButton
      Left = 433
      Top = 9
      Width = 16
      Height = 16
      Caption = '^'
      TabOrder = 18
      Visible = False
      OnClick = jogupbtnClick
    end
    object jogfactor: TRadioGroup
      Left = 471
      Top = 7
      Width = 63
      Height = 57
      Caption = 'Jog factor'
      ItemIndex = 0
      Items.Strings = (
        '0.01'
        '0.1'
        '1.0')
      TabOrder = 19
      Visible = False
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 80
    Top = 128
    object NewTable1: TMenuItem
      Caption = 'New Table'
      OnClick = NewTable1Click
    end
    object DeleteTable1: TMenuItem
      Caption = 'Delete Table'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object RobotControl1: TMenuItem
      Caption = 'Robot Control'
      OnClick = RobotControl1Click
    end
  end
end
