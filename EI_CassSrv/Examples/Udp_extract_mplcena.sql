DROP PROCEDURE udp_extract_mplcena
---
CREATE PROCEDURE udp_extract_mplcena(
    IMTU INTEGER,
    IPART INTEGER,
    DAT DATE)
RETURNS (
    CENA DOUBLE PRECISION,
    INCRED INTEGER)
AS
DECLARE VARIABLE IMpl INTEGER;
begin
    if ((IMTU is Null) or (IPART is Null) or (Dat is null)) then Exit;

		IMpl=0; 
		select  fn_ExDlm(1,vls,'^') from variables
			where fn_StrToIntDef(fn_Copy(variabl,10,10),0) = :iPart
				and fn_Copy(variabl,1,9)='PART_MPL+'
			into :IMpl;

		SELECT Price, IncrEd FROM MTUPRICE WHERE
			IncrMTU=:IMTU AND IncrMPL=:IMPL AND BegDat<=:Dat AND EndDat>:Dat
		INTO :Cena, :IncrEd;

		SUSPEND;
end