unit ConstVarUnit;

interface
uses
    Classes;

resourcestring
    ErDatSetCreate  = 'Error Dataset %s creating';
    Error           = 'Error';
    RemovedGoodsMsg = 'Перечень не запрограммированного товара';
    FormatMsg       = '-- %s '+#$0d+#$0a+'%s';
    GeneralPriceMsg = '      Инкрeмент:        %0:d;'+#$0d+#$0a+
                      '      Наименование:  %1:s;'+#$0d+#$0a+
                      '      Цена:                  %3:m;';
    GeneralMsg      = '      Инкрeмент:        %0:d;'+#$0d+#$0a+
                      '      Наименование:  %1:s;'+#$0d+#$0a+
                      '      Количество:       %2:f;';
    GeneralSyncMsg  = '      Инкрeмент:        %0:d;'+#$0d+#$0a+
                      '      Наименование:  %1:s;';
    WrongLengthMsg  = 'Превышение длины локального кода:'+#$0d+#$0a+
                      '      Локальный код: %4:d;';
    CodeExistsMsg   = 'Товар с таким кодом уже существует в базе - измените код:'+#$0d+#$0a+
                      '      Локальный код: %4:d;';
    CodeSyExistsMsg = 'Товар с таким кодом уже существует в базе'+#$0d+#$0a+
                      '      синхронизация по товару проводиться не будет:'+#$0d+#$0a+
                      '      Локальный код: %2:d;';
    WrongCountMsg   = 'Ошибочное значение в количестве';
    WrongPriceMsg   = 'Ошибочное значение в цене';
    WrongTransform  = 'Ошибка при обработке данных';
    WrongSync       = 'Ошибка при синхронизации данных';
    WrongTransFile  = 'Ошибка при обработке данных. Будте внимательны:'+#$0d+#$0a+
                      'повторная попытка загрузки файла может привести'+#$0d+#$0a+
                      'к задвоению данных в кассовом сервере.';
    ChangedCodeMsg  = 'Код входящего товара отличается от имеющегося:'+#$0d+#$0a+
                      '      Код в кассовом сервере: %5:d;'+#$0d+#$0a+
                      '      Передаваемый код: %4:d;';
    ChangeCodeOkMsg = 'Изменен код товара в кассовом сервере:'+#$0d+#$0a+
                      '      Был: %5:d;'+#$0d+#$0a+
                      '      Стал: %4:d;';
    WrongTransGood  = 'Ошибка при переносе в кассовый сервер данных товара:'+#$0d+#$0a+
                      '      Локальный код: %4:d;';
    WrongTransPrice = 'Ошибка при переносе в кассовый сервер данных цены товара:'+#$0d+#$0a+
                      '      Локальный код: %4:d;';
    WrongTransChanges = 'Ошибка при регистрации обновлений в кассовом сервере данных товара:'+#$0d+#$0a+
                      '      Локальный код: %4:d;';
    WrongSyncGood   = 'Ошибка при переносе в кассовый сервер данных товара:'+#$0d+#$0a+
                      '      Локальный код: %2:d;';
    SyncNotGood     = 'В базе кассового сервера данных о товаре нет:'+#$0d+#$0a+
                      '      Локальный код: %2:d;';
    TransChangesMsg = 'Зарегистрировано изменений товаров количеством:   %d.';
    TransPricesMsg  = 'Установлено цен товаров количеством:   %d.';
    WrongTransPrices= 'Цены не установлены!!!';
    WrongTransGoods = 'ДАННЫЕ В КАССОВЫЙ СЕРВЕР НЕ ПЕРЕНЕСЕНЫ!!!';
    WrongSyncGoods  = 'ДАННЫЕ СИНХРОНИЗАЦИИ В КАССОВЫЙ СЕРВЕР НЕ ПЕРЕНЕСЕНЫ!!!';
    ResultMsg       = ''+#$0d+#$0a+'КОЛИЧЕСТВО ЗАПИСЕЙ ДЛЯ ПРЕНОСА '+
                      'В КАССОВЫЙ СЕРВЕР:       %d ;'+#$0d+#$0a+
                      'КОЛИЧЕСТВО ПОЗИЦИЙ ТОВАРА ПЕРЕНЕСЕННОГО В КАССОВЫЙ СЕРВЕР:  %d.';
    ResultSyncMsg   = ''+#$0d+#$0a+'КОЛИЧЕСТВО ПОЗИЦИЙ ТОВАРА ДЛЯ CИНХРОНИЗАЦИИ '+
                      'В КАССОВЫЙ СЕРВЕР:       %d ;'+#$0d+#$0a+
                      'КОЛИЧЕСТВО ПОЗИЦИЙ ТОВАРА CИНХРОНИЗИРОВАННОГО В КАССОВЫЙ СЕРВЕР:  %d.';
    ErrorCaption    = 'Ошибка';
    WarningCaption  = 'Внимание!!!';
    DiffersCodeMsg  = 'Произошла ошибка при установке шрих-кода %s для товара %s :'+#$0d+#$0a+
                      'В базе имеется такой же штрих-код пренадлежащий другому товару.'+#$0d+#$0a+
                      'Сменить принадлежность шрих-кода?';
    BCErrInstMsg    = 'Ошибка установки штрих-кода.';
    BCFormatMsg     = '-- %s '+#$0d+#$0a+'%s';
    BCGeneralMsg    = '      Код:                     %0:d;'+#$0d+#$0a+
                      '      Наименование:  %1:s;'+#$0d+#$0a+
                      '      Штрих-код:          %2:s;'+#$0d+#$0a+
                      '      Масштаб:            %3:f;';
    BCErrGoodMsg    = 'Ошибка установки штрих-кода для входящего товара:';
    BCGenErrMsg     = 'Ошибка обработки таблицы штрих-кодов:'+#$0d+#$0a+
                      '      Входящие штрих-коды в базу не внесены.';
    BCRefusMsg      = 'Отказ от приведения штрих-кода для товара:';
    NoBCExistsMsg   = 'Информация о штрих-кодах отсутствует';
    InDocExistsMsg  = 'Выбранный Вами документ был загружен (обработан)'+#$0d+#$0a+
                      'в кассовый сервер %s %s.'+#$0d+#$0a+
                      'Повторная обработка может привести к безосновательному'+#$0d+#$0a+
                      'увеличению количества для выбранного товара.'+#$0d+#$0a+
                      '                               '+#$0d+#$0a+
                      'Продолжить обработку документа?';
    RefusDocMsg     = 'Отказ от обработки документа.';
    ErrHandlHeadMsg = 'Ошибка при обработке заголовка документа.'+#$0d+#$0a+
                      'Документ не обработан, попробуйте повторить операцию.';
    RetreatDocMsg   = 'Повторная обработка документа.';
    OutDocExistsMsg = 'Данные за указанную дату были загружены в базу %s %s.'+#$0d+#$0a+
                      'Повторная обработка может привести к безосновательному'+#$0d+#$0a+
                      'увеличению реализации для выбранного товара.'+#$0d+#$0a+
                      '                               '+#$0d+#$0a+
                      'Продолжить обработку документа?';
    OutDFormatMsg   = '-- %s '+#$0d+#$0a+'%s';
    OutDGeneralMsg  = '      Код в базе кассового сервера:       %0:d;';
    NotIncrMtuMsg   = 'Синхронизируйте базу кассового сервера с основной базой:'+#$0d+#$0a+
                      '      нет информации о соответствующем товаре в базе данных';
    RSubKey         = 'Software\Терминал\EIDukat';
    RClass          = '';
    NameVal         = 'journalize';
    JournalName     = 'journal.txt';
    ErrHandSalesMsg = 'Ошибка при инициализации данных о продажах.'+#$0d+#$0a+
                      'Документ не обработан, попробуйте повторить операцию.';
    FormatHeader    = 'TCI';
    ExportIndent    = 'TCE';
    ResCountRecMsg  = 'КОЛИЧЕСТВО ПОЗИЦИЙ ТОВАРА ИМПОРТИРОВАННОГО С КАССОВОГО СЕРВЕРА:  %d.';
    NotDataMsg      = 'Данные для импорта не обнаружены.';
    CorFileFrmtMsg  = 'Неверный формат данных. Данные не обработаны, повторите операцию.';
    IntErrRoutnMsg  = 'Внутренняя ошибка обработки строки:'+#$0d+#$0a+
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
