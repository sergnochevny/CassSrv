object DukatDM: TDukatDM
  OldCreateOrder = False
  Left = 193
  Top = 138
  Height = 480
  Width = 696
  object Dukat: TvIBDataBase
    Connected = True
    DatabaseName = 
      '127.0.0.1:F:\Program Files\Delphi5\Projects\EI_Dukat_WD_IB\Insta' +
      'llDukat\Дукат\Data\MVENGINE.GDB'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey')
    LoginPrompt = False
    DefaultTransaction = DefTrans
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 24
    Top = 16
  end
  object DefTrans: TvIBTransaction
    Active = True
    DefaultDatabase = Dukat
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 72
    Top = 16
  end
  object vIBStoredProc1: TvIBStoredProc
    Database = Dukat
    Transaction = DefTrans
    StoredProcName = 'ADD_BARCODE'
    Params = <
      item
        DataType = ftInteger
        Name = 'RES'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'IMTU'
        ParamType = ptInput
      end
      item
        DataType = ftString
        Name = 'BARCODE'
        ParamType = ptInput
      end
      item
        DataType = ftFloat
        Name = 'ZOOM'
        ParamType = ptInput
      end
      item
        DataType = ftInteger
        Name = 'CHANGE'
        ParamType = ptInput
      end>
    Left = 72
    Top = 72
    ParamData = <
      item
        DataType = ftInteger
        Name = 'RES'
        ParamType = ptOutput
      end
      item
        DataType = ftInteger
        Name = 'IMTU'
        ParamType = ptInput
      end
      item
        DataType = ftString
        Name = 'BARCODE'
        ParamType = ptInput
      end
      item
        DataType = ftFloat
        Name = 'ZOOM'
        ParamType = ptInput
      end
      item
        DataType = ftInteger
        Name = 'CHANGE'
        ParamType = ptInput
      end>
  end
  object vIBDataSet1: TvIBDataSet
    Database = Dukat
    Transaction = DefTrans
    BufferChunks = 1000
    CachedUpdates = False
    RequestLive = False
    Left = 24
    Top = 128
  end
  object IBDataSet1: TIBDataSet
    Database = Dukat
    Transaction = DefTrans
    BufferChunks = 1000
    CachedUpdates = False
    Left = 88
    Top = 136
  end
end
