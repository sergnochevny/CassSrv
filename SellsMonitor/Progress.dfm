object fProgress: TfProgress
  Left = 323
  Top = 322
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Выполняется поиск в протоколе...'
  ClientHeight = 23
  ClientWidth = 478
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 478
    Height = 23
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    object pbSearch: TProgressBar
      Left = 5
      Top = 4
      Width = 468
      Height = 15
      Min = 0
      Max = 100
      TabOrder = 0
    end
  end
end
