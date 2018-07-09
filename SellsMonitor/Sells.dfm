object SellsForm: TSellsForm
  Left = 1028
  Top = 859
  BorderStyle = bsToolWindow
  Caption = 'Выторг за день'
  ClientHeight = 42
  ClientWidth = 244
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object vPSumm: TvPanel
    Left = 0
    Top = 0
    Width = 244
    Height = 42
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    object lSum: TLabel
      Left = 6
      Top = 3
      Width = 233
      Height = 37
      Alignment = taCenter
      AutoSize = False
      Caption = 'lSum'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
  end
  object fsSales: TFormStorage
    IniFileName = 'SellsMonitor'
    IniSection = 'F_SALES'
    StoredValues = <>
    Left = 32
  end
end
