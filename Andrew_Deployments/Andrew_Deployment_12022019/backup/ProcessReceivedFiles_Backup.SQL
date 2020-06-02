USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [dbo].[ProcessReceivedFiles]    Script Date: 12/3/2019 10:49:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Joey B.
-- Create date: 10/4/2013
-- Description:	Reads AND updates EDI DB with imported files
-- =============================================
CREATE PROCEDURE [dbo].[ProcessReceivedFiles] 
(
	 @FileName VARCHAR(100)
	,@FileText VARCHAR(MAX)
)
AS
BEGIN	
	SET NOCOUNT ON; ---- SET NOCOUNT ON added to prevent extra result sets from interfering with select statements.

	---- READ THE TEXT AND SPLIT INTO A TABLE FOR PROCESSING
	DECLARE  @FileType VARCHAR(20)
			,@txt VARCHAR(MAX)
			,@ediVersion CHAR(4)
			,@fileNo VARCHAR(30)
			,@PRFNumSep INT

	-- DECLARE @FileText VARCHAR(MAX) 
	-- DECLARE @FileName VARCHAR(100)
	-- SET @FileName='855_000069812.txt'

	---- PO STRING
		-- SET @txt = 'ISA~GS~ST*850*00001~BEG*00*NE*104824**20130311~DTM**20130311~N1*ST*Half Price Books #001*15*00ST~N1*BT*Half Price Books Corporate Office*15*00BT~N1*VN*Baker & Taylor Distribution*15*00VN~N2*Crystal Sweeney~N2*AcCOUNTingOffice~N3*5803 E. Northwest Hwy.~N3*5803 E. Northwest Hwy.~N3*PO Box 277938~N4*Dallas*TX*75231*USA~N4*Dallas*TX*75231~N4*Atlanta*GA*30384~PO1*1*3*EA*11.3900*EN*9781451627299*UP*~IT8*N~PO1*2*12*EA*16.5200*EN*9780446583978*UP*~IT8*N~PO1*3*12*EA*17.1000*EN*9780316036313*UP*~IT8*N~PO1*4*15*EA*8.5500*EN*9780425263907*UP*~IT8*N~PO1*5*15*EA*19.9500*EN*9780307464873*UP*~IT8*N~PO1*6*7*EA*17.0900*EN*9781401233792*UP*~IT8*N~PO1*7*12*EA*16.5000*EN*9780399157561*UP*~IT8*N~PO1*8*25*EA*9.0900*EN*9780345803498*UP*~IT8*N~PO1*9*25*EA*9.0900*EN*9780345803504*UP*~IT8*N~PO1*10*25*EA*9.0900*EN*9780345803481*UP*~IT8*N~PO1*11*12*EA*5.1200*EN*9780553579901*UP*~IT8*N~PO1*12*10*EA*14.2400*EN*9781401235413*UP*~IT8*N~PO1*13*5*EA*8.5500*EN*9780375507250*UP*~IT8*N~PO1*14*2*EA*19.9500*EN*9780553801477*UP*~IT8*N~CTT*14*180~SE*44*00001~'
	---- ACKNOWLEDGE STRING
		-- SET @FileText = ''
	---- INVOICE STRING
		-- SET @txt = 'ISA|00|810BK3060 |00|          |ZZ|7214119        |ZZ|760985X        |131015|1132|U|00300|013113257|0|P|>GS|IN|7214119|760985X|131015|1132|013113257|X|003060ST|810|0001BIG|131015|TESTINV-1132|131015|TESTPO-111057CUR|SE|USDN1|ST||15|760985XN1|BT||15|760985XN1|VN||15|7214119ITD|01|3|||||30DTM|011|131015|||20IT1|1|1|EA|590.00|NT|IB|0835247414|PO|TESTPO-111057CTP||SLP|590.00|||DIS|1PID|F||||SUBJECT GUIDE TO BIP 2005-2006TDS|59000CAD|M||||USPSSAC|C|G830|||0|||||||06CTT|1|1SE|16|0001GE|1|013113257IEA|1|013113257'
	SET @txt = LTRIM(RTRIM(@FileText))
	IF RIGHT(LTRIM(RTRIM(@txt)), 1) = '|' SET @txt = LTRIM(RTRIM(REPLACE(@txt, '|', '')))
	SET @txt = REPLACE(@txt, '*', '|') ---- RUN REPLACE TO ACCOUNT FOR BOTH 3060 AND 4010 VERSIONS
	SET @FileType = LTRIM(RTRIM(SUBSTRING(REPLACE(@FileName, 'HPB', ''), 1, 3)))

	IF @FileType NOT IN ('855', '856', '810') OR UPPER(RIGHT(@FileName, 5)) LIKE 'XX%'
		BEGIN
			SET @FileType = LTRIM(RTRIM(RIGHT(REPLACE(@FileName, 'HPB', ''), 3)))
			SET @fileNo = REPLACE(RIGHT(RTRIM(@txt), 9), '~', '')
			SET @ediVersion = '4010'
		END
	ELSE
		BEGIN
			SET @fileNo = CASE WHEN LEFT(@FileName, 3) = 'HPB' THEN REPLACE(RIGHT(RTRIM(@txt), 9), '~', '') ELSE RIGHT(REPLACE(@FileName, '.txt', ''), 9) END
			SET @ediVersion = '3060'
		END

	---- ADD REPLACE STRING TO ADD TILDE FOR PARSING
	IF @FileType = '855'
		BEGIN
			SET @txt = REPLACE(@txt, '|B5|', '|B5|^')
			SET @txt = REPLACE(@txt, '|B6|', '^|B6|')
		END

	SET @txt = REPLACE(@txt, 'GS|'		, '~GS|')
	SET @txt = REPLACE(@txt, 'ST|856'	, '~ST|856')
	SET @txt = REPLACE(@txt, 'ST|855'	, '~ST|855')
	SET @txt = REPLACE(@txt, 'ST|810'	, '~ST|810')
	SET @txt = REPLACE(@txt, 'BAK|'		, '~BAK|')

	IF @FileType = '856'
		BEGIN
			SET @txt = REPLACE(@txt, 'BSN|'				, '~BSN|')
			SET @txt = REPLACE(@txt, 'PRF|'				, '~PRF|')
			SET @txt = REPLACE(@txt, 'REF|BM'			, '~REF|BM')
			SET @txt = REPLACE(@txt, 'REF|PK'			, '~PEF|PK')
			SET @txt = REPLACE(@txt, 'REF|CN'			, '~RRE|CN')
			SET @txt = REPLACE(@txt, 'REF|MA'			, '~PEF|MA')
			SET @txt = REPLACE(@txt, 'REF|IV'			, '~PIV|IV')
			SET @txt = REPLACE(@txt, 'TD1|'				, '~TD1|')
			SET @txt = REPLACE(@txt, 'TD5|'				, '~TD5|')
			SET @txt = REPLACE(@txt, 'LIN|'				, '~LIN|')
			SET @txt = REPLACE(@txt, 'MEA|'				, '~MEA|')
			SET @txt = REPLACE(@txt, 'MAN|GM'			, '~MAN|GM')
			SET @txt = REPLACE(@txt, 'HL|'				, '~HL|')
			SET @txt = REPLACE(@txt, 'FOB|PO'			, '~FOB|PO')
			SET @txt = REPLACE(@txt, '~LIN||EN|'		, '~LIN||IB|0|EN|')
			SET @txt = REPLACE(@txt, '~LIN||B5||B6||EN|', '~LIN||IB|0|B5||B6||EN|')
		END

	IF @FileType = '810'
		BEGIN
			SET @txt = REPLACE(@txt, 'BIG|'				, '~BIG|')
			SET @txt = REPLACE(@txt, 'TDS|'				, '~TDS|')
			SET @txt = REPLACE(@txt, 'SAC|'				, '~SAC|')
			SET @txt = REPLACE(@txt, 'IT1|'				, '~IT1|')
			SET @txt = REPLACE(@txt, '|NT|EN|'			, '|NT|IB||EN|')
			SET @txt = REPLACE(@txt, '|NT|B5||B6||EN|'	, '|NT|IB||B5||B6||EN|')
			SET @txt = REPLACE(@txt, 'CUR|SE|'			, '~CUR|S:E|')
		END

	SET @txt = REPLACE(@txt, 'SE|'		, '~SE|')
	SET @txt = REPLACE(@txt, 'SN1|'		, '~SN1|')
	SET @txt = REPLACE(@txt, 'N1|'		, '~N1|')
	SET @txt = REPLACE(@txt, '~S~N1|'	, '~SN1|')
	SET @txt = REPLACE(@txt, 'PO1|'		, '~PO1|')
	SET @txt = REPLACE(@txt, 'CTP|'		, '~CTP|')
	SET @txt = REPLACE(@txt, 'PID|'		, '~PID|')
	SET @txt = REPLACE(@txt, 'DTM|017'	, '~DDTM|017')
	SET @txt = REPLACE(@txt, 'DTM|011'	, '~DTM|011')
	SET @txt = REPLACE(@txt, 'ACK|IA'	, '~ACK|IA')
	SET @txt = REPLACE(@txt, 'ACK|IQ'	, '~ACK|IQ')
	SET @txt = REPLACE(@txt, 'ACK|IR'	, '~ACK|IR')
	SET @txt = REPLACE(@txt, 'ACK|IB'	, '~ACK|IB')
	SET @txt = REPLACE(@txt, 'CAD|'		, '~CAD|')
	SET @txt = REPLACE(@txt, 'CUR|'		, '~CUR|')
	SET @txt = REPLACE(@txt, '~~CUR|'	, '~CUR|')
	SET @txt = REPLACE(@txt, 'CTT|'		, '~CTT|')
	SET @txt = REPLACE(@txt, 'IEA|1|'	, '~IEA|1|')
	SET @txt = REPLACE(@txt, CHAR(13)	, '')
	SET @txt = REPLACE(@txt, CHAR(10)	, '')
	SET @txt = REPLACE(@txt, '~~'		, '~')

	DECLARE	 @rVal INT	= 0
			,@err INT	= 0

	DECLARE  @Sender	VARCHAR(15)
			,@Receiver	VARCHAR(15)
			,@filePO	VARCHAR(20)
			,@fileInv	VARCHAR(20)
			,@fileASN	VARCHAR(20)
			,@_FileType VARCHAR(6)
			,@issueDate VARCHAR(12)
			,@amtCode	VARCHAR(4)
			,@LineSts	CHAR(2)
			,@LineCode	CHAR(2)
			,@LineQty	INT
			,@curID		VARCHAR(20)
			,@DisPct	VARCHAR(6)
			,@RetAmt	VARCHAR(8)
			,@ToPay		VARCHAR(10)
			,@addChrg	VARCHAR(10)
			,@chrgCode	VARCHAR(10)
			,@lastID	VARCHAR(20)
			,@lastTracking VARCHAR(30)
			,@UOM		VARCHAR(6)
			,@pkgNo		VARCHAR(30)
			,@trkNo		VARCHAR(30)
			,@InvRef	VARCHAR(15)
			,@ASNRef	VARCHAR(15)
			,@ACKRef	VARCHAR(15)
			,@carrier	VARCHAR(50)
			,@STINVNo	VARCHAR(10)
			,@STASNNo	VARCHAR(10)
			,@STACKNo	VARCHAR(10)
			,@GSNo		VARCHAR(10)
			,@tmpTxt	 VARCHAR(250)

	DECLARE @ACKHdrs TABLE 
	(
		 [RowID]		INT IDENTITY(1, 1)
		,[TypeCode]		VARCHAR(12)
		,[Sender]		VARCHAR(15)
		,[Receiver]		VARCHAR(15)
		,[FileType]		VARCHAR(20)
		,[IssueDate]	VARCHAR(12)
		,[FilePO]		VARCHAR(20)
		,[STIDNo]		VARCHAR(10)
		,[GSNo]			VARCHAR(10)
	)
	DECLARE @ASNHdrs TABLE 
	(
		 [RowID]		INT IDENTITY(1, 1)
		,[TypeCode]		VARCHAR(12)
		,[Sender]		VARCHAR(15)
		,[Receiver]		VARCHAR(15)
		,[FileType]		VARCHAR(20)
		,[IssueDate]	VARCHAR(12)
		,[FilePO]		VARCHAR(20)
		,[FileASN]		VARCHAR(20)
		,[AmtCode]		VARCHAR(4)
		,[Carrier]		VARCHAR(50)
		,[STIDNo]		VARCHAR(10)
		,[GSNo]			VARCHAR(10)
	)
	DECLARE @INVHdrs TABLE 
	(
		 [RowID]		INT IDENTITY(1, 1)
		,[TypeCode]		VARCHAR(12)
		,[Sender]		VARCHAR(15)
		,[Receiver]		VARCHAR(15)
		,[FileType]		VARCHAR(20)
		,[IssueDate]	VARCHAR(12)
		,[FilePO]		VARCHAR(20)
		,[FileINV]		VARCHAR(20)
		,[AmtCode]		VARCHAR(4)
		,[DisPct]		VARCHAR(6)
		,[STIDNo]		VARCHAR(10)
		,[GSNo]			VARCHAR(10)
	)
	DECLARE @ACKDtl TABLE 
	(
		 [PONumber]		VARCHAR(20)
		,[LineNum]		VARCHAR(6)
		,[Qty]			VARCHAR(6)
		,[UOM]			VARCHAR(3)
		,[UnitPrice]	VARCHAR(10)
		,[PriceCode]	VARCHAR(4)
		,[ItemIDCode]	VARCHAR(4)
		,[ItemID]		VARCHAR(15)
		,[AckQty]		INT
		,[ShipQty]		INT
		,[CanQty]		INT
		,[BakQty]		INT
		,[LineSts]		CHAR(2)
		,[LineCode]		CHAR(2)
	)
	DECLARE @ASNDtl TABLE 
	(
		 [PONumber]		VARCHAR(20)
		,[LineNum]		VARCHAR(6)
		,[Qty]			VARCHAR(6)
		,[UOM]			VARCHAR(3)
		,[UnitPrice]	VARCHAR(10)
		,[PriceCode]	VARCHAR(4)
		,[ItemIDCode]	VARCHAR(4)
		,[ItemID]		VARCHAR(15)
		,[AckQty]		INT
		,[ShipQty]		INT
		,[CanQty]		INT
		,[BakQty]		INT
		,[LineSts]		CHAR(2)
		,[LineCode]		CHAR(2)
		,[PkgNo]		VARCHAR(30)
		,[TrkNo]		VARCHAR(30)
	)
	DECLARE @INVDtl TABLE 
	(
		 [PONumber]		VARCHAR(20)
		,[LineNum]		VARCHAR(6)
		,[Qty]			VARCHAR(6)
		,[UOM]			VARCHAR(3)
		,[UnitPrice]	VARCHAR(10)
		,[PriceCode]	VARCHAR(4)
		,[ItemIDCode]	VARCHAR(4)
		,[ItemID]		VARCHAR(15)
		,[FileINV]		VARCHAR(20)
		,[RetAmt]		VARCHAR(8)
	)
	DECLARE @INVAdds TABLE 
	(
		 [PONumber]		VARCHAR(20)
		,[FileINV]		VARCHAR(20)
		,[ChargeCode]	VARCHAR(10)
		,[ChargeAmt]	VARCHAR(10)
	)
	DECLARE @listTable TABLE 
	(	
		 RowID			INT IDENTITY(1, 1)
		,[Type]			VARCHAR(6)
		,[LineNum]		VARCHAR(6)
		,[Qty]			VARCHAR(6)
		,[Key]			VARCHAR(20)
		,[Data]			VARCHAR(250)
	)

	IF ( LEFT(RIGHT(REPLACE(@txt, '~', ''), 15), 3) = 'IEA' OR LEFT(RIGHT(REPLACE(@txt, '~', ''), 16), 3) = 'IEA' ) AND @fileNo = REPLACE(RIGHT(@txt, 9), '~', '') ---- CHECK TO ENSURE THERE IS A COMPLETE FILE
		BEGIN
			IF LTRIM(RTRIM(@fileType)) = '855' ---- READ IN ACKNOWLEDGE FILE
				BEGIN
					---- READ INPUT FILE AND BUILD TEMP TABLE
					WHILE LEN(@txt) > 0
						BEGIN
							SELECT @err = @@ERROR, @tmpTxt = LEFT(@txt, ISNULL(NULLIF(CHARINDEX('~', @txt) - 1, - 1), LEN(@txt))), @txt = SUBSTRING(@txt, ISNULL(NULLIF(CHARINDEX('~', @txt), 0), LEN(@txt)) + 1, LEN(@txt))
							IF LEFT(@tmpTxt, 2) IN ('GS') ---- FILE DATA
								BEGIN
									-- SELECT REPLACE(LEFT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-1),'|',''), 
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)-CHARINDEX('|',@tmpTxt,1)-1),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-1)),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1))),
									-- LTRIM(RTRIM(@tmpTxt))
									SET @Sender = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
									SET @Receiver = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1)))
									SET @issueDate = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1)))
									SET @ediVersion = ISNULL(( SELECT EDIVersion FROM dbo.Vendor_SAN_Codes WHERE SANCode = @Sender ), @ediVersion)
									SET @GSNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1)))

									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 2) IN ('ST') ---- FILE DATA
								BEGIN
									-- SELECT REPLACE(LEFT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-1),'|',''), 
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)-CHARINDEX('|',@tmpTxt,1)-1),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-1)),
									-- LTRIM(RTRIM(@tmpTxt))
									SET @_FileType = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1)
									-- SET @issueDate = SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)))
									SET @STACKNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))

									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('BAK') ---- PO HDR DATA
								BEGIN
									-- SELECT REPLACE(LEFT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-1),'|',''), 
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)-CHARINDEX('|',@tmpTxt,1)-1),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-1)),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1))),
									-- LTRIM(RTRIM(@tmpTxt))
									SET @filePO = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1)))
									SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO, '-', ''), 'reship', '')))
									SET @issueDate = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1)))
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('ACK') ---- PO DTL DATA
								BEGIN
									SET @LineSts = ''
									SET @LineQty = 0

									IF LEN(@tmpTxt) >= 10
									BEGIN
										-- SELECT REPLACE(LEFT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-1),'|',''), 
										-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)-CHARINDEX('|',@tmpTxt,1)-1),
										-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-1)),
										-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1))),
										-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1))),
										-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1))),
										-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1))),
										-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1))),
										-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1))),
										-- LTRIM(RTRIM(@tmpTxt))
										SET @curID = @lastID -- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1)))
										SET @LineQty = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
										SET @LineSts = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1)
										SET @LineCode = RIGHT(REPLACE(REPLACE(@tmpTxt, CHAR(13), ''), CHAR(10), ''), 2)

										UPDATE @ACKDtl
										SET AckQty = @LineQty, ShipQty = @LineQty, LineSts = @LineSts, LineCode = @LineCode
										WHERE ItemID = @curID

										IF @err = 0 SET @err = @@ERROR
									END
								ELSE IF LEN(@tmpTxt) < 10
									BEGIN
										SET @LineCode = ''
										-- SELECT REPLACE(LEFT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-0),'|',''), REPLACE(RIGHT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-1),'|',''),REPLACE(RIGHT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-1),'|','')
										SET @LineCode = REPLACE(RIGHT(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) - 1), '|', '')

										UPDATE @ACKDtl
											SET LineCode = @LineCode
										WHERE ItemID = @curID
										IF @err = 0 SET @err = @@ERROR
									END
							END
							ELSE IF LEFT(@tmpTxt, 2) IN ('PO') ---- PO DTL DATA
								BEGIN
									-- SELECT REPLACE(LEFT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-1),'|',''), 
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)-CHARINDEX('|',@tmpTxt,1)-1),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-1)),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1))),
									-- LTRIM(RTRIM(@tmpTxt))
									IF EXISTS ( SELECT POnumber FROM BLK.PurchaseOrderHeader WHERE ponumber = @filePO )
										BEGIN
											INSERT INTO @ACKHdrs (	 [TypeCode],[Sender],[Receiver],[FileType],[IssueDate],[FilePO]
																	,[STIDNo],[GSNo])
												SELECT	 'ACK', @Sender AS [Sender], @Receiver AS [Receiver], @fileType AS [FileType], @issueDate AS [IssueDate], @filePO AS [FilePO]
														,@STACKNo AS [STIDNo], @GSNo AS [GSNo]
												WHERE @filePO NOT IN ( SELECT DISTINCT FilePO FROM @ACKHdrs )

											INSERT INTO @ACKDtl ([PONumber]
																,[LineNum]
																,[Qty]
																,[UOM]
																,[UnitPrice]
																,[PriceCode]
																,[ItemIDCode]
																,[ItemID]
																,[AckQty],[ShipQty],[CanQty],[BakQty],[LineSts],[LineCode])
												SELECT	 @FilePO AS [PONumber]
														,RIGHT(SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1), 4) AS [LineNum]
														,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1)) AS [Qty]
														,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1))) AS [UOM]
														,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))) AS [UnitPrice]
														,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1))) AS [PriceCode]
														,CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1)  + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) = 'EN' 
																THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
																ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1))) END, CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) = 'EN' THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
														 END AS [ItemID]
														,0 AS [AckQty],0 AS [ShipQty],0 AS [CanQty],0 AS [BakQty],'' AS [LineSTS],'' AS [LineCode]

												SET @lastID = CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) = 'EN' 
																		THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
																		ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
																END
											IF @err = 0 SET @err = @@ERROR
										END
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('IEA') ---- PO HDR DATA
								SET @ACKRef = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1)
						END
				END
			ELSE IF LTRIM(RTRIM(@fileType)) = '856' ---- READ IN ASN FILE
				BEGIN
					---- READ INPUT FILE AND BUILD TEMP TABLE
					WHILE LEN(@txt) > 0
					BEGIN
						SET @tmpTxt = LEFT(@txt, ISNULL(NULLIF(CHARINDEX('~', @txt) - 1, - 1), LEN(@txt)))
						SET @txt = SUBSTRING(@txt, ISNULL(NULLIF(CHARINDEX('~', @txt), 0), LEN(@txt)) + 1, LEN(@txt))

						IF LEFT(@tmpTxt, 2) IN ('GS') ---- FILE DATA
							BEGIN
								SELECT	 @Sender = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1)), @Receiver = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1)))
										,@ediVersion = ISNULL((SELECT EDIVersion FROM dbo.Vendor_SAN_Codes WHERE SANCode = @Sender ), @ediVersion)
										,@GSNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1)))
								IF @err = 0 SET @err = @@ERROR
							END
						ELSE IF LEFT(@tmpTxt, 2) IN ('ST') ---- FILE DATA
							BEGIN
								SET @_FileType = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1)
								SET @STASNNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))

								IF @err = 0 SET @err = @@ERROR
							END
						ELSE IF LEFT(@tmpTxt, 3) IN ('TD5') ---- FILE DATA
							BEGIN
								SET @carrier = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 50 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1)))
								IF @ediVersion = '3060' AND @Sender = '8600023' ---- SCHOLASTIC
									SET @carrier = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1)))
								IF @ediVersion = '3060' AND @Sender = '2002086' ---- HARPERCOLLINS
									SET @carrier = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1)))
							END
						ELSE IF LEFT(@tmpTxt, 3) IN ('PRF') ---- PO HDR DATA
							BEGIN
								--  IF @ediVersion='3060' AND @Sender<>'2153793'
								--	BEGIN
								--		SET @filePO = SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)-CHARINDEX('|',@tmpTxt,1)-1)
								--		SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
								--	END
								-- ELSE IF @ediVersion='3060' AND @Sender='2153793'
								--	BEGIN
								--		SET @filePO=SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,6)
								--		SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
								--	END
								-- ELSE IF @ediVersion='4010'
								--	BEGIN
								--		SET @filePO=SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,6)
								--		SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
								--	END
								SELECT @PRFNumSep = LEN(@tmpTxt) - LEN(REPLACE(@tmpTxt, '|', ''))
								IF @ediVersion = '3060'
									IF @PRFNumSep = 1 ---- SENDER SOULD BE HOUGHTON MIFFLIN DISTRIBUTION - 2153793  OR MACMILLAN DISTRIBUTION	- 6315011
										BEGIN
											SET @filePO = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, 6)
											SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO, '-', ''), 'reship', '')))
										END
									ELSE
										BEGIN
											SET @filePO = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1)
											SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO, '-', ''), 'reship', '')))
										END
								ELSE IF @ediVersion = '4010'
									BEGIN
										IF @PRFNumSep = 1
											BEGIN
												SET @filePO = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, 6)
												SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO, '-', ''), 'reship', '')))
											END
									END
								IF @err = 0 SET @err = @@ERROR
								SET @PRFNumSep = 0
							END
						ELSE IF LEFT(@tmpTxt, 3) IN ('REF') ---- PO HDR DATA
							BEGIN
								---- IDMACMDIST & IDS&SDISTR
								IF @ediVersion = '3060' OR @Sender IN ('6315011', '2002442')
									SET @fileASN = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 + 1 + 1))
								IF @err = 0 SET @err = @@ERROR
							END
						ELSE IF LEFT(@tmpTxt, 3) IN ('PEF') ---- RANDOMHOUSE
							IF @ediVersion = '4010'
								SET @fileASN = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 + 1 + 1))
							ELSE IF LEFT(@tmpTxt, 3) IN ('RRE') ---- HARPERCOLLINS
								IF @ediVersion = '3060'
									SET @trkNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 + 15))
								ELSE
									SET @trkNo = ''
							ELSE IF LEFT(@tmpTxt, 3) IN ('DTM') ---- FILE DATA
								SET @issueDate = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
							ELSE IF LEFT(@tmpTxt, 3) IN ('CUR') --PO Hdr data
								BEGIN
									SET @amtCode = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('MAN') ---- PO HDR DATA
								BEGIN
									IF @ediVersion = '3060' AND @Sender NOT IN ('2002086', '8600023') ---- NOT HARPERCOLLINS OR SCHOLASTIC
										BEGIN
											SET @pkgNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
											SET @trkNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1)))
											IF @pkgNo = @trkNo
												BEGIN
													SET @pkgNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 + 15))
													SET @trkNo = ''
												END
										END
									ELSE IF @ediVersion = '3060' AND @Sender IN ('2002086', '8600023') ---- HARPERCOLLINS & SCHOLASTIC
										SET @pkgNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 + 15))
									ELSE IF @ediVersion = '4010'
										BEGIN
											SET @pkgNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
											SET @trkNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1)))
											IF @pkgNo = @trkNo
												BEGIN
													SET @trkNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 + 15))
													SET @pkgNo = ''
												END
										END
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('LIN') ---- PO DTL DATA
								BEGIN
									INSERT INTO @ASNHdrs (	 [TypeCode],[Sender],[Receiver],[FileType],[IssueDate],[FilePO]
															,[FileASN],[AmtCode],[Carrier],[STIDNo],[GSNo])
										SELECT	 'ASN' AS [TypeCode],@Sender AS [Sender],@Receiver AS [Receiver],@fileType AS [FileType],@issueDate AS [IssueDate],@filePO AS [FilePO]
												,@fileASN AS [FileASN], @amtCode AS [AmtCode], @carrier AS [Carrier], @STASNNo AS [STIDNo], @GSNo AS [GSNo]
										WHERE @filePO NOT IN ( SELECT DISTINCT FilePO FROM @ASNHdrs ) 
											-- AND @filePO NOT IN (SELECT DISTINCT FilePO FROM @ASNHdrs)		  

									INSERT INTO @ASNDtl (	 [PONumber],[LineNum],[Qty],[UOM],[UnitPrice],[PriceCode]
															,[ItemIDCode]
															,[ItemID]
															,[AckQty],[ShipQty],[CanQty],[BakQty],[LineSts],[LineCode],[PkgNo],[TrkNo])
										SELECT	 @FilePO AS [PONumber], '' AS [LineNum], '' AS [Qty], '' AS [UOM], '' AS [UnitPrice], '' AS [PriceCode]
												,CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))) = 'EN' 
														THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))) 
														ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1)) 
												  END AS [ItemIDCode]
												 ,CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))) = 'EN' 
														THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1))) 
														ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))) 
												  END AS [ItemID]
												 ,0 AS [AckQty],0 AS [ShipQty],0 AS [CanQty],0 AS [BakQty],'' AS [LineSTS],'' AS [LineCode],@pkgNo AS [PkgNo],@trkNo AS [TrkNo]

									SET @lastID = CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))) = 'EN' 
															THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1))) 
															ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))) 
												  END
									SET @lastTracking = CASE WHEN @pkgNo = '' THEN @trkNo ELSE @pkgNo END
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('SN1') ---- PO DTL DATA
								BEGIN
									SELECT	 @LineSts = ''
											,@LineQty = 0
									SELECT	 @curID = @lastID -- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1)+1)))
											,@LineQty = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1)), @UOM = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1)))

									UPDATE @ASNDtl
										SET	 Qty = @LineQty
											,ShipQty = @LineQty
											,UOM = CASE WHEN LEN(@UOM) > 2 THEN LEFT(@UOM, 2) ELSE @UOM END
									WHERE ItemID = @curID
										AND PONumber = @filePO
										AND @lastTracking IN (PkgNo, TrkNo)
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('IEA') ---- PO HDR DATA
								BEGIN
									SET @ASNRef = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1)
										-- SELECT @ASNRef
								END
					END
				END
			ELSE IF LTRIM(RTRIM(@fileType)) = '810' ---- READ IN INVOICE FILE
				BEGIN
					---- READ INPUT FILE AND BUILD TEMP TABLE
					WHILE LEN(@txt) > 0
						BEGIN
							SELECT @tmpTxt = LEFT(@txt, ISNULL(NULLIF(CHARINDEX('~', @txt) - 1, - 1), LEN(@txt))), @txt = SUBSTRING(@txt, ISNULL(NULLIF(CHARINDEX('~', @txt), 0), LEN(@txt)) + 1, LEN(@txt))
							-- SELECT @tmpTxt
							IF LEFT(@tmpTxt, 2) IN ('GS') ---- FILE DATA
								BEGIN
									SELECT	 @Sender = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1)), @Receiver = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1)))
											,@ediVersion = ISNULL(( SELECT EDIVersion FROM dbo.Vendor_SAN_Codes WHERE SANCode = @Sender ), @ediVersion)
											,@GSNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1)))
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 2) IN ('ST') ---- FILE DATA
								SELECT @_FileType = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1), @STINVNo = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
							ELSE IF LEFT(@tmpTxt, 3) IN ('BIG') ---- PO HDR DATA
								BEGIN
									SET @fileInv = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
									SET @filePO = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1)))
									SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO, '-', ''), 'reship', '')))
									IF @ediVersion = '4010'
										SET @issueDate = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1)
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('DTM') ---- FILE DATA
								BEGIN
									IF @ediVersion = '3060'
										SET @issueDate = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('CUR') ---- PO HDR DATA
								BEGIN
									IF @ediVersion = '3060'
										SET @amtCode = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
									ELSE IF @ediVersion = '4010'
										SET @amtCode = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('CTP') ---- PO HDR DATA
								BEGIN
									SET @DisPct = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1)))
									SET @RetAmt = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1)))

									UPDATE @INVHdrs
										SET	 AmtCode = @amtCode
											,DisPct = @DisPct
									WHERE FilePO = @filePO

									UPDATE @INVDtl
										SET RetAmt = @RetAmt
									WHERE ItemID = @lastID
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('SAC') ---- FILE DATA
								BEGIN
									SET @chrgCode = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1))
									SET @addChrg = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1)))
									SET @addChrg = CASE LEN(@addChrg) WHEN 1 THEN '000' + @addChrg WHEN 2 THEN '00' + @addChrg WHEN 3 THEN '0' + @addChrg ELSE @addChrg END

									IF NOT EXISTS ( SELECT PONumber FROM @INVAdds WHERE PONumber = @filePO AND FileINV = @fileInv AND ChargeCode = @chrgCode ) AND CAST(@addChrg AS INT) <> 0
										INSERT INTO @INVAdds (PONumber, FileINV,ChargeCode,ChargeAmt)
											SELECT @filePO AS [PONumber], @fileInv AS [FileINV], @chrgCode AS [ChargeCode], @addChrg AS [ChargeAmt]
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('TDS') ---- PO HDR DATA
								BEGIN
									-- SELECT REPLACE(LEFT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)-1),'|',''), REPLACE(RIGHT(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1),'|','')
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)-CHARINDEX('|',@tmpTxt,1)-1)
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-1)),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1))),
									-- SUBSTRING(@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,CHARINDEX('|',@tmpTxt,1)+1)+1)+1)+1)+1)+1)+1))),
									-- LTRIM(RTRIM(@tmpTxt))
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('IT1') ---- PO DTL DATA
								BEGIN
									--IF EXISTS(SELECT POnumber FROM dbo.[850_PO_Hdr] WHERE ponumber=@filePO)
									--BEGIN
									INSERT INTO @INVHdrs (	 TypeCode, Sender, Receiver, FileType, IssueDate, FilePO
															,FileINV, AmtCode, DisPct, STIDNo, GSNo)
										SELECT	 'INV' AS [TypeCode], @Sender AS [Sender], @Receiver AS [Receiver], @fileType AS [FileType], @issueDate AS [IssueDate], @filePO AS [FilePO]
												,@fileINV AS [FileINV],@amtCode AS [AmtCode], @DisPct AS [DisPct], @STINVNo AS [STIDNo], @GSNo AS [GSNo]
										WHERE @fileInv NOT IN ( SELECT DISTINCT FileINV FROM @INVHdrs ) 
											-- AND @filePO NOT IN (SELECT DISTINCT FilePO FROM @INVHdrs)

									INSERT INTO @INVDtl (PONumber, LineNum,Qty,UOM,UnitPrice,PriceCode,ItemIDCode,ItemID,FileINV,RetAmt)
										SELECT	 @FilePO AS [PONumber]
												,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1), SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1)), SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1))), SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, 
														CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))), SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1))), CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 
																			CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) = 'EN' THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 
																			CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1))) END, CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', 
																					@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) = 'EN' THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 
																				CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 
																		CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) END, @fileInv, @RetAmt

									INSERT INTO @INVDtl (PONumber,LineNum,Qty,UOM,UnitPrice,PriceCode,ItemIDCode,ItemID,FileINV,RetAmt)
										SELECT	 @FilePO AS [PONumber]
												,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) - CHARINDEX('|', @tmpTxt, 1) - 1) AS [LineNum]
												,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - 1)) AS [Qty]
												,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1))) AS [UOM]
												,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1))) AS [UnitPrice]
												,SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1))) AS [PriceCode]
												,CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) = 'EN' 
														THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
														ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
												 END AS [ItemIDCode]
												,CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) = 'EN' 
														THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
														ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
												 END AS [ItemID]
												,@fileInv AS [FileINV],@RetAmt AS [RetAmt]
									SET @lastID = CASE WHEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) = 'EN' 
														THEN SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
														ELSE SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1) + 1) + 1) + 1))) 
												   END
									IF @err = 0 SET @err = @@ERROR
											
								END
							ELSE IF LEFT(@tmpTxt, 3) IN ('IEA') ---- PO HDR DATA
								BEGIN
									SET @InvRef = SUBSTRING(@tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1, ABS(CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1 - CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, CHARINDEX('|', @tmpTxt, 1) + 1) + 1) + 1) + 1)
									-- SELECT @InvRef
								END
						END
				END
			---- INSERT INTO DB FROM TEMP TABLE
			DECLARE @id INT = 0

			IF LTRIM(RTRIM(@fileType)) = '855' AND LTRIM(RTRIM(@_FileType)) = '855'
				BEGIN
					---- ACK
					DECLARE @ACKloop INT
					SELECT @ACKloop = COUNT(DISTINCT FilePO) FROM @ACKHdrs

					WHILE @ACKloop > 0
						BEGIN
							DECLARE  @curACKPO VARCHAR(12)
									,@curACKSend VARCHAR(20)
									,@curACKRecv VARCHAR(20)
									,@curACKIssueDtm VARCHAR(20)
									,@curACKamtCode VARCHAR(6)
									,@curACKSTNo VARCHAR(10)
									,@curACKGSNo VARCHAR(10)

							SELECT	 @curACKPO = FilePO
									,@curACKSend = Sender
									,@curACKRecv = Receiver
									,@curACKIssueDtm = IssueDate
									,@curACKSTNo = STIDNo
									,@curACKGSNo = GSNo
							FROM @ACKHdrs
							WHERE RowID = @ACKloop

							---- SET @ACKDTL QUANTITIES
							UPDATE p
								SET p.CanQty = CASE WHEN VendorID IN ('IDINGRAMDI','IDINGRAMWEB')
													THEN CASE WHEN ISNULL(p.Qty, 0) - ISNULL(p.AckQty, 0) < 0 THEN 0 ELSE ISNULL(p.Qty, 0) - ISNULL(p.AckQty, 0) END
													ELSE 0
											   END
							FROM @ACKDtl p
								LEFT JOIN BLK.PurchaseOrderHeader ph -- dbo.[850_PO_Hdr] ph 
									ON p.PONumber = ph.PONumber
								LEFT JOIN BLK.PurchaseOrderDetail pd -- dbo.[850_PO_Dtl] pd 
									ON ph.OrderID = pd.OrderID
										AND p.ItemID = pd.ItemIdentifier
							WHERE p.PONumber = @curACKPO
							IF @err = 0 SET @err = @@ERROR

							BEGIN TRANSACTION

							---- INSERT HEADER INFO AND GET IDENTITY
							INSERT INTO BLK.AcknowledgeHeader (	 PONumber,IssueDate,VendorID,ReferenceNo,ShipToLoc,ShipToSAN
																,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN
																,TotalLines
																,TotalQuantity
																,CurrencyCode,InsertDateTime,Processed,ProcessedDateTime
																,ResponseACKSent,ResponseAckNo,GSNo)
								SELECT	 ph.PONumber AS [PONumber], @curACKIssueDtm AS [IssueDate], ph.VendorID, @ACKRef AS [RefrenceNo], ph.ShipToLoc, ph.ShipToSAN
										,ph.BillToLoc, ph.BillToSAN, ph.ShipFromLoc, ph.ShipFromSAN
										,(SELECT COUNT(LineNum) FROM @ACKDtl WHERE PONumber = @curACKPO ) AS [TotalLines]
										,CASE WHEN ph.VendorID IN ('IDINGRAMDI','IDINGRAMWEB')
												THEN (SELECT SUM(AckQty) FROM @ACKDtl WHERE PONumber = @curACKPO ) 
												ELSE (SELECT TOP 1 TotalQuantity FROM BLK.PurchaseOrderHeader WHERE PONumber = @curACKPO ) 
										 END AS [TotalQuantity]
										,@curACKamtCode AS [CurrencyCode], GETDATE() AS [InsertDateTime], 0 AS [Processed], NULL AS [ProcessedDateTime]
										,0 AS [ResonseACKSent], @curACKSTNo AS [ResponseACKNo], @curACKGSNo AS [GSNo]
								FROM BLK.PurchaseOrderHeader ph -- dbo.[850_PO_Hdr] ph 
								WHERE ph.ponumber = @curACKPO
									AND REPLACE(ph.ShipFromSAN, '-', '') = REPLACE(@curACKSend, '-', '') 
									-- AND REPLACE(ph.ShipToSAN,'-','')=REPLACE(@Receiver,'-','')
							IF @err = 0 SET @err = @@ERROR
							SET @id = @@IDENTITY

							---- INSERT DETAIL INFO
							IF ISNULL(@id, 0) <> 0 AND @err = 0
								BEGIN
									INSERT INTO BLK.AcknowledgeDetail (	 AckID, [LineNo], LineStatusCode, ItemStatusCode, UnitOfMeasure
																		,QuantityOrdered, QuantityShipped
																		,QuantityCancelled
																		,QuantityBackordered
																		,UnitPrice, PriceCode, CurrencyCode, ItemIDCode, ItemIdentifier)
										SELECT	 @id AS [AckID], p.LineNum AS [LineNo], p.LineSts AS [LineStatusCode], p.LineCode AS [ItemStatusCode], p.UOM AS [UnitOfMesuare]
												,p.AckQty AS [QuantiyOrdered], p.ShipQty AS [QuantityShipped]
												,CASE WHEN p.LineCode LIKE 'B%' OR p.LineCode = 'IB' 
														THEN 0 
														ELSE p.CanQty 
												 END AS [CanQty]
												,CASE WHEN p.LineCode LIKE 'B%' OR p.LineCode = 'IB' 
														THEN p.CanQty 
														ELSE p.BakQty 
												 END AS [BakQty]
												,p.UnitPrice, p.PriceCode, @amtCode AS [CurrencyCode], p.ItemIDCode, p.ItemID AS [ItemIdentifier]
										FROM @ACKDtl p
										WHERE p.PONumber = @curACKPO
									IF @err = 0 SET @err = @@ERROR
								END

							IF @err = 0
								COMMIT TRANSACTION VX_ReqSubmit
							ELSE
								ROLLBACK TRANSACTION VX_ReqSubmit

							SET @ACKloop = @ACKloop - 1
						END
				END					
			ELSE IF LTRIM(RTRIM(@fileType)) = '856' AND LTRIM(RTRIM(@_FileType)) = '856'
				BEGIN
					---- ASN
					DECLARE @ASNloop INT
					SELECT @ASNloop = COUNT(DISTINCT FileASN) FROM @ASNHdrs

					WHILE @ASNloop > 0
						BEGIN
							DECLARE	 @curASNPO VARCHAR(12)
									,@curASNSend VARCHAR(20)
									,@curASNRecv VARCHAR(20)
									,@curASNIssueDtm VARCHAR(20)
									,@curASNamtCode VARCHAR(6)
									,@curASN VARCHAR(20)
									,@curCar VARCHAR(20)
									,@curASNSTNo VARCHAR(10)
									,@curASNGSNo VARCHAR(10)

							SELECT	 @curASNPO = FilePO
									,@curASN = FileASN
									,@curASNSend = Sender
									,@curASNRecv = Receiver
									,@curASNIssueDtm = IssueDate
									,@curASNamtCode = AmtCode
									,@curCar = LTRIM(RTRIM(REPLACE(Carrier, ' ', '')))
									,@curASNSTNo = STIDNo
									,@curASNGSNo = GSNo
							FROM @ASNHdrs
							WHERE RowID = @ASNloop

							BEGIN TRANSACTION

							IF EXISTS ( SELECT PONumber FROM BLK.PurchaseOrderHeader WHERE PONumber = @curASNPO ) -- dbo.[850_PO_Hdr] WHERE PONumber=@curASNPO)
								BEGIN
									---- SET @ACKDTL QUANTITIES
									UPDATE p
										SET	 p.LineNum = pd.[LineNo]
											,p.UnitPrice = pd.UnitPrice
											,p.PriceCode = pd.PriceCode
									FROM @ASNDtl p
										LEFT JOIN BLK.PurchaseOrderHeader ph -- dbo.[850_PO_Hdr] ph 
											ON p.PONumber = ph.PONumber
										LEFT JOIN BLK.PurchaseOrderDetail pd -- dbo.[850_PO_Dtl] pd 
											ON ph.OrderID = pd.OrderID
												AND p.ItemID = pd.ItemIdentifier
									WHERE p.PONumber = @curASNPO
									IF @err = 0 SET @err = @@ERROR

									---- INSERT HEADER INFO AND GET IDENTITY
									INSERT INTO BLK.ShipmentHeader ( [PONumber],[ASNNo],[IssueDate],[VendorID],[ReferenceNo]
																	,[ShipToLoc],[ShipToSAN],[BillToLoc],[BillToSAN],[ShipFromLoc],[ShipFromSAN],[Carrier]
																	,[TotalLines]
																	,[TotalQuantity]
																	,[CurrencyCode],[InsertDateTime],[Processed],[ProcessedDateTime],[ASNACKSent],[ASNAckNo],[GSNo])
										SELECT	 ph.PONumber, @curASN AS [ASNo], @curASNIssueDtm AS [IssueDate], ph.VendorID, @ASNRef AS [ReferenceNo]
												,ph.ShipToLoc, ph.ShipToSAN, ph.BillToLoc, ph.BillToSAN, ph.ShipFromLoc, ph.ShipFromSAN, LEFT(@curCar, 20) AS [Carrier]
												,(SELECT COUNT(LineNum) FROM @ASNDtl WHERE PONumber = @curASNPO ) AS TotalLines
												,(SELECT SUM(ShipQty) FROM @ASNDtl WHERE PONumber = @curASNPO ) AS TotalQuantity
												,@curASNamtCode AS [CurrencyCode], GETDATE() AS [InsertDateTime], 0 AS [Processed], NULL AS [ProcessedDateTime]
												,0 AS [ASNACKSent], @curASNSTNo AS [ASNAckNo], @curASNGSNo AS [GSNo]
										FROM BLK.PurchaseOrderHeader ph -- dbo.[850_PO_Hdr] ph 
										WHERE ph.ponumber = @curASNPO
											AND REPLACE(ph.ShipFromSAN, '-', '') = REPLACE(@curASNSend, '-', '')
											-- AND REPLACE(ph.ShipToSAN,'-','')=REPLACE(@Receiver,'-','')								
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE IF NOT EXISTS ( SELECT PONumber FROM BLK.PurchaseOrderHeader WHERE PONumber = @curASNPO ) AND LEN(@curASNPO) > 6 -- dbo.[850_PO_Hdr] WHERE PONumber=@curASNPO) AND LEN(@curASNPO)>6
								BEGIN
									INSERT INTO BLK.ShipmentHeader ( [PONumber],[ASNNo],[IssueDate],[VendorID],[ReferenceNo]
																	,[ShipToLoc],[ShipToSAN],[BillToLoc],[BillToSAN],[ShipFromLoc],[ShipFromSAN],[Carrier]
																	,[TotalLines]
																	,[TotalQuantity]
																	,[CurrencyCode],[InsertDateTime],[Processed],[ProcessedDateTime]
																	,[ASNACKSent],[ASNAckNo],[GSNo])
										SELECT	 'F' + RIGHT(@ASNRef, 5) AS [PONumber],@curASN AS [ASNNo], @curASNIssueDtm AS [IssueDate], v.VendorID, @ASNRef AS [ReferenceNo]
												,s1.LocationNo AS [ShipToLoc], s1.SANCode AS [ShipToSAN], s2.LocationNo AS [BillToLoc], s2.SANCode AS [BillToSAN]
												,'VEND' AS [ShipFromLoc], v.SANCode AS [ShipFromSAN], LEFT(@curCar, 20) AS [Carrier]
												,(SELECT COUNT(LineNum) FROM @ASNDtl WHERE PONumber = @curASNPO ) AS [TotalLines]
												,(SELECT SUM(ShipQty) FROM @ASNDtl WHERE PONumber = @curASNPO ) AS [TotalQuantity]
												,@curASNamtCode AS [CurrencyCode], GETDATE() AS [InsertDateTime], 0 AS [Processed], NULL AS [ProcessedDateTime]
												,0 AS [ASNACKSent] , @curASNSTNo AS [ASNAckNo], @curASNGSNo AS [GSNo]
										FROM @ASNHdrs h
											INNER JOIN dbo.Vendor_SAN_Codes v
												ON REPLACE(h.Sender, '-', '') = REPLACE(v.SANCode, '-', '')
											INNER JOIN dbo.HPB_SAN_Codes s1
												ON REPLACE(h.Receiver, '-', '') = REPLACE(s1.SANCode, '-', '')
											INNER JOIN dbo.HPB_SAN_Codes s2
												ON s2.LocationNo = 'HPBCA'
										WHERE h.FilePO = @curASNPO
											AND REPLACE(h.Sender, '-', '') = REPLACE(@curASNSend, '-', '')
											AND h.FileASN NOT IN ( SELECT DISTINCT ReferenceNo FROM BLK.ShipmentHeader )
											-- AND h.FileASN NOT IN (SELECT DISTINCT ReferenceNo FROM dbo.[856_ASN_Hdr])								
									IF @err = 0 SET @err = @@ERROR
								END
							ELSE
								BEGIN
									INSERT INTO BLK.ShipmentHeader ([PONumber],[ASNNo],[IssueDate],[VendorID],[ReferenceNo]
																	,[ShipToLoc],[ShipToSAN],[BillToLoc],[BillToSAN]
																	,[ShipFromLoc],[ShipFromSAN],[Carrier]
																	,[TotalLines]
																	,[TotalQuantity]
																	,[CurrencyCode],[InsertDateTime],[Processed],[ProcessedDateTime]
																	,[ASNACKSent],[ASNAckNo],[GSNo])
										SELECT	 h.FilePO AS [PONumber], @curASN AS [ASNNo], @curASNIssueDtm AS [IssueDate], v.VendorID, @ASNRef AS [ReferenceNo]
												,s1.LocationNo AS [ShipToLoc], s1.SANCode AS [ShipToSAN], s2.LocationNo AS [BillToLoc], s2.SANCode AS [BillToSAN]
												, 'VEND' AS [ShipFromLoc], v.SANCode AS [ShipFromSAN], LEFT(@curCar, 20) AS [Carrier]
												,(SELECT COUNT(LineNum) FROM @ASNDtl WHERE PONumber = @curASNPO ) AS [TotalLines]
												,(SELECT SUM(ShipQty) FROM @ASNDtl WHERE PONumber = @curASNPO ) AS [TotalQuantity]
												,@curASNamtCode AS [CurrencyCode], GETDATE() AS [InsertDateTime], 0 AS [Processed], NULL AS [ProcesseDateTime]
												,0 AS [ASNAckNo], @curASNSTNo AS [ASNAckNo], @curASNGSNo AS [GSNo]
										FROM @ASNHdrs h
											INNER JOIN dbo.Vendor_SAN_Codes v
												ON REPLACE(h.Sender, '-', '') = REPLACE(v.SANCode, '-', '')
											INNER JOIN dbo.HPB_SAN_Codes s1
												ON REPLACE(h.Receiver, '-', '') = REPLACE(s1.SANCode, '-', '')
											INNER JOIN dbo.HPB_SAN_Codes s2
												ON s2.LocationNo = 'HPBCA'
										WHERE h.FilePO = @curASNPO
											AND REPLACE(h.Sender, '-', '') = REPLACE(@curASNSend, '-', '')
											AND h.FileASN NOT IN ( SELECT DISTINCT ReferenceNo FROM BLK.ShipmentHeader ) -- dbo.[856_ASN_Hdr])								
									IF @err = 0 SET @err = @@ERROR
								END
							SET @id = @@IDENTITY

							---- INSERT DETAIL INFO
							IF ISNULL(@id, 0) <> 0 AND @err = 0
								BEGIN
									INSERT INTO BLK.ShipmentDetail ( [ShipmentID]
																	,[LineNo]
																	,[ItemIDCode],[ItemIdentifier],[QuantityShipped],[PackageNo],[TrackingNo])
										SELECT	 @id AS [ShipmentID]
												,CASE WHEN LTRIM(RTRIM(ISNULL(p.LineNum, ''))) = '' 
														THEN ISNULL(ROW_NUMBER() OVER (PARTITION BY [PONumber] ORDER BY [PONumber]), '') 
														ELSE p.LineNum END AS [LineNo]
												,p.ItemIDCode, p.ItemID AS [ItemIdentifier], p.ShipQty AS [QuantityShipped], p.PkgNo AS [PackageNo], p.TrkNo AS [TrackingNo]
										FROM @ASNDtl p
										WHERE p.POnumber = @curASNPO
									IF @err = 0 SET @err = @@ERROR
								END

							IF @err = 0
								COMMIT TRANSACTION VX_ReqSubmit
							ELSE
								ROLLBACK TRANSACTION VX_ReqSubmit
							SET @ASNloop = @ASNloop - 1
						END

					---- UPDATE ANY INVOICES THAT THE ORDER ORIGINATED IN DIPS
					-- IF EXISTS (SELECT i.PONumber FROM dbo.[856_ASN_Hdr] i INNER JOIN (SELECT PONumber,LocationNo FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r ON i.PONumber=r.PONumber
					--			INNER JOIN dbo.HPB_SAN_Codes s ON s.LocationNo=r.LocationNo WHERE i.ShipToLoc='00944' AND i.Processed=0 AND ISNUMERIC(i.PONumber)=1)
					IF EXISTS (	SELECT i.PONumber
								FROM (	SELECT ih.PONumber
										FROM BLK.InvoiceHeader ih
										WHERE ih.Processed = 0
											AND ih.ShipToLoc = '00944'
											AND ISNUMERIC(ih.PONumber) = 1) i
									INNER JOIN (SELECT PONumber, LocationNo
												FROM OPENDATASOURCE ('SQLOLEDB', 'Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r
										ON i.PONumber = r.PONumber
									INNER JOIN dbo.HPB_SAN_Codes s
										ON s.LocationNo = r.LocationNo)
					BEGIN
						UPDATE i
							SET	 i.ShipToLoc = r.LocationNo
								,i.ShipToSAN = s.SANCode
						FROM BLK.InvoiceHeader i
							INNER JOIN (SELECT PONumber, LocationNo
										FROM OPENDATASOURCE ('SQLOLEDB', 'Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader ) r
								ON i.PONumber = r.PONumber
							INNER JOIN dbo.HPB_SAN_Codes s
								ON s.LocationNo = r.LocationNo
						WHERE i.ShipToLoc = '00944'
							AND i.Processed = 0
							AND ISNUMERIC(i.PONumber) = 1
					END
				END				
			ELSE IF LTRIM(RTRIM(@fileType)) = '810' AND LTRIM(RTRIM(@_FileType)) = '810'
				BEGIN
					---- INV
					DECLARE @INVloop INT
					SELECT @INVloop = COUNT(DISTINCT FileINV) FROM @INVHdrs

					WHILE @INVloop > 0
						BEGIN
							DECLARE	 @curINVPO VARCHAR(12)
									,@curINVSend VARCHAR(20)
									,@curINVRecv VARCHAR(20)
									,@curINVIssueDtm VARCHAR(20)
									,@curINVamtCode VARCHAR(6)
									,@curINV VARCHAR(20)
									,@curINVDisPct VARCHAR(6)
									,@curINVSTNo VARCHAR(10)
									,@curGSNo VARCHAR(10)

							SELECT	 @curINVPO = FilePO
									,@curINV = FileINV
									,@curINVSend = Sender
									,@curINVRecv = Receiver
									,@curINVIssueDtm = IssueDate
									,@curINVamtCode = ISNULL(AmtCode, 'USD')
									,@curINVDisPct = DisPct
									,@curINVSTNo = STIDNo
									,@curGSNo = GSNo
							FROM @INVHdrs
							WHERE RowID = @INVloop

							---- UPDATE UNIT PRICE FOR HMH SINCE THEY ARE SENDING FULL RETAIL PRICE IN FILES
							IF @curINVSend = '2153793'
								BEGIN
									UPDATE @INVDtl
										SET UnitPrice = CAST(CAST(CAST(UnitPrice AS MONEY) * CAST(@curINVDisPct AS DECIMAL(8, 2)) AS DECIMAL(12, 4)) AS VARCHAR(10))
									WHERE PONumber = @curINVPO
								END

							IF EXISTS ( SELECT a.PONumber
										FROM dbo.[810_Inv_Charges] a
											INNER JOIN @INVAdds b
												ON a.PONumber = b.PONumber
													AND a.InvoiceNo = b.FileINV
													AND a.ChargeCode = b.ChargeCode
										WHERE a.PONumber = @curINVPO )
								BEGIN
									UPDATE b
										SET ChargeAmt = CAST(ISNULL(LEFT(a.ChargeAmt, LEN(a.ChargeAmt) - 2) + '.' + RIGHT(a.ChargeAmt, 2), 0) AS DECIMAL(10, 2))
									FROM dbo.[810_Inv_Charges] b
										INNER JOIN @INVAdds a
											ON a.PONumber = b.PONumber
												AND b.InvoiceNo = a.FileINV
												AND a.ChargeCode = b.ChargeCode
									WHERE b.PONumber = @curINVPO
										AND b.InvoiceNo = @curINV
										AND b.ChargeCode = a.ChargeCode
								END
							ELSE
								BEGIN
									INSERT INTO dbo.[810_Inv_Charges]
										SELECT a.PONumber, @curINV, a.ChargeCode, SUM(CAST(ISNULL(LEFT(a.ChargeAmt, LEN(a.ChargeAmt) - 2) + '.' + RIGHT(a.ChargeAmt, 2), 0) AS DECIMAL(10, 2)))
										FROM @INVAdds a
										WHERE a.PONumber = @curINVPO
											AND NOT EXISTS (SELECT PONumber
															FROM dbo.[810_Inv_Charges]
															WHERE PONumber = @curINVPO
																AND InvoiceNo = @curINV
																AND ChargeCode = a.ChargeCode)
										GROUP BY a.PONumber, a.ChargeCode
								END

							SELECT @ToPay = SUM(CAST(Qty AS INT) * CAST(UnitPrice AS MONEY))
							FROM @INVDtl
							WHERE PONumber = @filePO
								AND FileINV = @curINV 

							IF @curINVDisPct IS NULL SET @curINVDisPct = ( SELECT TOP 1 DisPct FROM @INVHdrs WHERE DisPct IS NOT NULL )

							BEGIN TRANSACTION

							---- INSERT HEADER INFO AND GET IDENTITY; CHECK IF PO EXISTS AND DO INSERT
							IF EXISTS ( SELECT PONumber FROM BLK.PurchaseOrderHeader WHERE PONumber = @curINVPO ) --dbo.[850_PO_Hdr] WHERE PONumber=@curINVPO)
								BEGIN
									INSERT INTO BLK.InvoiceHeader (	 [InvoiceNo],[IssueDate],[VendorID],[PONumber],[ReferenceNo],[ShipToLoc],[ShipToSAN]
																	,[BillToLoc],[BillToSAN],[ShipFromLoc],[ShipFromSAN]
																	,[TotalLines]
																	,[TotalQuantity]
																	,[TotalPayable]
																	,[CurrencyCode],[InsertDateTime],[Processed],[ProcessedDateTime]
																	,[InvoiceAckSent],[InvoiceAckNo],[GSNo])
										SELECT	 @curINV AS [InvoiceNo], @curINVIssueDtm AS [IssueDate], ph.VendorID, ph.PONumber, @InvRef AS [ReferenceNo], ph.ShipToLoc, ph.ShipToSAN
												,ph.BillToLoc, ph.BillToSAN, ph.ShipFromLoc, ph.ShipFromSAN
												,(SELECT COUNT(LineNum) FROM @INVDtl WHERE PONumber = @curINVPO AND FileINV = @curINV ) AS [TotalLines]
												,(SELECT SUM(CAST(Qty AS INT)) FROM @INVDtl WHERE PONumber = @curINVPO AND FileINV = @curINV ) AS [TotalQuantity]
												,(SELECT CAST(SUM(CAST(UnitPrice AS DECIMAL(12, 4)) * CAST(Qty AS INT)) AS DECIMAL(12, 4)) FROM @INVDtl WHERE PONumber = @curINVPO AND FileINV = @curINV ) 
													+ ISNULL((SELECT SUM(ChargeAmt) FROM dbo.[810_Inv_Charges] WHERE PONumber = @curINVPO AND InvoiceNo = @curINV), 0) AS [TotalPayable]
												,@curINVamtCode AS [CurrencyCode], GETDATE() AS [InsertDateTime], 0 AS [Processed], NULL AS [ProcessedDateTime]
												,0 AS [InvocieAckSent],@curINVSTNo AS [InvoiceAckNo], @curGSNo AS [GSNo]
										FROM BLK.PurchaseOrderHeader ph --dbo.[850_PO_Hdr] ph 
										WHERE ph.ponumber = @curINVPO
											AND REPLACE(ph.ShipFromSAN, '-', '') = REPLACE(@curINVSend, '-', '')
											AND NOT EXISTS ( SELECT DISTINCT InvoiceNo FROM BLK.InvoiceHeader WHERE InvoiceNo = @curINV) --dbo.[810_Inv_Hdr] WHERE InvoiceNo=@curINV) 
								END
							ELSE ----IF PO does NOT exist THEN pull FROM table variables......................................................
								BEGIN
									INSERT INTO BLK.InvoiceHeader (	 [InvoiceNo],[IssueDate],[VendorID],[PONumber],[ReferenceNo],[ShipToLoc]
																	,[ShipToSAN],[BillToLoc],[BillToSAN],[ShipFromLoc],[ShipFromSAN]
																	,[TotalLines]
																	,[TotalQuantity]
																	,[TotalPayable]
																	,[CurrencyCode],[InsertDateTime],[Processed],[ProcessedDateTime]
																	,[InvoiceAckSent],[InvoiceAckNo],[GSNo])
										SELECT	 h.FileINV AS [InvoiceNo], h.IssueDate, v.VendorID, h.FilePO AS [PONumber], @InvRef AS [ReferenceNo], s1.LocationNo AS [ShipToLoc]
												,s1.SANCode AS [ShipToSan],s2.LocationNo AS [BillToLoc], s2.SANCode AS [BillToSAn], 'VEND' AS [ShipFromLoc], v.SANCode AS [ShipFroSAN]
												,(SELECT COUNT(LineNum) FROM @INVDtl WHERE PONumber = @curINVPO AND FileINV = @curINV ) AS [TotalLines]
												,(SELECT SUM(CAST(Qty AS INT)) FROM @INVDtl WHERE PONumber = @curINVPO AND FileINV = @curINV ) AS [TotalQuantity]
												,(SELECT CAST(SUM(CAST(UnitPrice AS DECIMAL(12, 4)) * CAST(Qty AS INT)) AS DECIMAL(12, 4)) FROM @INVDtl WHERE PONumber = @curINVPO AND FileINV = @curINV) 
													+ ISNULL(( SELECT SUM(ChargeAmt) FROM dbo.[810_Inv_Charges] WHERE PONumber = @curINVPO AND InvoiceNo = @curINV ), 0) AS [TotalPayable]
												,@curINVamtCode AS [CurrencyCode],GETDATE() AS [InsertDateTime], 0 AS [Processed], NULL AS [ProcessedDateTime]
												,0 AS [InvoiceAckSet], @curINVSTNo AS InvocieAckNo , @curGSNo AS GSNo
										FROM @INVHdrs h
											INNER JOIN dbo.Vendor_SAN_Codes v
												ON REPLACE(h.Sender, '-', '') = REPLACE(v.SANCode, '-', '')
											INNER JOIN dbo.HPB_SAN_Codes s1
												ON REPLACE(h.Receiver, '-', '') = REPLACE(s1.SANCode, '-', '')
											INNER JOIN dbo.HPB_SAN_Codes s2
												ON s2.LocationNo = 'HPBCA'
										WHERE h.FilePO = @curINVPO
											AND h.FileINV = @curINV
											AND REPLACE(h.Sender, '-', '') = REPLACE(@curINVSend, '-', '')
											AND NOT EXISTS (SELECT DISTINCT InvoiceNo
															FROM blk.InvoiceHeader
															WHERE InvoiceNo = @curINV ) --dbo.[810_Inv_Hdr] WHERE InvoiceNo=@curINV)
								END
								SET @id = @@IDENTITY

							IF ISNULL(@id, 0) <> 0 AND @err = 0
								BEGIN
									-- INSERT detail info
									INSERT INTO BLK.InvoiceDetail (	 [InvoiceID],[LineNo],[ItemIDCode],[ItemIdentifier],[ItemDesc],[InvoiceQty]
																	,[UnitPrice],[DiscountPrice],[DiscountCode],[DiscountPct]
																	,[RetailPrice])
										SELECT	 @id AS [InvoiceID], p.LineNum AS [LineNo], p.ItemIDCode AS [ItemIDCode], p.ItemID AS [ItemIdentifier], '' AS [ItemDesc], p.Qty AS [InvoiceQty]
												,CAST(CAST(p.UnitPrice AS DECIMAL(12, 2)) AS VARCHAR(6)) AS [UnitPrice], '' AS [DiscountPrice], '' as [DiscountCode], @curINVDisPct AS [DiscountPct]
												,p.RetAmt AS [RetailPrice]
										FROM @INVDtl p
										WHERE p.PONumber = @curINVPO
											AND p.FileINV = @curINV
									IF @err = 0 SET @err = @@ERROR
								END

							IF @err = 0
								COMMIT TRANSACTION VX_ReqSubmit
							ELSE
								ROLLBACK TRANSACTION VX_ReqSubmit

							SET @INVloop = @INVloop - 1
						END

					---- UPDATE ANY INVOICES THAT THE ORDER ORIGINATED IN DIPS
					-- IF EXISTS	(	SELECT i.PONumber 
					-- 				FROM dbo.[810_Inv_Hdr] i 
					-- 					INNER JOIN (SELECT PONumber,LocationNo FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r 
					-- 						ON i.PONumber=r.PONumber
					-- 					INNER JOIN dbo.HPB_SAN_Codes s 
					-- 						ON s.LocationNo=r.LocationNo WHERE i.ShipToLoc='00944' AND i.Processed=0 AND ISNUMERIC(i.PONumber)=1
					-- 			)
					IF EXISTS (	SELECT i.PONumber
								FROM (	SELECT ih.PONumber
										FROM BLK.InvoiceHeader ih
										WHERE ih.ShipToLoc = '00944'
											AND ih.Processed = 0
											AND ISNUMERIC(ih.PONumber) = 1 ) i
									INNER JOIN (SELECT PONumber, LocationNo
												FROM OPENDATASOURCE ('SQLOLEDB', 'Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader ) r
										ON i.PONumber = r.PONumber
									INNER JOIN dbo.HPB_SAN_Codes s
										ON s.LocationNo = r.LocationNo )
					BEGIN
						UPDATE i
							SET	 i.ShipToLoc = r.LocationNo
								,i.ShipToSAN = s.SANCode
						FROM blk.InvoiceHeader i
							INNER JOIN (SELECT PONumber, LocationNo 
										FROM OPENDATASOURCE ('SQLOLEDB', 'Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader ) r
								ON i.PONumber = r.PONumber
							INNER JOIN dbo.HPB_SAN_Codes s
								ON s.LocationNo = r.LocationNo
						WHERE i.ShipToLoc = '00944'
							AND i.Processed = 0
							AND ISNUMERIC(i.PONumber) = 1
					END
				END
			SET @rVal = @err
			SELECT @rVal
		END
	ELSE
		BEGIN ----IF the file IS NOT complete THEN send a false back to app......
			SET @err = 1
			SET @rVal = @err
			SELECT @rVal
		END
END
GO

