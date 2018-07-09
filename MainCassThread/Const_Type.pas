unit Const_Type;

interface
uses
	Windows, LogFunc, SysUtils ;

resourcestring  
	GeneralError		= 'Ошибка инициализации драйвера.';

  PathDelimiter   = '\';
  SectionCommon   = 'COMMON';
  RegIniFileNameC = 'CassSrv.ini';
  DBK             = 'DB';
  DBUserK         = 'DBUser';
  DBPassK         = 'DBPass';

  Def_DB_FileName = '\Data\CassSrvDB.gdb';
  Def_DB_user     = 'SYSDBA';
  Def_DB_pass     = 'masterkey';

  __InsertCheck__ = 'SELECT RES FROM INSERT_CHECK(%s,''%s'',%s,%s,%s,%s)';
  __InsertSale__ = 'INSERT INTO "EcrSells"'+
                   '(SERNUMBER, MOMENT, ECRCODE, GOODSID, PRICE, QUANTITY, SUMMA, '+
                   'DISCOUNT, TOTAL, TAXNUMBER, ECRPAYID, CHKNUMBER) '+
                   'VALUES(%s,''%s'',%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)';
  __UpdateCheck__ = 'SELECT RES FROM UPDATE_CHECK(%s,%s,''%s'',%s,%s,%s,%s)';

  __select__ = 'SELECT ';
  __all__ = '* ';
  __from__ = ' FROM ';
  __where__ = ' WHERE ';
  __and__ = ' AND ';

{$ifdef drvdll}  
  __InitProtocol__ = 'InitProtocol';
{$endif}  

  __InitParseQueryDisc__ = 'InitParseQueryDisc';
  __InitParseBar__       = 'InitParseBar';
  __ParseQueryDisc__     = 'ParseQueryDisc';
  __ParseBar__           = 'ParseBar';
  
  Def__PQDLibraryName    = 'PQDLibrary';
  Def__PBLibraryName     = 'PBLibrary';

  SectionLibrary         = 'LIBRARY';
  PBLibraryNameK         = 'PBLibrary';
  PQDLibraryNameK        = 'PQDLibrary';
  TmpDirK                = 'TmpDir';
  GoodsCasheK            = 'GoodsCashe';
  ProtocolDirK           = 'ProtocolDir';
  LogCheckK              = 'LogCheck';
  __kSaveServiceCheck    = 'SaveServiceCheck';
  __kWriteProtocol       = 'WriteProtocol';
  __kWriteFullProtocol   = 'WriteFullProtocol';
  __kRejectNoAnswer      = 'RejectNoAnswer';
  __kNoRejectIfNull      = 'NoRejectIfNull';
  __kSendNullIfReadError = 'SendNullIfReadError';

  __tmpext               = '.tmp';
  __logext               = '.log';
  __dbext                = '.db';
  __tmpand               = '_';
  __iniext               = '.ini';
  __Libraryext           = '.dll';
  __tmpast               = '*';

	__kReadIntervalTimeout 			    = 'ReadIntervalTimeout';
	__kReadTotalTimeoutMultiplier 	= 'ReadTotalTimeoutMultiplier';
	__kReadTotalTimeoutConstant 		= 'ReadTotalTimeoutConstant';
	__kWriteTotalTimeoutMultiplier 	= 'WriteTotalTimeoutMultiplier';
	__kWriteTotalTimeoutConstant  	= 'WriteTotalTimeoutConstant';

  __cfg_com = 'cfg_com';
  
const
  __NOINFINITE = 1;

  __EvWaitCloseTimeOut = 5000;

  __DefSaveServiceCheck = 1;
  __DefWriteProtocol = 1;
  __DefWriteFullProtocol = 0;
  __DefRejectNoAnswer = 1;
  __DefNoRejectIfNull = 0;
  __DefSendNullIfReadError = 1;
  __DefRepCountCreateCheckData = 50;
  
  DefSilent = 0;
  DefBaudRate = CBR_4800;
  DefByteSize = 8;
  DefStopBits = OneStopBit;
  DefParity = NoParity;
  DefDepthBuff = 14;

  LenIniStr           :LongWORD   = 300;
  LenFileName         :Integer = 300;  

  THREAD_PROCESS_PACKET   = $0401;
  THREAD_BREAK            = $0402;
  THREAD_REFRESH          = $0403;
  THREAD_PROCESS_DATA     = $0404;
  THREAD_BREAK_CONNECT    = $0405;
  
	LenBigRow 						= 1024;
	tcReadIntervalTimeout 			= 0;
	tcReadTotalTimeoutMultiplier 	= 0;
	tcReadTotalTimeoutConstant 		= 200;//50;//25;//100;//1000;
	tcWriteTotalTimeoutMultiplier 	= 0;
	tcWriteTotalTimeoutConstant  	= 0;

  DefTroubleRepCount = 2;

  Def_LogCheck    = 0;
  
	PortN1 = 1;
	PortN2 = 2;
	PortN3 = 3;
	PortN4 = 4;
  
  DlmField = ';';
  _DS = '.';
  MinDataSize = 3;

const
  RESTORE = $13;
  ACK = $06;
  NAK = $15;
  FF = $FF;
  TAKE = $11;
  TAKE1 = $04;
  pBEG = $0A;
  pEND = $0D;

  SizeACKBuff = 1;
  SizeNakBuff = 1;
  SizeTAKEBuff = 20;
  SizeNullBuff = 5;
  SizeRESTOREBuff = 14;

  defNAKNum = 5;
  defErrorReadNum = 1;
  
  resAck = 1;
  resNak = 2;
  
  opSaleArt          = Ord('0');
  opSaleCode         = Ord('1');
  opSaleBar          = Ord('7');
  opDiscount         = Ord('2');
  opPayment          = Ord('3');
  opQueryKey         = Ord('4');
  opQeryDisc         = Ord('C');
  opRejectSale       = Ord('A');
  opRejectSaleCode   = Ord('B');
  opRejectSaleBar    = Ord('F');
  opAnnul            = Ord('H');
  opRejectAnnul      = Ord('X');

  __DiscOnLastPerc   = 0;
  __DiscPerc         = 1;
  __DiscOnLastSum    = 2;
  __DiscSum          = 3;
  
  ___AddPerc          = 0;
  ___DiscPerc         = 1;
  ___AddSum           = 2;
  ___DiscSum          = 3;

  __opSale           = 0;
  __opPartPayment    = 1;
  __opPayment        = 2;
  __opAnnul          = 5;
  __opInOut          = 10;
  __opNullCheck      = 11;
  __opUnknown        = 99;
  __opNull           = $FF;
  
  __kndNullCheck     = 'A';
  __kndInOut         = 'P';
  __kndPayCash       = '0';
  __kndPayCredit     = '2';
  __kndPayCard       = '3';

{$ifdef datecs550}  
  __posSerialNum          = 1;
  __posSaleChkNum         = 8;
  __posSaleCode           = 4;
  __posSaleCount          = 6;
  __posSaleRow            = 7;
  __posPayChkNum          = 9;
  __posAnnulChkNum        = 9;
  __posPaytKind           = 4;
  __posQueryDisctKind     = 4;
  __posQueryDiscChkNum    = 7;
  __posPaySumTotal        = 11;
  __posPaySum             = 17;
  __posSalePrice          = 5;
  __posQueryKey           = 4;
  __posDiscChkNum         = 9;
  __postDiscountKind      = 4;
  __posSumBefDisc         = 5;
  __postValueDiscount     = 6;
  __posSumAftDisc         = 10;

  __LastEcrCode           = 250;

{$endif}  

  __CLEANGOODSTABLE   = '55555555';
  __ANSWERCLEANGOODS1 = 'Таблица товаров';
  __ANSWERCLEANGOODS2 = 'очищена.';
  
{$ifdef datecs500}  
  ___kndNullCheck     = '5';
  ___kndInOut         = '6';

  __posSerialNum          = 1;
  __posSaleChkNum         = 8;
  __posSaleCode           = 4;
  __posSaleCount          = 6;
  __posSaleRow            = 7;
  __posPayChkNum          = 9;
  __posAnnulChkNum        = 9;
  __posPaytKind           = 4;
  __posQueryDisctKind     = 4;
  __posQueryDiscChkNum    = 9;
  __posPaySumTotal        = 11;
  __posPaySum             = 20;
  __posSalePrice          = 5;
  __posQueryKey           = 4;
  __posDiscChkNum         = 9;
  __postDiscountKind      = 4;
  __posSumBefDisc         = 5;
  __postValueDiscount     = 6;
  __posSumAftDisc         = 10;

{$ifdef debug}  
  __LastEcrCode           = 250;
{$else}
  __LastEcrCode           = 250;
{$endif}  

{$endif}  

  __SECONDS              = 1000;
  __WTimeOut             = 5;
  __Off                  = 1;

type

  PSaveDataRec = ^TSaveDataRec;
  TSaveDataRec = packed record
    __CheckData:  Pointer;
    __FileName: String;
    __TmpDir: String;
  end;

  PGoodsParam = ^TGoodsParam;
  TGoodsParam = record
    isBarCode: Boolean; OriginalPrice, Zoom: Double;
    BarCode,Code,Count,Price,Tax,Name,GoodsID,EcrCode: String; 
    Dividable: Boolean;
  end;
  
  PDevArray = ^TDevArray;
  TDevArray = array of array[0..3] of Cardinal;

  PStreamInfo = ^TStreamInfo;
  TStreamInfo = record
    Port: ShortInt; 
    BaudRate: Cardinal; 
    ByteSize,
    Parity, StopBits: Byte; 
    CountDev: Integer;    
    Proc: FarProc;
  end;

  PStreamInfoEnum = ^TStreamInfoEnum;
  TStreamInfoEnum = record
    Val: TStreamInfo;
    Next: PStreamInfoEnum;
  end;
  
  PDevEnum = ^TDevEnum;
  TDevEnum = record
    SerialNum: Integer;
    DevNum: Integer;
    Depart: Integer;
    Off: Integer;
    Next: PDevEnum;
    CheckState: Pointer;
    GoodsCash: Pointer;
    LastEcrCode: Integer;
    Log:  TLog;
  end;

  PDataStreamEnum = ^TDataStreamEnum;
  TDataStreamEnum  = record
    DataStream: Pointer;
    Next: PDataStreamEnum;
  end;

  POpData = ^TOpData;
  TOpData = packed record
    __opType: Byte;
    __DevEnum: PDevEnum;
  end;
  
	PBuffer = ^TBuffer;
	TBuffer = array of Byte;

  _DCB = packed record
    DCBlength: DWORD;
    BaudRate: DWORD;
    Flags: Longint;
    wReserved: Word;
    XonLim: Word;
    XoffLim: Word;
    ByteSize: Byte;
    Parity: Byte;
    StopBits: Byte;
    XonChar: CHAR;
    XoffChar: CHAR;
    ErrorChar: CHAR;
    EofChar: CHAR;
    EvtChar: CHAR;
    wReserved1: Word;
  end;
  
	PCommInfo = ^TCommInfo;
	TCommInfo = packed record
		CommHandle,
		BaudRate:           Cardinal;    
    ByteSize: Byte;
    Parity: Byte;
    StopBits: Byte;
		Port:               ShortInt;
		Connected:          BOOL;
		CommTimeOuts:       TCommTimeOuts;
		DCB:                TDCB;
		case Byte of
			0: (SD:         pSecurityDescriptor;
				  SA:         pSecurityAttributes);
			1: (pSD, pSA:   Cardinal);
	end;

	PInfo = ^TInfo;
	TInfo = packed record
		OldPriority: Integer;
		BigWriteCount,
		BigReadCount,
		CommandWriteCount,
		CommandReadCount:  	Cardinal;
		case Byte of
			0: (CommInfo:           PCommInfo;
				CommandWriteBuffer,
				CommandReadBuffer,
				BigWriteBuffer,
				BigReadBuffer:  PBuffer);
			1: (H_CommInfo,
				H_CommandWriteBuffer,
				H_CommandReadBuffer,
				H_BigWriteBuffer,
				H_BigReadBuffer:Cardinal);
	end;

  TInitParseQueryDisc = procedure; stdcall;
  TInitParseBar = procedure(_HLibrary: THandle); stdcall;
  TParseQueryDisc = function(_ChkNum: Integer; _Perc, _BSum: Double; var _tDKnd: Integer ): Double; stdcall;
  TParseBar = function( var _P: TGoodsParam ): Boolean; stdcall;

  TOnChange = procedure() of object;
  
const
	Size_Buffer:    DWORD = $20;
	Size_BigBuffer: DWORD = $100;
	Size_CommInfo:  DWORD = sizeof(TCommInfo);
	Size_Info:      DWORD = sizeof(TInfo);
	Size_SD:        DWORD = SECURITY_DESCRIPTOR_REVISION;
	Size_SA:        DWORD = sizeof(tSecurityAttributes);
	Size_DCB:       DWORD = sizeof(TDCB);


  __cGoodsChange    = 0;
  __cBarCodesChange = 1;
  __cDepPriceChange = 2;
  
var
	Structura_Info: PInfo = nil;
  HandleEvents: array[0..8] of String = ('GOODS_INSERT','GOODS_UPDATE','GOODS_DELETE',
                                        'BARCODES_INSERT', 'BARCODES_UPDATE', 'BARCODES_DELETE',
                                        'DEPPRICE_INSERT', 'DEPPRICE_UPDATE', 'DEPPRICE_DELETE');
const
  TranslChar: array[0..255] of Byte = (
    $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,
    $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,
    $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,
    $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F,
    $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,
    $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F,
    $20,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,
    $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F,
    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,
    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,
    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$5D,$20,$20,$20,$20,$5C,
    $20,$20,$5B,$5B,$20,$20,$20,$20,$20,$20,$5D,$20,$20,$20,$20,$5C,
    $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F,
    $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7E,$7B,$7F,$7C,$7D,
    $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F,
    $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7E,$7B,$7F,$7C,$7D
  );

  procedure __move(const Src, Dest; Len:Integer);
  function WinStrToDatecs(const SourceStr: String): String;stdcall;
  
implementation

procedure __move(const Src, Dest; Len:Integer);
begin
  asm
    mov edi, [edx]
    mov esi, [eax]
    rep movsb
  end;
end;

//AnsiToDatecs
//==============================================================================
function WinStrToDatecs(const SourceStr: String): String;stdcall;
begin
  SetLength(Result,Length(SourceStr));
  asm
   	push  edi
   	push  esi
   	push	ebx
  	cld
   	mov 	esi, [ebp+$0c]
   	mov 	edi, Result
    mov   edi, [edi]
    lea   ebx, TranslChar
    xor 	eax, eax
   	mov 	ecx, [esi - 04h]
    or 		ecx, ecx
    jz 		@retn
    inc   ecx
  @@1:
    lodsb
    or 		eax, eax
    loopnz @@2
    jmp 	@retn
  @@2:
    xlat
    stosb
    jmp   @@1
  @retn:
    pop   ebx
 	  pop 	esi
 	  pop 	edi
  end;
end;

end.

