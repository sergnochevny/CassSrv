object ProgressF: TProgressF
  Left = 612
  Top = 289
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Передача данных'
  ClientHeight = 72
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlM: TPanel
    Left = 0
    Top = 0
    Width = 329
    Height = 72
    Align = alClient
    AutoSize = True
    BevelInner = bvLowered
    TabOrder = 0
    object lblMain: TLabel
      Left = 8
      Top = 16
      Width = 3
      Height = 16
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object pbMain: TProgressBar
      Left = 7
      Top = 40
      Width = 316
      Height = 25
      Min = 0
      Max = 100
      Step = 1
      TabOrder = 0
    end
  end
end
