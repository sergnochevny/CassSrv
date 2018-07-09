unit AbstractDataStream;

interface
  uses  Windows, Messages,
  Const_Type, SysUtils,
  DBClient, myIBEvents, StrFunc;
  
type

  PDataStream = ^TDataStream;
  TDataStream = class
    private
      __HParseQueryDiscLiblary,
      __HParseBarLibrary,
		  __HLibrary: THandle;
      __ConnectionStream: TObject;
      __TimeOut:   Integer;
      __Terminated: Boolean;
      __DevEnum: PDevEnum;
      __MainTHId: Cardinal;
      __StreamHandle: THandle;
      __StreamThID: Cardinal;
      __Port: Integer;
      __PortID: Integer;
      __BaudNumber: Integer;
{$ifdef CS}      
      __CS: TRTLCriticalSection;
      __CSDev: TRTLCriticalSection;
{$else}      
      __EvH: Cardinal;
      __EvHDev: Cardinal;
{$endif}      
		  __EventLogger: TObject;

      __Goods: TClientDataSet;
      __BarCodes: TClientDataSet;
      __DepPrice: TClientDataSet;
      __Ecrs: TClientDataSet;

      ___InitParseQueryDisc: TInitParseQueryDisc;
      ___InitParseBar: TInitParseBar;
      ___ParseQueryDisc: TParseQueryDisc;
      ___ParseBar: TParseBar;
      
      __DBObj: TObject;

      __SaveServiceCheck: Integer;
      __WriteProtocol: Integer;
      __WriteFullProtocol: Integer;
      __RejectNoAnswer: Integer;
      __NoRejectIfNull: Integer;
      __SendNullIfReadError: Integer;

      __TmpDir, __GoodsCashe,
      __ProtocolDir,
      __PQDLibraryName,
      __PBLibraryName: String;
    private
    protected
      procedure __Terminate; virtual; abstract;
      function __GetParams: Boolean; virtual; abstract;
      procedure __CheckTmpCDS; virtual; abstract;
      procedure __CreateDevEnum(_DevArray: TDevArray); virtual; abstract;
      function __GoodsCasheCreate(): TClientDataSet; virtual; abstract;
      function __OpenGoodsCashe(_DevEnum: PDevEnum): TClientDataSet; virtual; abstract;
      procedure __FreeDevEnum; virtual; abstract;
      procedure __CloseStream; virtual; abstract;
      function __GetGoodsParam(var _P: TGoodsParam; _DevEnum: PDevEnum): Boolean; virtual; abstract;
      function __ParseBar( var _P: TGoodsParam; _DevEnum: PDevEnum ): Boolean; virtual; abstract;
      function __ParseKey( _Key: String; _DevEnum: PDevEnum ): String; virtual; abstract;
      function __ParseQueryDisc( _ChkNum: Integer; _Perc, _BSum: Double; var _tDKnd: Integer; _DevEnum: PDevEnum ): Double; virtual; abstract;

      procedure __SaleArt(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __Payment(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __Annul(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __QueryDisc(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __SaleCode(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __Discount(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __SaleBar(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __QueryKey(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __RejectLastOperation(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __RejectSaleCode(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __RejectSaleBar(_P: Pointer; _DevEnum: PDevEnum); virtual; abstract;
      procedure __ProcEventsAlert( _cds: TClientDataSet; _case: Integer ); virtual; abstract;
      procedure __RefreshGoodsCashe(_case: Integer); virtual; abstract;
    public
      constructor Create;
		  destructor Destroy; override;
      function InitializeStream( _P: Pointer ): BOOL; virtual; abstract;
      procedure Terminate; virtual; abstract;
      procedure WaitForExit; virtual; abstract;
      procedure Resume; virtual; abstract;
      procedure Initialize; virtual; abstract;
      procedure Finalize; virtual; abstract;
      procedure Run; virtual; abstract;
      procedure ProcessPacket(_P: Pointer; _OpData: POpData); virtual; abstract;
      procedure ConfirmAnnul(_DevEnum: PDevEnum); virtual; abstract;
    published
      property Terminated: Boolean read __Terminated write __Terminated;
      property StreamThID: Cardinal read __StreamThID;
      property MainThID: Cardinal write __MainThID;
      property HLibrary: THandle read __HLibrary write __HLibrary;
      property Port: Integer read __Port write __Port;
      property PortID: Integer read __PortID write __PortID;
      property BaudNumber: Integer read __BaudNumber write __BaudNumber;
      property TmpDir: String read __TmpDir;
      property EventLogger: TObject read __EventLogger;
  end;

implementation

constructor TDataStream.Create;
begin
end;

destructor TDataStream.Destroy;
begin
end;

initialization
  DecimalSeparator := _DS;

end.


