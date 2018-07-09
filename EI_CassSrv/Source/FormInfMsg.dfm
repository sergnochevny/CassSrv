object FormMsg: TFormMsg
  Left = 425
  Top = 69
  BorderStyle = bsDialog
  Caption = 'Информация процесса обработки данных'
  ClientHeight = 359
  ClientWidth = 591
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object C_Panel: TPanel
    Left = 0
    Top = 0
    Width = 591
    Height = 324
    Align = alClient
    TabOrder = 0
    object ErrorMemo: TMemo
      Left = 1
      Top = 1
      Width = 589
      Height = 322
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ReadOnly = True
      ScrollBars = ssVertical
      ShowHint = False
      TabOrder = 0
    end
  end
  object Bott_Panel: TPanel
    Left = 0
    Top = 324
    Width = 591
    Height = 35
    Align = alBottom
    TabOrder = 1
    object SaveB: TSpeedButton
      Left = 3
      Top = 3
      Width = 69
      Height = 29
      Caption = '&Save'
      Flat = True
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333330070
        7700333333337777777733333333008088003333333377F73377333333330088
        88003333333377FFFF7733333333000000003FFFFFFF77777777000000000000
        000077777777777777770FFFFFFF0FFFFFF07F3333337F3333370FFFFFFF0FFF
        FFF07F3FF3FF7FFFFFF70F00F0080CCC9CC07F773773777777770FFFFFFFF039
        99337F3FFFF3F7F777F30F0000F0F09999937F7777373777777F0FFFFFFFF999
        99997F3FF3FFF77777770F00F000003999337F773777773777F30FFFF0FF0339
        99337F3FF7F3733777F30F08F0F0337999337F7737F73F7777330FFFF0039999
        93337FFFF7737777733300000033333333337777773333333333}
      NumGlyphs = 2
      OnClick = SaveBClick
    end
  end
  object SaveLog: TSaveDialog
    DefaultExt = 'log'
    Filter = 'Файлы журнала обработки *.log|*.log'
    Left = 280
    Top = 140
  end
end
