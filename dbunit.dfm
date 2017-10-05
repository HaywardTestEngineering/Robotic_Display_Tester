object dbinterface: Tdbinterface
  Left = 329
  Top = 95
  Caption = 'db interface'
  ClientHeight = 561
  ClientWidth = 758
  Color = clCream
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    758
    561)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 48
    Top = 8
    Width = 53
    Height = 13
    Caption = 'Usernames'
  end
  object Label2: TLabel
    Left = 8
    Top = 264
    Width = 87
    Height = 13
    Caption = 'Query results table'
  end
  object Label4: TLabel
    Left = 360
    Top = 8
    Width = 46
    Height = 13
    Caption = 'Keywords'
  end
  object DBText1: TDBText
    Left = 368
    Top = 200
    Width = 193
    Height = 17
    Color = clMoneyGreen
    DataField = 'keyword'
    ParentColor = False
  end
  object Label5: TLabel
    Left = 368
    Top = 232
    Width = 41
    Height = 13
    Caption = 'symptom'
  end
  object Label3: TLabel
    Left = 176
    Top = 8
    Width = 32
    Height = 13
    Caption = 'Tables'
  end
  object Label6: TLabel
    Left = 568
    Top = 8
    Width = 55
    Height = 13
    Caption = 'Activity Log'
  end
  object Label7: TLabel
    Left = 176
    Top = 208
    Width = 61
    Height = 13
    Caption = 'Process step'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 542
    Width = 758
    Height = 19
    Panels = <>
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 24
    Width = 161
    Height = 105
    DataSource = DataSource1
    FixedColor = clCream
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object DBGrid2: TDBGrid
    Left = 8
    Top = 280
    Width = 745
    Height = 179
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource2
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 8
    Top = 466
    Width = 81
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'SQL Submit'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 96
    Top = 466
    Width = 657
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 4
  end
  object ListBox1: TListBox
    Left = 176
    Top = 24
    Width = 177
    Height = 169
    ItemHeight = 13
    TabOrder = 5
  end
  object DBGrid3: TDBGrid
    Left = 360
    Top = 24
    Width = 201
    Height = 169
    FixedColor = clCream
    TabOrder = 6
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Memo1: TMemo
    Left = 568
    Top = 24
    Width = 185
    Height = 225
    Anchors = [akLeft, akTop, akRight]
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 7
  end
  object Edit3: TEdit
    Left = 416
    Top = 232
    Width = 121
    Height = 21
    AutoSize = False
    CharCase = ecUpperCase
    TabOrder = 8
  end
  object ComboBox1: TComboBox
    Left = 176
    Top = 224
    Width = 145
    Height = 21
    TabOrder = 9
  end
  object Button2: TButton
    Left = 8
    Top = 490
    Width = 81
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Get data for sn'
    TabOrder = 10
    OnClick = Button2Click
  end
  object Edit2: TEdit
    Left = 96
    Top = 488
    Width = 137
    Height = 21
    Anchors = [akLeft, akBottom]
    AutoSize = False
    TabOrder = 11
  end
  object MainMenu1: TMainMenu
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
      object exit1: TMenuItem
        Caption = 'exit'
        OnClick = exit1Click
      end
      object Upload1: TMenuItem
        Caption = 'Upload'
        Enabled = False
        OnClick = Upload1Click
      end
    end
  end
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=dilbert;Persist Security Info=True;' +
      'User ID=testdept;Initial Catalog=quality;Data Source=GLSQL;Use P' +
      'rocedure for Prepare=1;Auto Translate=True;Packet Size=4096;Work' +
      'station ID=RUSSB;Use Encryption for Data=False;Tag with column c' +
      'ollation when possible=False'
    KeepConnection = False
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    OnConnectComplete = ADOConnection1ConnectComplete
    Top = 40
  end
  object DataSource1: TDataSource
    DataSet = ADODataSet1
    Top = 104
  end
  object DataSource2: TDataSource
    DataSet = ADOQuery1
    Left = 8
    Top = 328
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    Left = 8
    Top = 360
  end
  object DataSource3: TDataSource
    Left = 360
    Top = 112
  end
  object ADODataSet2: TADODataSet
    Connection = ADOConnection1
    CursorType = ctStatic
    CommandText = 'select max(Id) from Keywords'
    Parameters = <>
    Left = 392
    Top = 80
  end
  object ADOQuery2: TADOQuery
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    Left = 360
    Top = 80
  end
  object ADODataSet1: TADODataSet
    Connection = ADOConnection1
    CursorType = ctStatic
    CommandText = 
      'select name,password from sysusers '#13#10'where status='#39'2'#39' and name <' +
      '> '#39'testdept'#39
    Parameters = <>
    Top = 72
  end
end
