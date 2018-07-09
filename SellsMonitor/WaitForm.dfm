object Wait: TWait
  Left = 591
  Top = 264
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Ожидайте...'
  ClientHeight = 65
  ClientWidth = 259
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pWait: TPanel
    Left = 0
    Top = 0
    Width = 259
    Height = 65
    Align = alClient
    BevelInner = bvLowered
    Caption = 'Обработка запроса.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
end
