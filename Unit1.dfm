object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'bu'
  ClientHeight = 435
  ClientWidth = 546
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
  object Label1: TLabel
    Left = 8
    Top = 414
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Connect: TButton
    Left = 463
    Top = 0
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = ConnectClick
  end
  object FileListBox1: TFileListBox
    Left = 0
    Top = 0
    Width = 457
    Height = 409
    ItemHeight = 13
    TabOrder = 1
    OnClick = FileListBox1Click
  end
  object Button1: TButton
    Left = 463
    Top = 31
    Width = 75
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 463
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Download'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 387
    Width = 433
    Height = 21
    TabOrder = 4
    Text = 'Edit1'
  end
  object Button3: TButton
    Left = 463
    Top = 151
    Width = 75
    Height = 25
    Caption = 'Upload'
    TabOrder = 5
    OnClick = Button3Click
  end
  object ProgressBar1: TProgressBar
    Left = 16
    Top = 352
    Width = 473
    Height = 17
    TabOrder = 6
  end
  object IdFTP: TIdFTP
    IPVersion = Id_IPv4
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 80
    Top = 24
  end
end
