object SoldGoodsForm: TSoldGoodsForm
  Left = 278
  Top = 95
  Width = 624
  Height = 508
  Caption = 'Проданный товар'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object vPSoldGoods: TvPanel
    Left = 0
    Top = 0
    Width = 616
    Height = 462
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    object vPParams: TvPanel
      Left = 2
      Top = 2
      Width = 612
      Height = 41
      Align = alTop
      BevelInner = bvLowered
      TabOrder = 1
      object Label1: TLabel
        Left = 8
        Top = 13
        Width = 87
        Height = 16
        Caption = 'За период:   с'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 228
        Top = 13
        Width = 16
        Height = 16
        Caption = 'по'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object dtpBegin: TDateTimePicker
        Left = 114
        Top = 9
        Width = 100
        Height = 24
        CalAlignment = dtaLeft
        Date = 41776.5495992477
        Time = 41776.5495992477
        DateFormat = dfShort
        DateMode = dmComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Kind = dtkDate
        ParseInput = False
        ParentFont = False
        TabOrder = 0
        OnChange = dtpBeginChange
      end
      object dtpEnd: TDateTimePicker
        Left = 255
        Top = 9
        Width = 100
        Height = 24
        CalAlignment = dtaLeft
        Date = 41776.5517019213
        Time = 41776.5517019213
        DateFormat = dfShort
        DateMode = dmComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Kind = dtkDate
        ParseInput = False
        ParentFont = False
        TabOrder = 1
        OnChange = dtpEndChange
      end
      object bGo: TButton
        Left = 371
        Top = 8
        Width = 105
        Height = 25
        Caption = 'Получить данные'
        TabOrder = 2
        OnClick = bGoClick
      end
    end
    object vPGrid: TvPanel
      Left = 2
      Top = 43
      Width = 612
      Height = 417
      Align = alClient
      BevelInner = bvLowered
      TabOrder = 0
      object dgSoldGoods: TRxDBGrid
        Left = 2
        Top = 2
        Width = 608
        Height = 413
        Align = alClient
        DataSource = dsSoldGoods
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = [fsBold]
        OnDblClick = dgSoldGoodsDblClick
        OnKeyPress = dgSoldGoodsKeyPress
        IniStorage = fsSoldGoods
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 462
    Width = 616
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object fsSoldGoods: TFormStorage
    IniFileName = 'SellsMonitor.ini'
    IniSection = 'F_SOLDGOODS'
    StoredValues = <>
    Left = 472
    Top = 9
  end
  object dsSoldGoods: TvDataSource
    Left = 134
    Top = 49
  end
end
