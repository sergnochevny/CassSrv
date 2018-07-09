object WorkForm: TWorkForm
  Left = 172
  Top = 229
  Width = 852
  Height = 508
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object vPWork: TvPanel
    Left = 0
    Top = 0
    Width = 844
    Height = 201
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 0
    object vPParams: TvPanel
      Left = 2
      Top = 2
      Width = 840
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
      end
    end
    object vPGrid: TvPanel
      Left = 2
      Top = 43
      Width = 840
      Height = 156
      Align = alClient
      BevelInner = bvLowered
      TabOrder = 0
      object dgWork: TRxDBGrid
        Left = 2
        Top = 2
        Width = 836
        Height = 152
        Align = alClient
        DataSource = dsWork
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
        IniStorage = fsWork
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 462
    Width = 844
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object RxSplitter1: TRxSplitter
    Left = 0
    Top = 201
    Width = 844
    Height = 3
    ControlFirst = vPWork
    ControlSecond = vPWorkDetail
    Align = alTop
    BorderStyle = bsSingle
  end
  object vPWorkDetail: TvPanel
    Left = 0
    Top = 204
    Width = 844
    Height = 258
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 3
    object vPGoods: TvPanel
      Left = 2
      Top = 2
      Width = 840
      Height = 24
      Align = alTop
      Alignment = taLeftJustify
      BevelInner = bvLowered
      Caption = '  Товар в чеке'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object vPDetailGrid: TvPanel
      Left = 2
      Top = 26
      Width = 840
      Height = 230
      Align = alClient
      BevelInner = bvLowered
      TabOrder = 0
      object dgWorkDetail: TRxDBGrid
        Left = 2
        Top = 2
        Width = 836
        Height = 226
        Align = alClient
        DataSource = dsWorkDetail
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
        IniStorage = fsWork
      end
    end
  end
  object dsWork: TvDataSource
    Left = 134
    Top = 49
  end
  object dsWorkDetail: TvDataSource
    Left = 138
    Top = 238
  end
  object alFilter: TActionList
    Left = 178
    Top = 49
    object Filter: TAction
      ShortCut = 32781
    end
  end
  object fsWork: TFormStorage
    Active = False
    StoredProps.Strings = (
      'vPWork.Height'
      'vPWorkDetail.Height')
    StoredValues = <>
    Left = 722
    Top = 10
  end
end
