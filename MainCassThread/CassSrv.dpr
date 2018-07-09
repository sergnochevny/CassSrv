{*******************************************************}
{                                                       }
{       Terminal service source code                    }
{                                                       }
{       Copyright (c) 2002,03 Terminal                  }
{                                                       }
{*******************************************************}

{$A+,B-,C-,D-,E-,F-,G+,H+,I+,J+,K-,L-,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE CONSOLE}

program CassSrv;

uses
  FastMM4 in '..\FastMM\FastMM4.pas',
  FastMM4Messages in '..\FastMM\FastMM4Messages.pas',
  Windows,
  SysUtils,
  vSvcMgr in 'vSvcMgr.pas',
  tServiceMain in 'tServiceMain.pas',
  CassSrvAppObj in 'CassSrvAppObj.pas',
  myIBEvents in 'myIBEvents.pas',
  LogFunc in 'LogFunc.pas',
  Const_Type in 'Const_Type.pas',
{$ifdef debug}  
  fDbGrid in 'Debugform\fDbGrid.pas',
{$endif}  
  DBObj in 'DBObj.pas',
{$ifdef drvdll}
  AbstractDataStream in 'AbstractDataStream.pas',
{$else}
{$ifdef datecs500}
  DataStream in '..\Datecs500_Protocol\DataStream.pas',
  ConnectionStream in '..\Datecs500_Protocol\ConnectionStream.pas',
  Comm_Procedures in '..\Datecs500_Protocol\Comm_Procedures.pas',
  Protocols in '..\Datecs500_Protocol\Protocols.pas',
  CheckState in '..\Datecs500_Protocol\CheckState.pas',
  ProcessDBObj in '..\Datecs500_Protocol\ProcessDBObj.pas',
{$else}
{$ifdef datecs550}
  DataStream in '..\Datecs550_Protocol\DataStream.pas',
  ConnectionStream in '..\Datecs550_Protocol\ConnectionStream.pas',
  Comm_Procedures in '..\Datecs550_Protocol\Comm_Procedures.pas',
  Protocols in '..\Datecs550_Protocol\Protocols.pas',
  CheckState in '..\Datecs550_Protocol\CheckState.pas',
  ProcessDBObj in '..\Datecs550_Protocol\ProcessDBObj.pas',
{$endif}
{$endif}
{$endif}  
  DBObjs in 'DBObjs.pas';

{$R *.RES}

begin
	if (Win32Platform = 2) and (Win32MajorVersion>=4) then begin
		try

      {Ваш код инициализации}

		except
			on E:Exception do
				begin
					MessageBox(0, PChar(E.Message),
                     PChar(tServiceMain.Application.ServiceName),
                     MB_ICONERROR);
				end;
		end;
		if Installing or StartService or Registering then
			begin
        tServiceMain.Application.Initialize;
        Application.Run;
			end;
	end;
end.



