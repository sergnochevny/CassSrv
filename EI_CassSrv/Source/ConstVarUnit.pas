unit ConstVarUnit;

interface
uses
    Classes;

resourcestring
    ErDatSetCreate  = 'Error Dataset %s creating';
    Error           = 'Error';
    RemovedGoodsMsg = '�������� �� �������������������� ������';
    FormatMsg       = '-- %s '+#$0d+#$0a+'%s';
    GeneralPriceMsg = '      ����e����:        %0:d;'+#$0d+#$0a+
                      '      ������������:  %1:s;'+#$0d+#$0a+
                      '      ����:                  %3:m;';
    GeneralMsg      = '      ����e����:        %0:d;'+#$0d+#$0a+
                      '      ������������:  %1:s;'+#$0d+#$0a+
                      '      ����������:       %2:f;';
    GeneralSyncMsg  = '      ����e����:        %0:d;'+#$0d+#$0a+
                      '      ������������:  %1:s;';
    WrongLengthMsg  = '���������� ����� ���������� ����:'+#$0d+#$0a+
                      '      ��������� ���: %4:d;';
    CodeExistsMsg   = '����� � ����� ����� ��� ���������� � ���� - �������� ���:'+#$0d+#$0a+
                      '      ��������� ���: %4:d;';
    CodeSyExistsMsg = '����� � ����� ����� ��� ���������� � ����'+#$0d+#$0a+
                      '      ������������� �� ������ ����������� �� �����:'+#$0d+#$0a+
                      '      ��������� ���: %2:d;';
    WrongCountMsg   = '��������� �������� � ����������';
    WrongPriceMsg   = '��������� �������� � ����';
    WrongTransform  = '������ ��� ��������� ������';
    WrongSync       = '������ ��� ������������� ������';
    WrongTransFile  = '������ ��� ��������� ������. ����� �����������:'+#$0d+#$0a+
                      '��������� ������� �������� ����� ����� ��������'+#$0d+#$0a+
                      '� ��������� ������ � �������� �������.';
    ChangedCodeMsg  = '��� ��������� ������ ���������� �� ����������:'+#$0d+#$0a+
                      '      ��� � �������� �������: %5:d;'+#$0d+#$0a+
                      '      ������������ ���: %4:d;';
    ChangeCodeOkMsg = '������� ��� ������ � �������� �������:'+#$0d+#$0a+
                      '      ���: %5:d;'+#$0d+#$0a+
                      '      ����: %4:d;';
    WrongTransGood  = '������ ��� �������� � �������� ������ ������ ������:'+#$0d+#$0a+
                      '      ��������� ���: %4:d;';
    WrongTransPrice = '������ ��� �������� � �������� ������ ������ ���� ������:'+#$0d+#$0a+
                      '      ��������� ���: %4:d;';
    WrongTransChanges = '������ ��� ����������� ���������� � �������� ������� ������ ������:'+#$0d+#$0a+
                      '      ��������� ���: %4:d;';
    WrongSyncGood   = '������ ��� �������� � �������� ������ ������ ������:'+#$0d+#$0a+
                      '      ��������� ���: %2:d;';
    SyncNotGood     = '� ���� ��������� ������� ������ � ������ ���:'+#$0d+#$0a+
                      '      ��������� ���: %2:d;';
    TransChangesMsg = '���������������� ��������� ������� �����������:   %d.';
    TransPricesMsg  = '����������� ��� ������� �����������:   %d.';
    WrongTransPrices= '���� �� �����������!!!';
    WrongTransGoods = '������ � �������� ������ �� ����������!!!';
    WrongSyncGoods  = '������ ������������� � �������� ������ �� ����������!!!';
    ResultMsg       = ''+#$0d+#$0a+'���������� ������� ��� ������� '+
                      '� �������� ������:       %d ;'+#$0d+#$0a+
                      '���������� ������� ������ ������������� � �������� ������:  %d.';
    ResultSyncMsg   = ''+#$0d+#$0a+'���������� ������� ������ ��� C������������ '+
                      '� �������� ������:       %d ;'+#$0d+#$0a+
                      '���������� ������� ������ C������������������ � �������� ������:  %d.';
    ErrorCaption    = '������';
    WarningCaption  = '��������!!!';
    DiffersCodeMsg  = '��������� ������ ��� ��������� ����-���� %s ��� ������ %s :'+#$0d+#$0a+
                      '� ���� ������� ����� �� �����-��� ������������� ������� ������.'+#$0d+#$0a+
                      '������� �������������� ����-����?';
    BCErrInstMsg    = '������ ��������� �����-����.';
    BCFormatMsg     = '-- %s '+#$0d+#$0a+'%s';
    BCGeneralMsg    = '      ���:                     %0:d;'+#$0d+#$0a+
                      '      ������������:  %1:s;'+#$0d+#$0a+
                      '      �����-���:          %2:s;'+#$0d+#$0a+
                      '      �������:            %3:f;';
    BCErrGoodMsg    = '������ ��������� �����-���� ��� ��������� ������:';
    BCGenErrMsg     = '������ ��������� ������� �����-�����:'+#$0d+#$0a+
                      '      �������� �����-���� � ���� �� �������.';
    BCRefusMsg      = '����� �� ���������� �����-���� ��� ������:';
    NoBCExistsMsg   = '���������� � �����-����� �����������';
    InDocExistsMsg  = '��������� ���� �������� ��� �������� (���������)'+#$0d+#$0a+
                      '� �������� ������ %s %s.'+#$0d+#$0a+
                      '��������� ��������� ����� �������� � �����������������'+#$0d+#$0a+
                      '���������� ���������� ��� ���������� ������.'+#$0d+#$0a+
                      '                               '+#$0d+#$0a+
                      '���������� ��������� ���������?';
    RefusDocMsg     = '����� �� ��������� ���������.';
    ErrHandlHeadMsg = '������ ��� ��������� ��������� ���������.'+#$0d+#$0a+
                      '�������� �� ���������, ���������� ��������� ��������.';
    RetreatDocMsg   = '��������� ��������� ���������.';
    OutDocExistsMsg = '������ �� ��������� ���� ���� ��������� � ���� %s %s.'+#$0d+#$0a+
                      '��������� ��������� ����� �������� � �����������������'+#$0d+#$0a+
                      '���������� ���������� ��� ���������� ������.'+#$0d+#$0a+
                      '                               '+#$0d+#$0a+
                      '���������� ��������� ���������?';
    OutDFormatMsg   = '-- %s '+#$0d+#$0a+'%s';
    OutDGeneralMsg  = '      ��� � ���� ��������� �������:       %0:d;';
    NotIncrMtuMsg   = '��������������� ���� ��������� ������� � �������� �����:'+#$0d+#$0a+
                      '      ��� ���������� � ��������������� ������ � ���� ������';
    RSubKey         = 'Software\��������\EIDukat';
    RClass          = '';
    NameVal         = 'journalize';
    JournalName     = 'journal.txt';
    ErrHandSalesMsg = '������ ��� ������������� ������ � ��������.'+#$0d+#$0a+
                      '�������� �� ���������, ���������� ��������� ��������.';
    FormatHeader    = 'TCI';
    ExportIndent    = 'TCE';
    ResCountRecMsg  = '���������� ������� ������ ���������������� � ��������� �������:  %d.';
    NotDataMsg      = '������ ��� ������� �� ����������.';
    CorFileFrmtMsg  = '�������� ������ ������. ������ �� ����������, ��������� ��������.';
    IntErrRoutnMsg  = '���������� ������ ��������� ������:'+#$0d+#$0a+
                      '      %s';

const
    US                  = $1f;
    RS                  = $1e;
    GS                  = $1d;
    FS                  = $1c;

    __PathDelimiter = '\';
    DefImpFileName  = 'Imp.dat';
    DefExpFileName  = 'Exp.dat';
    DefSyncFileName = 'Sync.dat';
    SQLFileName     = 'Sells.sql';
    PSQLFileName    = 'Prepare.sql';
    PosSQLFileName  = 'PostQuery.sql';
    ImpFileNameK    = 'ImpFileName';
    ExpFileNameK    = 'ExpFileName';
    SyncFileNameK   = 'SyncFileName';
    PathBasaK       = 'PathBasa';
    TokenLogK       = 'TokenLog';
    TokenWriteWOSnK = 'TokenWriteWOSync';
    DVerK           = 'DVer';
    ChngCodeK       = 'ChngCode';
    WDepK           = 'WDep';
    TDebugK         = 'Debug';
    PackK           = 'Pack';
    ShowProgrK      = 'ShowProgress';
    DelFK           = 'DelF';
    SectionCommon   = 'COMMON';
    SectionFiles    = 'FILES';
    SectionTokens   = 'TOKENS';
    SectionDB       = 'DB';
    LogFileName     = 'EICassSrv.log';
    PathDelimiter   = '\';
    CheckFileName   = '\MTU.db';

//Table names
    GoodsTableName  = 'Goods';
    PricesTableName = 'Prices';
    MTUTableName    = 'MTU';
    PacksTableName  = 'Packs';
    InDocTableName  = 'InDocList';
    OutDocTableName = 'OutDocList';

    LenLocCode          = 6;
    LenShortName        = 14;
    LenName             = 40;

    OffsetBarCode       = 0;
    OffsetScale         = 1;
    StepParsingBC       = 2;

    Str_Delimiter       = ';';
    Null_Str            = '';
    BegMemSize          = LongWord($10000);
    MinMemSize          = LongWord($8000);

    RKey                = LongWord($80000001);  // HKEY_CURRENT_USER
    dwROptions          = ($00000000);          // REG_OPTION_NON_VOLATILE
    rOpen               = ($00000002);          // REG_OPENED_EXISTING_KEY
    rCreate             = ($00000001);          // REG_CREATED_NEW_KEY

    HEAP_ZERO_MEMORY    = ($00000008);
    HEAP_NO_SERIALIZE   = ($00000001);
    LenIniStr           :LongWORD   = 300;
    DefTokenLog         = 0;
    DefTokenWriteWOSn   = 0;
    DefDVer             = 6;
    DefChngCode         = 0;
    DefWDep             = 1;
    DefTDebug           = 0;
    DefPack             = 0;
    DefDelF             = 1;
    DefShowProgr        = 0;
    TokenLogWrite       = 1;
    TokenLogShow        = 2;

var
    InitialAmountGoods: Longint     = 0;
    Interm_Handle:      Integer     = 0;
    TempHandle:         Integer     = 0;
    InfMem:             TStrings    = nil;
    Journalize:         Boolean     = false;
    Journal:            TStrings    = nil;
    RecWriteCount:      Cardinal    = 0;

    ImpFileName,
    ExpFileName,
    SyncFileName,
    sDatabaseName:      String;
    sDBName:            String;
    TokenWriteWOSn:     Cardinal    = 0;
    TokenLog:           Cardinal    = 0;
    DVer:               Cardinal;
    ChngCode:           Cardinal;
    WDep:               Cardinal;
    TDebug:             Cardinal;
    Pack:               Cardinal;
    DelF:               Cardinal;
    ShowProgr:          Cardinal;
    TokenHandle:        Boolean     = false;
    RegIniFileName:     String;  
    SQLFile:            String; 
       

const
    RegIniFileNameC = 'EICassSrv.ini';

implementation

end.
