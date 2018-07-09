DROP PROCEDURE UDP_EXPORTDUKAT_ALL
---
CREATE PROCEDURE UDP_EXPORTDUKAT_ALL(
    DAT DATE,
    CENAKIND INTEGER)
RETURNS (
    IF1 INTEGER,
    IF2 INTEGER,
    imtu INTEGER,
    CARDNUM INTEGER,
    DEPARTMENT INTEGER,	
    PRINT CHAR(1),
    NAME VARCHAR(64),
    SHORTNAME VARCHAR(30),
    KOL DOUBLE PRECISION,
    CENA DOUBLE PRECISION,
    INCRED INTEGER,
    PR_NDS SMALLINT,
    BARCODE VARCHAR(20),
    SCALE DOUBLE PRECISION)
AS
declare variable SKol Double precision;
declare variable SScale Double precision;
declare variable Df16 Double precision;
declare variable ED1 Integer;
declare variable PrB Integer;
declare variable imtupos Integer;
declare variable IPart Integer;
begin
    if ((CenaKind is Null) or (Dat is null)) then Exit;

    for
        select incr, incrmtu, incrpart, PR_NDS
        from mtupos where declar=1
        into :imtupos, :imtu, :IPart, :PR_NDS
/*
        select CardNum, incr, incrmtu, incrpart, PR_NDS
        from mtupos where declar=1
        into :CardNum, :imtupos, :imtu, :IPart, :PR_NDS
*/
    do begin

				DEPARTMENT = Null;
				CardNum = Null;	IF1 = Null; IF2 = Null;
        Name = Null; ShortName = Null; Kol = Null; 
				Cena = Null; IncrED = Null; BarCode = Null; 
				Scale = Null; PRINT = Null; Df16 = Null; 
				ED1 = Null;  SScale = Null;
				
				SKol=0;
        select Sum(Saldo+debet-credit-reserve) as SKol
        from mtucard where incrmtupos = :imtupos
        and Dat = fn_bmonth(:DAT)
        into :SKol;
				if (SKol<>0) then begin
					if (CenaKind = -1) then begin
							select Cena,IncrED from udp_extract_mplcena(:Imtu, :IPart, :DAT)
							into :Cena,:IncrED;
					end
					else
							if (CenaKind = 0) then begin
									select RCena,IncrEdR
									from mtucena
									where incrmtupos = :imtupos and
												begdat <= :DAT and enddat > :DAT
									into :Cena,:IncrED;
							end
							else
									if (CenaKind = 1) then begin
											select Cena1,IncrEd1
											from mtucena
											where incrmtupos = :imtupos and
														begdat <= :DAT and enddat > :DAT
											into :Cena,:IncrED;
									end
									else
											if (CenaKind = 2) then begin
													select Cena2,IncrEd2
													from mtucena
													where incrmtupos = :imtupos and
																begdat <= :DAT and enddat > :DAT
													into :Cena,:IncrED;
											end
											else
													if (CenaKind = 3) then begin
															select Cena3,IncrEd3
															from mtucena
															where incrmtupos = :imtupos and
																		begdat <= :DAT and enddat > :DAT
															into :Cena,:IncrED;
													end
													else begin
															select Cena4,IncrEd4
															from mtucena
															where incrmtupos = :imtupos and
																		begdat <= :DAT and enddat > :DAT
															into :Cena,:IncrED;
													end

					DEPARTMENT=1; 
					select max(fn_StrToIntDef(fn_Copy(variabl,11,10),1)) from variables
						where fn_ExDlm(1,vls,'^')=''||:iPart
							and fn_Copy(variabl,1,10)='CASH_PART+'
						into :DEPARTMENT;

					if ( exists (select *	from VARIABLES
					where variabl = fn_Trim('CASH_PART+'||CAST(:DEPARTMENT as VARCHAR(2))) and
						fn_StrToIntDef(fn_ExDlm(2,Vls,'^'),0) = 0 )) then
						PR_NDS = -1;

					select code, Name,ShortName,IncrEd1
					from mtu where incr=:imtu
					into :CardNum,:Name,:ShortName,:Ed1;
/*
				select Name,ShortName,IncrEd1
        from mtu where incr=:if15
        into :Name,:ShortName,:Ed1;
*/
					Df16 = NULL;
					execute procedure mtued_ed_cf(:imtu,:ed1,:IncrEd)
					returning_values :Df16;
					if (DF16 is NULL) then Df16 = 1;

					if (IncrEd IS NOT NULL) then
						SELECT SnInt FROM ED WHERE Incr=:IncrEd INTO :PrInt;
					else
					if (ed1 IS NOT NULL) then
						SELECT SnInt FROM ED WHERE Incr=:ed1 INTO :PrInt;
					else PrInt='0';

					Kol = SKol * Df16;
					BarCode = Null; Scale = Null; SScale = Null;
					PrB = 0;
					for
							select BarCode, Scale
							from MTUPOS_MTUBAR_LIST(:imtupos)
							into :BarCode, :SScale
					do begin
							PrB = PrB+1;
							if (SScale is not Null) then Scale = SScale * Df16;
							SUSPEND;
					end
					if (PrB = 0) then SUSPEND;
        end
    end
end