object fListProtocol: TfListProtocol
  Left = 141
  Top = 175
  ActiveControl = dgProtocol
  BorderStyle = bsToolWindow
  Caption = 'Протокол'
  ClientHeight = 347
  ClientWidth = 875
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
  object StatusBar1: TStatusBar
    Left = 0
    Top = 328
    Width = 875
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object dgProtocol: TRxDBGrid
    Left = 0
    Top = 0
    Width = 875
    Height = 328
    Align = alClient
    DataSource = dsProtocol
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnGetCellParams = dgProtocolGetCellParams
  end
  object rmdProtocol: TRxMemoryData
    FieldDefs = <>
    Left = 184
    Top = 16
  end
  object dsProtocol: TvDataSource
    DataSet = rmdProtocol
    Left = 112
    Top = 16
  end
end
