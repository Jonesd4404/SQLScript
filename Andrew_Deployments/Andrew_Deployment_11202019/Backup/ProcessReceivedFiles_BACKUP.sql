USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [dbo].[ProcessReceivedFiles]    Script Date: 11/20/2019 8:01:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B.>
-- Create date: <10/4/2013>
-- Description:	<Reads AND updates EDI DB with imported files.....>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessReceivedFiles]
	 @FileName VARCHAR(100)
	,@FileText VARCHAR(MAX) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM interfering with SELECT statements.
	SET NOCOUNT ON;

	----read the text AND split INTO a table for processing....
	DECLARE	 @FileType VARCHAR(20)
			,@Listtring VARCHAR(MAX)  
			,@ediVersion CHAR(4)	
			,@fileNo VARCHAR(30)
			,@PRFNumSep INT

	--DECLARE @FileText VARCHAR(MAX) 
	--DECLARE @FileName VARCHAR(100)
	--SET @FileName='855_000069812.txt'
	------PO string........................................................
	----SET @Listtring = 'ISA~GS~ST*850*00001~BEG*00*NE*104824**20130311~DTM**20130311~N1*ST*Half Price Books #001*15*00ST~N1*BT*Half Price Books Corporate Office*15*00BT~N1*VN*Baker & Taylor Distribution*15*00VN~N2*Crystal Sweeney~N2*AcCOUNTingOffice~N3*5803 E. Northwest Hwy.~N3*5803 E. Northwest Hwy.~N3*PO Box 277938~N4*Dallas*TX*75231*USA~N4*Dallas*TX*75231~N4*Atlanta*GA*30384~PO1*1*3*EA*11.3900*EN*9781451627299*UP*~IT8*N~PO1*2*12*EA*16.5200*EN*9780446583978*UP*~IT8*N~PO1*3*12*EA*17.1000*EN*9780316036313*UP*~IT8*N~PO1*4*15*EA*8.5500*EN*9780425263907*UP*~IT8*N~PO1*5*15*EA*19.9500*EN*9780307464873*UP*~IT8*N~PO1*6*7*EA*17.0900*EN*9781401233792*UP*~IT8*N~PO1*7*12*EA*16.5000*EN*9780399157561*UP*~IT8*N~PO1*8*25*EA*9.0900*EN*9780345803498*UP*~IT8*N~PO1*9*25*EA*9.0900*EN*9780345803504*UP*~IT8*N~PO1*10*25*EA*9.0900*EN*9780345803481*UP*~IT8*N~PO1*11*12*EA*5.1200*EN*9780553579901*UP*~IT8*N~PO1*12*10*EA*14.2400*EN*9781401235413*UP*~IT8*N~PO1*13*5*EA*8.5500*EN*9780375507250*UP*~IT8*N~PO1*14*2*EA*19.9500*EN*9780553801477*UP*~IT8*N~CTT*14*180~SE*44*00001~'
	------Acknowledge string..............................................
	--SET @FileText = ''
	------Invoice string.....................................................
	----SET @Listtring = 'ISA|00|810BK3060 |00|          |ZZ|7214119        |ZZ|760985X        |131015|1132|U|00300|013113257|0|P|>GS|IN|7214119|760985X|131015|1132|013113257|X|003060ST|810|0001BIG|131015|TESTINV-1132|131015|TESTPO-111057CUR|SE|USDN1|ST||15|760985XN1|BT||15|760985XN1|VN||15|7214119ITD|01|3|||||30DTM|011|131015|||20IT1|1|1|EA|590.00|NT|IB|0835247414|PO|TESTPO-111057CTP||SLP|590.00|||DIS|1PID|F||||SUBJECT GUIDE TO BIP 2005-2006TDS|59000CAD|M||||USPSSAC|C|G830|||0|||||||06CTT|1|1SE|16|0001GE|1|013113257IEA|1|013113257'

	SET @Listtring = LTRIM(RTRIM(@FileText))
	IF RIGHT(LTRIM(RTRIM(@Listtring)),1)='|'  BEGIN SET @Listtring = LTRIM(RTRIM(REPLACE(@Listtring,'|',''))) END
	SET @Listtring = REPLACE(@Listtring,'*','|') ----run REPLACE to acCOUNT for both 3060 AND 4010 versions......

	SET @FileType = LTRIM(RTRIM(SUBSTRING(REPLACE(@FileName,'HPB',''),1,3)))
	IF @FileType NOT IN ('855','856','810') OR UPPER(RIGHT(@FileName,5)) like 'XX%'
		BEGIN
			SET @FileType = LTRIM(RTRIM(RIGHT(REPLACE(@FileName,'HPB',''),3)))
			SET @fileNo = REPLACE(RIGHT(RTRIM(@Listtring),9),'~','')
			SET @ediVersion='4010'
		END
	ELSE
		BEGIN
			SET @fileNo = CASE WHEN LEFT(@FileName,3)='HPB' THEN REPLACE(RIGHT(RTRIM(@Listtring),9),'~','') ELSE RIGHT(REPLACE(@FileName,'.txt',''),9) END
			SET @ediVersion='3060'
		END
	--add REPLACE string to add tilde for parsing.....
	IF @FileType ='855'
		BEGIN
			SET @Listtring = REPLACE(@Listtring,'|B5|','|B5|^')
			SET @Listtring = REPLACE(@Listtring,'|B6|','^|B6|')
		END
	SET @Listtring = REPLACE(@Listtring,'GS|','~GS|')
	SET @Listtring = REPLACE(@Listtring,'ST|856','~ST|856')
	SET @Listtring = REPLACE(@Listtring,'ST|855','~ST|855')
	SET @Listtring = REPLACE(@Listtring,'ST|810','~ST|810')
	SET @Listtring = REPLACE(@Listtring,'BAK|','~BAK|')
	IF @FileType ='856'
		BEGIN
			SET @Listtring = REPLACE(@Listtring,'BSN|','~BSN|')
			SET @Listtring = REPLACE(@Listtring,'PRF|','~PRF|')
			SET @Listtring = REPLACE(@Listtring,'REF|BM','~REF|BM')
			SET @Listtring = REPLACE(@Listtring,'REF|PK','~PEF|PK')
			SET @Listtring = REPLACE(@Listtring,'REF|CN','~RRE|CN')
			SET @Listtring = REPLACE(@Listtring,'REF|MA','~PEF|MA')
			SET @Listtring = REPLACE(@Listtring,'REF|IV','~PIV|IV')
			SET @Listtring = REPLACE(@Listtring,'TD1|','~TD1|')
			SET @Listtring = REPLACE(@Listtring,'TD5|','~TD5|')
			SET @Listtring = REPLACE(@Listtring,'LIN|','~LIN|')
			SET @Listtring = REPLACE(@Listtring,'MEA|','~MEA|')
			SET @Listtring = REPLACE(@Listtring,'MAN|GM','~MAN|GM')
			SET @Listtring = REPLACE(@Listtring,'HL|','~HL|')
			SET @Listtring = REPLACE(@Listtring,'FOB|PO','~FOB|PO')
			SET @Listtring = REPLACE(@Listtring,'~LIN||EN|','~LIN||IB|0|EN|')
			SET @Listtring = REPLACE(@Listtring,'~LIN||B5||B6||EN|','~LIN||IB|0|B5||B6||EN|')
		END
	IF @FileType ='810'
		BEGIN
			SET @Listtring = REPLACE(@Listtring,'BIG|','~BIG|')
			SET @Listtring = REPLACE(@Listtring,'TDS|','~TDS|')
			SET @Listtring = REPLACE(@Listtring,'SAC|','~SAC|')
			SET @Listtring = REPLACE(@Listtring,'IT1|','~IT1|')
			SET @Listtring = REPLACE(@Listtring,'|NT|EN|','|NT|IB||EN|')
			SET @Listtring = REPLACE(@Listtring,'|NT|B5||B6||EN|','|NT|IB||B5||B6||EN|')
			SET @Listtring = REPLACE(@Listtring,'CUR|SE|','~CUR|S:E|')
		END
	SET @Listtring = REPLACE(@Listtring,'SE|','~SE|')
	SET @Listtring = REPLACE(@Listtring,'SN1|','~SN1|')
	SET @Listtring = REPLACE(@Listtring,'N1|','~N1|')
	SET @Listtring = REPLACE(@Listtring,'~S~N1|','~SN1|')
	SET @Listtring = REPLACE(@Listtring,'PO1|','~PO1|')
	SET @Listtring = REPLACE(@Listtring,'CTP|','~CTP|')
	SET @Listtring = REPLACE(@Listtring,'PID|','~PID|')
	SET @Listtring = REPLACE(@Listtring,'DTM|017','~DDTM|017')
	SET @Listtring = REPLACE(@Listtring,'DTM|011','~DTM|011')
	SET @Listtring = REPLACE(@Listtring,'ACK|IA','~ACK|IA')
	SET @Listtring = REPLACE(@Listtring,'ACK|IQ','~ACK|IQ')
	SET @Listtring = REPLACE(@Listtring,'ACK|IR','~ACK|IR')
	SET @Listtring = REPLACE(@Listtring,'ACK|IB','~ACK|IB')
	SET @Listtring = REPLACE(@Listtring,'CAD|','~CAD|')
	SET @Listtring = REPLACE(@Listtring,'CUR|','~CUR|')
	SET @Listtring = REPLACE(@Listtring,'~~CUR|','~CUR|')
	SET @Listtring = REPLACE(@Listtring,'CTT|','~CTT|')
	SET @Listtring = REPLACE(@Listtring,'IEA|1|','~IEA|1|')
	SET @Listtring = REPLACE(@Listtring,CHAR(13),'')
	SET @Listtring = REPLACE(@Listtring,CHAR(10),'')
	SET @Listtring = REPLACE(@Listtring,'~~','~')

	DECLARE	 @rVal INT
			, @err INT
	SET @rVal = 0
	SET @err = 0
	DECLARE	 @Sender VARCHAR(15)
			,@Receiver VARCHAR(15)
			,@filePO VARCHAR(20)
			,@fileInv VARCHAR(20)
			,@fileASN VARCHAR(20)
			,@_FileType VARCHAR(6)
			,@issueDate VARCHAR(12)
			,@amtCode VARCHAR(4)
			,@LineSts CHAR(2)
			,@LineCode CHAR(2)
			,@LineQty INT
			,@curID VARCHAR(20)
			,@DisPct VARCHAR(6)
			,@RetAmt VARCHAR(8)
			,@ToPay VARCHAR(10)
			,@addChrg VARCHAR(10)
			,@chrgCode VARCHAR(10)
			,@lastID VARCHAR(20)
			,@lastTracking VARCHAR(30)
			,@UOM VARCHAR(6)
			,@pkgNo VARCHAR(30)
			,@trkNo VARCHAR(30)
			,@InvRef VARCHAR(15)
			,@ASNRef VARCHAR(15)
			,@ACKRef VARCHAR(15)
			,@carrier VARCHAR(50)
			,@STINVNo VARCHAR(10)
			,@STASNNo VARCHAR(10)
			,@STACKNo VARCHAR(10)
			,@GSNo VARCHAR(10)
			,@tmpString VARCHAR(250)
	DECLARE @ACKHdrs   TABLE (RowID INT identity(1,1),TypeCode VARCHAR(12),Sender VARCHAR(15),Receiver VARCHAR(15),FileType VARCHAR(20),IssueDate VARCHAR(12),FilePO VARCHAR(20),STIDNo VARCHAR(10), GSNo VARCHAR(10))
	DECLARE @ASNHdrs   TABLE (RowID INT identity(1,1),TypeCode VARCHAR(12),Sender VARCHAR(15),Receiver VARCHAR(15),FileType VARCHAR(20),IssueDate VARCHAR(12),FilePO VARCHAR(20),FileASN VARCHAR(20),AmtCode VARCHAR(4),Carrier VARCHAR(50),STIDNo VARCHAR(10), GSNo VARCHAR(10))
	DECLARE @INVHdrs   TABLE (RowID INT identity(1,1),TypeCode VARCHAR(12),Sender VARCHAR(15),Receiver VARCHAR(15),FileType VARCHAR(20),IssueDate VARCHAR(12),FilePO VARCHAR(20),FileINV VARCHAR(20),AmtCode VARCHAR(4),DisPct VARCHAR(6), STIDNo VARCHAR(10), GSNo VARCHAR(10))
	DECLARE @ACKDtl    TABLE (PONumber VARCHAR(20),LineNum VARCHAR(6),Qty VARCHAR(6),UOM VARCHAR(3),UnitPrice VARCHAR(10),PriceCode VARCHAR(4),ItemIDCode VARCHAR(4),ItemID VARCHAR(15),AckQty INT,ShipQty INT,CanQty INT,BakQty INT,LineSts CHAR(2),LineCode CHAR(2))
	DECLARE @ASNDtl    TABLE (PONumber VARCHAR(20),LineNum VARCHAR(6),Qty VARCHAR(6),UOM VARCHAR(3),UnitPrice VARCHAR(10),PriceCode VARCHAR(4),ItemIDCode VARCHAR(4),ItemID VARCHAR(15),AckQty INT,ShipQty INT,CanQty INT,BakQty INT,LineSts CHAR(2),LineCode CHAR(2),PkgNo VARCHAR(30),TrkNo VARCHAR(30))
	DECLARE @INVDtl    TABLE (PONumber VARCHAR(20),LineNum VARCHAR(6),Qty VARCHAR(6),UOM VARCHAR(3),UnitPrice VARCHAR(10),PriceCode VARCHAR(4),ItemIDCode VARCHAR(4),ItemID VARCHAR(15),FileINV VARCHAR(20),RetAmt VARCHAR(8))
	DECLARE @INVAdds   TABLE (PONumber VARCHAR(20),FileINV VARCHAR(20),ChargeCode VARCHAR(10),ChargeAmt VARCHAR(10))	
	DECLARE @listTable TABLE (RowID INT identity (1,1),[Type] VARCHAR(6),LineNum VARCHAR(6),Qty VARCHAR(6),[Key] VARCHAR(20), Data VARCHAR(250))

	IF (LEFT(RIGHT(REPLACE(@Listtring,'~',''),15),3)='IEA' OR LEFT(RIGHT(REPLACE(@Listtring,'~',''),16),3)='IEA') AND @fileNo=REPLACE(RIGHT(@Listtring,9),'~','')	----check to ensure there IS a complete file......
		BEGIN
			IF LTRIM(RTRIM(@fileType)) = '855'	----Read IN Acknowledge File....................................................................................
				BEGIN
					----------------------------------Read input file AND build temp table.........................................................................
					WHILE LEN(@Listtring) > 0
						BEGIN
							SELECT	 @err = @@ERROR
									,@tmpString = LEFT(@Listtring, ISNULL(NULLIF(CHARINDEX('~', @Listtring) - 1, -1),LEN(@Listtring)))
									,@Listtring = SUBSTRING(@Listtring,ISNULL(NULLIF(CHARINDEX('~', @Listtring), 0),LEN(@Listtring)) + 1, LEN(@Listtring))
							IF LEFT(@tmpstring,2) IN ('GS') --File data
								BEGIN
									--SELECT REPLACE(LEFT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|',''), 
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1)),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1))),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1))),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1))),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1))),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1))),
									--LTRIM(RTRIM(@tmpString))
									SET @Sender = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
									SET @Receiver = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)))
									SET @issueDate = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)))
									SET @ediVersion=ISNULL((SELECT EDIVersion FROM dbo.Vendor_SAN_Codes WHERE SANCode=@Sender),@ediVersion)
									SET @GSNo=SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)))			  
									IF @err = 0 BEGIN SET @err = @@ERROR END	
								END
							ELSE IF LEFT(@tmpstring,2) IN ('ST') --File data
								BEGIN
									--SELECT REPLACE(LEFT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|',''), 
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1)),
									--LTRIM(RTRIM(@tmpString))
									SET @_FileType = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1)
									--SET @issueDate = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)))
									SET @STACKNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))			  
									IF @err = 0 BEGIN SET @err = @@ERROR END	
								END
							ELSE IF LEFT(@tmpstring,3) IN ('BAK') --PO Hdr data
								BEGIN
									--SELECT REPLACE(LEFT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|',''), 
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1)),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1))),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))),
									--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1))),
									--LTRIM(RTRIM(@tmpString))
									SET @filePO = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)))
									SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
									SET @issueDate = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)))
									IF @err = 0 BEGIN SET @err = @@ERROR END	
								END
							ELSE IF LEFT(@tmpstring,3) IN ('ACK') --PO Dtl data
								BEGIN
									SET @LineSts = ''
									SET @LineQty = 0 
									IF LEN(@tmpstring)>=10
										BEGIN
											--SELECT REPLACE(LEFT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|',''), 
											--	SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1),
											--	SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1)),
											--	SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1))),
											--	SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))),
											--	SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1))),
											--	SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1))),
											--	SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1))),
											--	SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1))),
												--LTRIM(RTRIM(@tmpString))
												
												SET @curID = @lastID -- SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)))
												SET @LineQty = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
												SET @LineSts = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1)
												SET @LineCode = RIGHT(REPLACE(REPLACE(@tmpString,CHAR(13),''),CHAR(10),''),2)
																
												UPDATE @ACKDtl
												SET AckQty = @LineQty, ShipQty = @LineQty, LineSts=@LineSts, LineCode = @LineCode
												WHERE ItemID=@curID
												
												IF @err = 0 BEGIN SET @err = @@ERROR END	
										END
									ELSE IF LEN(@tmpstring)<10
										BEGIN
											SET @LineCode = ''
											--SELECT REPLACE(LEFT(@tmpString,CHARINDEX('|',@tmpString,1)-0),'|',''), REPLACE(RIGHT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|',''),REPLACE(RIGHT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|','')
						
											SET @LineCode = REPLACE(RIGHT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|','')
											UPDATE @ACKDtl
											SET LineCode = @LineCode
											WHERE ItemID=@curID
											IF @err = 0 BEGIN SET @err = @@ERROR END	
										END		 
								END
							ELSE IF LEFT(@tmpstring,2) IN ('PO') --PO Dtl data
								BEGIN
								--SELECT REPLACE(LEFT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|',''), 
								--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1),
								--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1)),
								--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1))),
								--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))),
								--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1))),
								--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1))),
								--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1))),
								--LTRIM(RTRIM(@tmpString))
							IF EXISTS(SELECT POnumber FROM dbo.[850_PO_Hdr] WHERE ponumber=@filePO)
								BEGIN
									INSERT INTO @ACKHdrs
										SELECT 'ACK',@Sender[Sender],@Receiver[Receiver],@fileType[FileType],@issueDate[IssueDate],@filePO[FilePO],@STACKNo[STIDNo],@GSNo[GSNo]
										WHERE @filePO NOT IN (SELECT DISTINCT FilePO FROM @ACKHdrs)
								 
									INSERT INTO @ACKDtl
										SELECT	 @FilePO, RIGHT(SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1),4)
												,SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
												,SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)))
												,SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)))
												,SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)))
												,CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1))) ='EN'
													THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)))
													ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1))) 
												 END
												,CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1))) ='EN'
													THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)))
													ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1))) 
												 END
												,0 AS [AckQty],0 AS [ShipQty],0 AS [CanQty],0 AS [BakQty],'' AS [LineSTS],'' AS [LineCode]
									
									SET @lastID = CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1))) ='EN'
														THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)+1)))
														ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1))) 
												  END
									IF @err = 0 BEGIN SET @err = @@ERROR END
								END
						END
					ELSE IF LEFT(@tmpstring,3) IN ('IEA') --PO Hdr data
						BEGIN
						  SET @ACKRef = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)
						END	
				END
		END	
	ELSE IF LTRIM(RTRIM(@fileType)) = '856'	----Read IN ASN File....................................................................................
		BEGIN
		----------------------------------Read input file AND build temp table.........................................................................
		 WHILE LEN(@Listtring) > 0
			BEGIN
				SET @tmpString = LEFT(@Listtring, ISNULL(NULLIF(CHARINDEX('~', @Listtring) - 1, -1),LEN(@Listtring)))
				SET @Listtring = SUBSTRING(@Listtring,ISNULL(NULLIF(CHARINDEX('~', @Listtring), 0),LEN(@Listtring)) + 1, LEN(@Listtring))
				IF LEFT(@tmpstring,2) IN ('GS') --File data
					BEGIN
						SElECT	 @Sender = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
								,@Receiver = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)))
								,@ediVersion=ISNULL((SELECT EDIVersion FROM dbo.Vendor_SAN_Codes WHERE SANCode=@Sender),@ediVersion)
								,@GSNo=SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)))
			  			IF @err = 0 BEGIN SET @err = @@ERROR END
					END
				ELSE IF LEFT(@tmpstring,2) IN ('ST') --File data
					BEGIN
						SET @_FileType = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1)
						SET @STASNNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
						
						IF @err = 0 BEGIN SET @err = @@ERROR END
					END
				ELSE IF LEFT(@tmpstring,3) IN ('TD5') --File data
				BEGIN
					SET @carrier = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+50-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)))
					IF @ediVersion='3060' AND @Sender='8600023'----Scholastic
						BEGIN
							SET @carrier = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)))
		 				END
					IF @ediVersion='3060' AND @Sender='2002086'----HarperCollins
						BEGIN
							SET @carrier = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)))
		 				END
				END
			ELSE IF LEFT(@tmpstring,3) IN ('PRF') --PO Hdr data
				BEGIN
				 --  IF @ediVersion='3060' AND @Sender<>'2153793'
					--	BEGIN
					--		SET @filePO = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1)
					--		SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
					--	END
					--ELSE IF @ediVersion='3060' AND @Sender='2153793'
					--	BEGIN
					--		SET @filePO=SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,6)
					--		SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
					--	END
					--ELSE IF @ediVersion='4010'
					--	BEGIN
					--		SET @filePO=SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,6)
					--		SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
					--	END
					SELECT @PRFNumSep = LEN(@tmpString) - LEN(REPLACE(@tmpString, '|',''))
					IF @ediVersion = '3060'						
						IF @PRFNumSep = 1 -- Sender sould be Houghton Mifflin Distribution - 2153793  or MacMillan Distribution	- 6315011
							BEGIN
								SET @filePO=SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,6)
								SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
							END
						ELSE 
							BEGIN
								SET @filePO = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1)
								SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
							END
					ELSE IF @ediVersion = '4010'
						BEGIN
							IF @PRFNumSep = 1
								BEGIN
									SET @filePO=SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,6)
									SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
								END
						END
				  IF @err = 0 BEGIN SET @err = @@ERROR END
				  SET @PRFNumSep = 0
				END
			ELSE IF LEFT(@tmpstring,3) IN ('REF') --PO Hdr data  
				BEGIN
					--IDMACMDIST & IDS&SDISTR
					IF @ediVersion='3060' OR @Sender IN ('6315011','2002442')  SET @fileASN = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1+1+1))
					IF @err = 0 BEGIN SET @err = @@ERROR END
				END
			ELSE IF LEFT(@tmpstring,3) IN ('PEF') ----RandomHouse
				IF @ediVersion='4010' SET @fileASN = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1+1+1))
			ELSE IF LEFT(@tmpstring,3) IN ('RRE') ----HarperCollins
				IF @ediVersion='3060'
					SET @trkNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1+15))
				ELSE
					SET @trkNo = ''
			ELSE IF LEFT(@tmpstring,3) IN ('DTM') --File data
				SET @issueDate = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
			ELSE IF LEFT(@tmpstring,3) IN ('CUR') --PO Hdr data
				BEGIN
				  SET @amtCode = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
				  IF @err = 0 BEGIN SET @err = @@ERROR END
				END
			ELSE IF LEFT(@tmpstring,3) IN ('MAN') --PO Hdr data
				BEGIN
						IF @ediVersion='3060' AND @Sender NOT IN ('2002086','8600023') ----NOT HarperCollins OR Scholastic
							BEGIN
								 SET @pkgNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
								 SET @trkNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)))
								 IF @pkgNo=@trkNo
									BEGIN
										SET @pkgNo =SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1+15))
					 					SET @trkNo = ''
									END	
							END	
						ELSE IF @ediVersion='3060' AND @Sender IN ('2002086','8600023')	----HarperCollins & Scholastic
							 SET @pkgNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1+15))
						ELSE IF @ediVersion='4010'
							BEGIN
								 SET @pkgNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
								 SET @trkNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)))
								
								 IF @pkgNo=@trkNo
									BEGIN
										SET @trkNo =SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1+15))
				 						SET @pkgNo = ''
									END	
							END	
					  IF @err = 0 BEGIN SET @err = @@ERROR END
				END
			ELSE IF LEFT(@tmpstring,3) IN ('LIN') --PO Dtl data
				BEGIN
					INSERT INTO @ASNHdrs
						SELECT 'ASN',@Sender[Sender],@Receiver[Receiver],@fileType[FileType],@issueDate[IssueDate],@filePO[FilePO],@fileASN[FileASN],@amtCode[AmtCode],@carrier[Carrier],@STASNNo[STIDNo],@GSNo[GSNo]
						WHERE @filePO NOT IN (SELECT DISTINCT FilePO FROM @ASNHdrs) --AND @filePO NOT IN (SELECT DISTINCT FilePO FROM @ASNHdrs)		  
					INSERT INTO @ASNDtl
						SELECT @FilePO,'','','','','',
							CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))) ='EN'
								THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)))
								ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1)) END,
							CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))) ='EN'
								THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)))
								ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))) END,
							0 AS [AckQty],0 AS [ShipQty],0 AS [CanQty],0 AS [BakQty],'' AS [LineSTS],'' AS [LineCode],@pkgNo,@trkNo
						SET @lastID = CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))) ='EN'
							THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)))
							ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))) 
						END
						SET @lastTracking = CASE WHEN @pkgNo=''THEN @trkNo ELSE @pkgNo END
						IF @err = 0 BEGIN SET @err = @@ERROR END
				END
			ELSE IF LEFT(@tmpstring,3) IN ('SN1') --PO Dtl data
				BEGIN
					SELECT	 @LineSts = ''
							,@LineQty = 0 
					SELECT   @curID = @lastID -- SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)))
							,@LineQty = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
							,@UOM = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)))
					UPDATE @ASNDtl
						SET Qty = @LineQty, ShipQty = @LineQty, UOM = CASE WHEN len(@UOM)>2 THEN LEFT(@UOM,2) ELSE @UOM END
					WHERE ItemID=@curID AND PONumber=@filePO AND @lastTracking IN (PkgNo,TrkNo)
					IF @err = 0 BEGIN SET @err = @@ERROR END
				END
			ELSE IF LEFT(@tmpstring,3) IN ('IEA') --PO Hdr data
				BEGIN
					SET @ASNRef = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)
					--SELECT @ASNRef
				END	
		END
	END
	ELSE IF LTRIM(RTRIM(@fileType)) = '810'	----Read IN Invoice File....................................................................................
		BEGIN
		----------------------------------Read input file AND build temp table.........................................................................
		 WHILE LEN(@Listtring) > 0
			BEGIN
		  SELECT @tmpString = LEFT(@Listtring, ISNULL(NULLIF(CHARINDEX('~', @Listtring) - 1, -1),LEN(@Listtring)))
				,@Listtring = SUBSTRING(@Listtring,ISNULL(NULLIF(CHARINDEX('~', @Listtring), 0),LEN(@Listtring)) + 1, LEN(@Listtring))
		  --SELECT @tmpstring
			IF LEFT(@tmpstring,2) IN ('GS') --File data
			BEGIN
			  SELECT @Sender = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
					,@Receiver = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)))
					,@ediVersion=ISNULL((SELECT EDIVersion FROM dbo.Vendor_SAN_Codes WHERE SANCode=@Sender),@ediVersion)
					,@GSNo=SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)))
			  IF @err = 0 BEGIN SET @err = @@ERROR END
			END
			ELSE IF LEFT(@tmpstring,2) IN ('ST') --File data
			BEGIN
			  SELECT @_FileType = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1)
					,@STINVNo = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
		END
			ELSE IF LEFT(@tmpstring,3) IN ('BIG') --PO Hdr data
			BEGIN
			  SET @fileInv = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
			  SET @filePO = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)))
			  SET @filePO = LTRIM(RTRIM(REPLACE(REPLACE(@filePO,'-',''),'reship','')))
			  
			  IF @ediVersion='4010'
				BEGIN
					SET @issueDate = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1)
				END
			  IF @err = 0 BEGIN SET @err = @@ERROR END
			END
			ELSE IF LEFT(@tmpstring,3) IN ('DTM') --File data
			BEGIN
			 IF @ediVersion='3060'
				BEGIN
					SET @issueDate = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
				END
			END
			ELSE IF LEFT(@tmpstring,3) IN ('CUR') --PO Hdr data
			BEGIN
				  IF @ediVersion='3060'
					BEGIN
						SET @amtCode = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
					END
				  ELSE IF @ediVersion='4010'
					BEGIN
						SET @amtCode = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
					END
			  IF @err = 0 BEGIN SET @err = @@ERROR END
			END
			ELSE IF LEFT(@tmpstring,3) IN ('CTP') --PO Hdr data
			BEGIN
			    SET @DisPct = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)))
				SET @RetAmt = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)))

				UPDATE @INVHdrs
					SET AmtCode=@amtCode,DisPct=@DisPct
				WHERE FilePO=@filePO
				
				UPDATE @INVDtl
					SET RetAmt=@RetAmt
				WHERE ItemID=@lastID
			  IF @err = 0 BEGIN SET @err = @@ERROR END
			END	
			ELSE IF LEFT(@tmpstring,3) IN ('SAC') --File data
			BEGIN
				SET @chrgCode = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1))
			    SET @addChrg = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)))
			    SET @addChrg = CASE LEN(@addChrg) WHEN 1 THEN '000'+@addChrg WHEN 2 THEN '00'+@addChrg WHEN 3 THEN '0'+@addChrg ELSE @addChrg END
				IF NOT EXISTS(SELECT PONumber FROM @INVAdds WHERE PONumber=@filePO AND FileINV=@fileInv AND ChargeCode=@chrgCode) AND CAST(@addChrg AS INT) <> 0
					BEGIN
						INSERT INTO @INVAdds
						SELECT @filePO,@fileInv,@chrgCode,@addChrg
					END
			END
			ELSE IF LEFT(@tmpstring,3) IN ('TDS') --PO Hdr data
			BEGIN
			  --SELECT REPLACE(LEFT(@tmpString,CHARINDEX('|',@tmpString,1)-1),'|',''), REPLACE(RIGHT(@tmpString,CHARINDEX('|',@tmpString,1)+1),'|','')
					--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1)
					--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1)),
					--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1))),
					--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))),
					--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1))),
					--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1))),
					--SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1))),
					--LTRIM(RTRIM(@tmpString))
			  IF @err = 0 BEGIN SET @err = @@ERROR END
			END			
			ELSE IF LEFT(@tmpstring,3) IN ('IT1') --PO Dtl data
			BEGIN
			 --IF EXISTS(SELECT POnumber FROM dbo.[850_PO_Hdr] WHERE ponumber=@filePO)
				--	BEGIN
						  INSERT INTO @INVHdrs
						  SELECT 'INV',@Sender[Sender],@Receiver[Receiver],@fileType[FileType],@issueDate[IssueDate],@filePO[FilePO],@fileINV[FileINV],@amtCode[AmtCode],@DisPct[DisPct],@STINVNo[STIDNo],@GSNo[GSNo]
						  WHERE @fileInv NOT IN (SELECT DISTINCT FileINV FROM @INVHdrs) --AND @filePO NOT IN (SELECT DISTINCT FilePO FROM @INVHdrs)
					
						  INSERT INTO @INVDtl
						  SELECT @FilePO, SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,1)+1,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)-CHARINDEX('|',@tmpString,1)-1),
								SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-1)),
								SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1))),
								SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1))),
								SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1))),
								CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1))) ='EN'
									THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)))
									ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1))) END,
								CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1))) ='EN'
									THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)))
									ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1))) END,
									@fileInv,@RetAmt
							SET @lastID = CASE WHEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1))) ='EN'
									THEN SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1)+1)+1)))
									ELSE SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)+1)+1)+1))) END
							IF @err = 0 BEGIN SET @err = @@ERROR END
					--END
			END
			ELSE IF LEFT(@tmpstring,3) IN ('IEA') --PO Hdr data
			BEGIN
			  SET @InvRef = SUBSTRING(@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1,ABS(CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1-CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,CHARINDEX('|',@tmpString,1)+1)+1)+1)+1)
			  --SELECT @InvRef
			END	
		 END
		END

	----------------------------------------------------------------------------------------------------------------------------------------------------------
	-------------------------INSERT INTO DB FROM temp table.................................................................................
		
		DECLARE @id INT
		SET @id = 0
			
		IF LTRIM(RTRIM(@fileType)) = '855'	AND LTRIM(RTRIM(@_FileType)) = '855'
			BEGIN
		--------ACK...................................................................................................................................................
				DECLARE @ACKloop INT
				SELECT @ACKloop = COUNT(DISTINCT FilePO) FROM @ACKHdrs
				WHILE @ACKloop > 0
					BEGIN
						DECLARE	 @curACKPO VARCHAR(12) 
								,@curACKSend VARCHAR(20)
								,@curACKRecv VARCHAR(20)
								,@curACKIssueDtm VARCHAR(20)
								,@curACKamtCode VARCHAR(6)
								,@curACKSTNo VARCHAR(10)
								,@curACKGSNo VARCHAR(10)
						SELECT @curACKPO=FilePO,@curACKSend=Sender,@curACKRecv=Receiver,@curACKIssueDtm=IssueDate,@curACKSTNo=STIDNo,@curACKGSNo=GSNo 
						FROM @ACKHdrs WHERE RowID=@ACKloop
				
						----SET @ACKDtl quantities.....
						UPDATE p
							SET p.CanQty=CASE WHEN ISNULL(p.Qty,0)-ISNULL(p.AckQty,0)< 0 THEN 0 ELSE ISNULL(p.Qty,0)-ISNULL(p.AckQty,0) END
						FROM @ACKDtl p 
							LEFT OUTER JOIN dbo.[850_PO_Hdr] ph 
								ON p.PONumber=ph.PONumber
							LEFT OUTER JOIN dbo.[850_PO_Dtl] pd 
								ON ph.OrdID=pd.OrdID 
									AND p.ItemID=pd.ItemIdentifier
						WHERE p.PONumber=@curACKPO
						
						IF @err = 0 BEGIN SET @err = @@ERROR END
											
						BEGIN tran
						--INSERT header info AND get identity...
						INSERT INTO BLK.AcknowledgeHeader (PONumber,IssueDate,VendorID,ReferenceNo,ShipToLoc,ShipToSAN,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN,TotalLines,TotalQuantity,CurrencyCode,InsertDateTime,Processed,ProcessedDateTime,ResponseACKSent,ResponseAckNo,GSNo)
							SELECT	 ph.PONumber
									,@curACKIssueDtm
									,ph.VendorID
									,@ACKRef
									,ph.ShipToLoc
									,ph.ShipToSAN
									,ph.BillToLoc
									,ph.BillToSAN
									,ph.ShipFromLoc
									,ph.ShipFromSAN
									,(SELECT COUNT(LineNum) FROM @ACKDtl WHERE PONumber=@curACKPO)
									,(SELECT SUM(AckQty) FROM @ACKDtl WHERE PONumber=@curACKPO)
									,@curACKamtCode
									,GETDATE()
									,0
									,NULL
									,0
									,@curACKSTNo
									,@curACKGSNo
							FROM dbo.[850_PO_Hdr] ph 
							WHERE ph.ponumber=@curACKPO 
								AND REPLACE(ph.ShipFromSAN,'-','')=REPLACE(@curACKSend,'-','') 
								--AND REPLACE(ph.ShipToSAN,'-','')=REPLACE(@Receiver,'-','')
						IF @err = 0 BEGIN SET @err = @@ERROR END
						SET @id = @@identity
						
						----INSERT detail info..................
						IF ISNULL(@id,0)<>0 AND @err=0
							BEGIN
								INSERT INTO BLK.AcknowledgeDetail (AckID,[LineNo],LineStatusCode,ItemStatusCode,UnitOfMeasure, QuantityOrdered, QuantityShipped, QuantityCancelled,QuantityBackordered,UnitPrice,PriceCode,CurrencyCode,ItemIDCode,ItemIdentifier)
									SELECT	 @id
											,p.LineNum
											,p.LineSts
											,p.LineCode
											,p.UOM
											,p.AckQty
											,p.ShipQty
											--,p.CanQty
											--,p.BakQty,
											,CASE WHEN p.LineCode like 'B%' OR p.LineCode ='IB' THEN 0			ELSE p.CanQty END AS [CanQty]
											,CASE WHEN p.LineCode like 'B%' OR p.LineCode ='IB' THEN p.CanQty	ELSE p.BakQty END AS [BakQty]
											,p.UnitPrice
											,p.PriceCode
											,@amtCode
											,p.ItemIDCode
											,p.ItemID
									FROM @ACKDtl p 
									WHERE p.PONumber=@curACKPO
								IF @err = 0 BEGIN SET @err = @@ERROR END
							END
						IF @err=0
							COMMIT TRANSACTION VX_ReqSubmit
						ELSE
							ROLLBACK  TRANSACTION VX_ReqSubmit
						SET @ACKloop = @ACKloop-1
					END
			END
		----------------------------------------------------------------------------------------------------------------------------------------------------------
		ELSE IF LTRIM(RTRIM(@fileType)) = '856'	AND LTRIM(RTRIM(@_FileType)) = '856'
			BEGIN
		--------ASN...................................................................................................................................................
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
				
						SELECT	 @curASNPO=FilePO
								,@curASN=FileASN
								,@curASNSend=Sender
								,@curASNRecv=Receiver
								,@curASNIssueDtm=IssueDate
								,@curASNamtCode=AmtCode
								,@curCar=LTRIM(RTRIM(REPLACE(Carrier,' ','')))
								,@curASNSTNo=STIDNo
								,@curASNGSNo=GSNo 
						FROM @ASNHdrs 
						WHERE RowID=@ASNloop
						
						BEGIN tran
						
						IF EXISTS (SELECT PONumber FROM dbo.[850_PO_Hdr] WHERE PONumber=@curASNPO)
							BEGIN
								----SET @ACKDtl quantities.....
								UPDATE p
									SET p.LineNum=pd.[LineNo],p.UnitPrice=pd.UnitPrice,p.PriceCode=pd.PriceCode
								FROM @ASNDtl p 
									LEFT OUTER JOIN dbo.[850_PO_Hdr] ph 
										ON p.PONumber=ph.PONumber
									LEFT OUTER JOIN dbo.[850_PO_Dtl] pd 
										ON ph.OrdID=pd.OrdID AND p.ItemID=pd.ItemIdentifier
								WHERE p.PONumber=@curASNPO
						
								IF @err = 0 BEGIN SET @err = @@ERROR END
								
								--INSERT header info AND get identity...
								INSERT INTO BLK.ShipmentHeader (PONumber,ASNNo,IssueDate,VendorID,ReferenceNo,ShipToLoc,ShipToSAN,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN,Carrier,TotalLines,TotalQuantity,CurrencyCode,InsertDateTime,Processed,ProcessedDateTime,ASNACKSent,ASNAckNo,GSNo)
									SELECT ph.PONumber,@curASN,@curASNIssueDtm,ph.VendorID,@ASNRef,ph.ShipToLoc,ph.ShipToSAN,ph.BillToLoc,ph.BillToSAN,ph.ShipFromLoc,ph.ShipFromSAN,
										LEFT(@curCar,20),(SELECT COUNT(LineNum) FROM @ASNDtl WHERE PONumber=@curASNPO),(SELECT SUM(ShipQty) FROM @ASNDtl WHERE PONumber=@curASNPO),@curASNamtCode,GETDATE(),0,NULL,0,@curASNSTNo,@curASNGSNo
									FROM dbo.[850_PO_Hdr] ph 
									WHERE ph.ponumber=@curASNPO 
										AND REPLACE(ph.ShipFromSAN,'-','')=REPLACE(@curASNSend,'-','') 
										--AND REPLACE(ph.ShipToSAN,'-','')=REPLACE(@Receiver,'-','')								
								IF @err = 0 BEGIN SET @err = @@ERROR END
							END
						ELSE IF NOT EXISTS (SELECT PONumber FROM dbo.[850_PO_Hdr] WHERE PONumber=@curASNPO) AND LEN(@curASNPO)>6
							BEGIN
								INSERT INTO BLK.ShipmentHeader (PONumber,ASNNo,IssueDate,VendorID,ReferenceNo,ShipToLoc,ShipToSAN,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN,Carrier,TotalLines,TotalQuantity,CurrencyCode,InsertDateTime,Processed,ProcessedDateTime,ASNACKSent,ASNAckNo,GSNo)
									SELECT 'F'+RIGHT(@ASNRef,5),@curASN,@curASNIssueDtm,v.VendorID,@ASNRef,s1.LocationNo,s1.SANCode,s2.LocationNo,s2.SANCode,'VEND',v.SANCode,
										LEFT(@curCar,20),(SELECT COUNT(LineNum) FROM @ASNDtl WHERE PONumber=@curASNPO),(SELECT SUM(ShipQty) FROM @ASNDtl WHERE PONumber=@curASNPO),@curASNamtCode,GETDATE(),0,NULL,0,@curASNSTNo,@curASNGSNo
									FROM @ASNHdrs h 
										INNER JOIN dbo.Vendor_SAN_Codes v 
											ON REPLACE(h.Sender,'-','')=REPLACE(v.SANCode,'-','')
										INNER JOIN dbo.HPB_SAN_Codes s1 
											ON REPLACE(h.Receiver,'-','')=REPLACE(s1.SANCode,'-','')
										INNER JOIN dbo.HPB_SAN_Codes s2 
											ON s2.LocationNo='HPBCA'
									WHERE h.FilePO=@curASNPO AND REPLACE(h.Sender,'-','')=REPLACE(@curASNSend,'-','')
										AND h.FileASN NOT IN (SELECT DISTINCT ReferenceNo FROM dbo.[856_ASN_Hdr])								
								IF @err = 0 BEGIN SET @err = @@ERROR END
							END
						ELSE
							BEGIN
								INSERT INTO BLK.ShipmentHeader (PONumber,ASNNo,IssueDate,VendorID,ReferenceNo,ShipToLoc,ShipToSAN,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN,Carrier,TotalLines,TotalQuantity,CurrencyCode,InsertDateTime,Processed,ProcessedDateTime,ASNACKSent,ASNAckNo,GSNo)
									SELECT h.FilePO,@curASN,@curASNIssueDtm,v.VendorID,@ASNRef,s1.LocationNo,s1.SANCode,s2.LocationNo,s2.SANCode,'VEND',v.SANCode,
										LEFT(@curCar,20),(SELECT COUNT(LineNum) FROM @ASNDtl WHERE PONumber=@curASNPO),(SELECT SUM(ShipQty) FROM @ASNDtl WHERE PONumber=@curASNPO),@curASNamtCode,GETDATE(),0,NULL,0,@curASNSTNo,@curASNGSNo
									FROM @ASNHdrs h 
										INNER JOIN dbo.Vendor_SAN_Codes v 
											ON REPLACE(h.Sender,'-','')=REPLACE(v.SANCode,'-','')
										INNER JOIN dbo.HPB_SAN_Codes s1 
											ON REPLACE(h.Receiver,'-','')=REPLACE(s1.SANCode,'-','')
										INNER JOIN dbo.HPB_SAN_Codes s2 
											ON s2.LocationNo='HPBCA'
									WHERE h.FilePO=@curASNPO AND REPLACE(h.Sender,'-','')=REPLACE(@curASNSend,'-','')
										AND h.FileASN NOT IN (SELECT DISTINCT ReferenceNo FROM dbo.[856_ASN_Hdr])								
								IF @err = 0 BEGIN SET @err = @@ERROR END
							END
						SET @id = @@IDENTITY
						--INSERT detail info..................
						IF ISNULL(@id,0)<>0 AND @err=0
							BEGIN
								INSERT INTO BLK.ShipmentDetail (ShipmentID,[LineNo],ItemIDCode,ItemIdentifier,QuantityShipped,PackageNo,TrackingNo)
								SELECT @id,CASE WHEN LTRIM(RTRIM(ISNULL(p.LineNum,'')))='' THEN ISNULL(ROW_NUMBER() OVER(PARTITION BY [PONumber] ORDER BY [PONumber]),'') ELSE p.LineNum END,
									p.ItemIDCode,p.ItemID,p.ShipQty,p.PkgNo,p.TrkNo
								FROM @ASNDtl p
								WHERE p.POnumber=@curASNPO
								IF @err = 0 BEGIN SET @err = @@ERROR END
							END
							
						IF @err=0
							COMMIT TRANSACTION VX_ReqSubmit
						ELSE
							ROLLBACK  TRANSACTION VX_ReqSubmit
						SET @ASNloop = @ASNloop-1
					END
					
					----UPDATE any invoices that the ORDER originated IN DIPS.........
					--IF EXISTS (SELECT i.PONumber FROM dbo.[856_ASN_Hdr] i INNER JOIN (SELECT PONumber,LocationNo FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r ON i.PONumber=r.PONumber
					--			INNER JOIN dbo.HPB_SAN_Codes s ON s.LocationNo=r.LocationNo WHERE i.ShipToLoc='00944' AND i.Processed=0 AND ISNUMERIC(i.PONumber)=1)
					IF EXISTS (	SELECT i.PONumber 
								FROM (	SELECT ih.PONumber
										FROM BLK.InvoiceHeader ih
										WHERE ih.Processed = 0 
											AND ih.ShipToLoc = '00944'
											AND ISNUMERIC(ih.PONumber) = 1) i
									INNER JOIN (SELECT PONumber,LocationNo FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r 
										ON i.PONumber=r.PONumber
									INNER JOIN dbo.HPB_SAN_Codes s 
										ON s.LocationNo=r.LocationNo)
						BEGIN  
							UPDATE i
								SET i.ShipToLoc=r.LocationNo,i.ShipToSAN=s.SANCode
							FROM BLK.InvoiceHeader i
								INNER JOIN (SELECT PONumber,LocationNo FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r 
									ON i.PONumber=r.PONumber
								INNER JOIN dbo.HPB_SAN_Codes s 
									ON s.LocationNo=r.LocationNo
							WHERE i.ShipToLoc='00944' 
								AND i.Processed=0
								AND ISNUMERIC(i.PONumber)=1
						END
			END
		----------------------------------------------------------------------------------------------------------------------------------------------------------
		ELSE IF LTRIM(RTRIM(@fileType)) = '810'	AND LTRIM(RTRIM(@_FileType)) = '810'
			BEGIN
		--------INV...................................................................................................................................................
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
						SELECT @curINVPO=FilePO,@curINV=FileINV,@curINVSend=Sender,@curINVRecv=Receiver,@curINVIssueDtm=IssueDate,@curINVamtCode=ISNULL(AmtCode,'USD'),@curINVDisPct=DisPct,@curINVSTNo=STIDNo,@curGSNo=GSNo 
						FROM @INVHdrs 
						WHERE RowID=@INVloop
				
						----UPDATE unit price for HMH since they are sending full retail price IN files...........
						IF @curINVSend='2153793'
							BEGIN
								UPDATE @INVDtl
									SET UnitPrice = CAST(CAST(CAST(UnitPrice AS MONEY)*CAST(@curINVDisPct AS DECIMAL(8,2)) AS DECIMAL(12,4)) AS VARCHAR(10))
								WHERE PONumber=@curINVPO
							END

						IF EXISTS(SELECT a.PONumber FROM dbo.[810_Inv_Charges] a INNER JOIN @INVAdds b ON a.PONumber=b.PONumber AND a.InvoiceNo=b.FileINV AND a.ChargeCode=b.ChargeCode WHERE a.PONumber=@curINVPO)
							BEGIN
								 UPDATE b
									 SET ChargeAmt=CAST(ISNULL(LEFT(a.ChargeAmt,LEN(a.ChargeAmt)-2)+'.'+RIGHT(a.ChargeAmt,2),0)AS DECIMAL(10,2))
								 FROM dbo.[810_Inv_Charges] b 
									INNER JOIN @INVAdds a 
										ON a.PONumber=b.PONumber 
											AND b.InvoiceNo=a.FileINV 
												AND a.ChargeCode=b.ChargeCode 
								 WHERE b.PONumber=@curINVPO 
									AND b.InvoiceNo=@curINV 
										AND b.ChargeCode=a.ChargeCode
							END
						ELSE
							BEGIN
								INSERT INTO dbo.[810_Inv_Charges]
									SELECT	 a.PONumber
											,@curINV
											,a.ChargeCode
											,SUM(CAST(ISNULL(LEFT(a.ChargeAmt,LEN(a.ChargeAmt)-2)+'.'+RIGHT(a.ChargeAmt,2),0)AS DECIMAL(10,2)))
									FROM @INVAdds a
									WHERE a.PONumber=@curINVPO 
										AND NOT EXISTS(	SELECT PONumber 
														FROM dbo.[810_Inv_Charges] 
														WHERE PONumber=@curINVPO 
															AND InvoiceNo=@curINV AND 
															ChargeCode=a.ChargeCode )
									GROUP BY a.PONumber,a.ChargeCode
							END	
						
						SET @ToPay = (	SELECT SUM(CAST(Qty AS INT)*CAST(UnitPrice AS MONEY)) 
										FROM @INVDtl 
										WHERE PONumber=@filePO 
											AND FileINV=@curINV)
						IF @curINVDisPct IS NULL BEGIN SET @curINVDisPct=(SELECT TOP 1 DisPct FROM @INVHdrs WHERE DisPct IS NOT NULL)  END
				
						BEGIN TRAN
						--INSERT header info AND get identity...check IF PO EXISTS AND do INSERT.........................................					
						IF EXISTS(SELECT PONumber FROM dbo.[850_PO_Hdr] WHERE PONumber=@curINVPO)
							BEGIN
								INSERT INTO BLK.InvoiceHeader (InvoiceNo,IssueDate,VendorID,PONumber,ReferenceNo,ShipToLoc,ShipToSAN,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN,TotalLines,TotalQuantity,TotalPayable,CurrencyCode,InsertDateTime,Processed,ProcessedDateTime,InvoiceAckSent,InvoiceAckNo,GSNo)
									SELECT	 @curINV
											,@curINVIssueDtm
											,ph.VendorID
											,ph.PONumber
											,@InvRef
											,ph.ShipToLoc
											,ph.ShipToSAN
											,ph.BillToLoc
											,ph.BillToSAN
											,ph.ShipFromLoc
											,ph.ShipFromSAN
											,(SELECT COUNT(LineNum) FROM @INVDtl WHERE PONumber=@curINVPO AND FileINV=@curINV)
											,(SELECT SUM(CAST(Qty AS INT)) FROM @INVDtl WHERE PONumber=@curINVPO AND FileINV=@curINV)
											,(SELECT CAST(SUM(CAST(UnitPrice AS DECIMAL(12,4))*CAST(Qty AS INT))AS DECIMAL(12,4)) FROM @INVDtl WHERE PONumber=@curINVPO AND FileINV=@curINV)+ISNULL((SELECT SUM(ChargeAmt) FROM dbo.[810_Inv_Charges] WHERE PONumber=@curINVPO AND InvoiceNo=@curINV),0)
											,@curINVamtCode
											,GETDATE()
											,0
											,NULL
											,0
											,@curINVSTNo
											,@curGSNo
									FROM dbo.[850_PO_Hdr] ph 
									WHERE ph.ponumber=@curINVPO 
										AND REPLACE(ph.ShipFromSAN,'-','')=REPLACE(@curINVSend,'-','')
										AND NOT EXISTS (SELECT DISTINCT InvoiceNo FROM dbo.[810_Inv_Hdr] WHERE InvoiceNo=@curINV)
							END
						ELSE  ----IF PO does NOT exist THEN pull FROM table variables......................................................
							BEGIN
								INSERT INTO BLK.InvoiceHeader (InvoiceNo,IssueDate,VendorID,PONumber,ReferenceNo,ShipToLoc,ShipToSAN,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN,TotalLines,TotalQuantity,TotalPayable,CurrencyCode,InsertDateTime,Processed,ProcessedDateTime,InvoiceAckSent,InvoiceAckNo,GSNo)
									SELECT	 h.FileINV
											,h.IssueDate
											,v.VendorID
											,h.FilePO
											,@InvRef
											,s1.LocationNo
											,s1.SANCode
											,s2.LocationNo
											,s2.SANCode
											,'VEND'
											,v.SANCode
											,(SELECT COUNT(LineNum) FROM @INVDtl WHERE PONumber=@curINVPO AND FileINV=@curINV)
											,(SELECT SUM(CAST(Qty AS INT)) FROM @INVDtl WHERE PONumber=@curINVPO AND FileINV=@curINV)
											,(SELECT CAST(SUM(CAST(UnitPrice AS DECIMAL(12,4))*CAST(Qty AS INT))AS DECIMAL(12,4)) FROM @INVDtl WHERE PONumber=@curINVPO AND FileINV=@curINV)+ISNULL((SELECT SUM(ChargeAmt) FROM dbo.[810_Inv_Charges] WHERE PONumber=@curINVPO AND InvoiceNo=@curINV),0)
											,@curINVamtCode
											,GETDATE()
											,0
											,NULL
											,0
											,@curINVSTNo
											,@curGSNo
									FROM @INVHdrs h 
										INNER JOIN dbo.Vendor_SAN_Codes v 
											ON REPLACE(h.Sender,'-','')=REPLACE(v.SANCode,'-','')
										INNER JOIN dbo.HPB_SAN_Codes s1 
											ON REPLACE(h.Receiver,'-','')=REPLACE(s1.SANCode,'-','')
										INNER JOIN dbo.HPB_SAN_Codes s2 
											ON s2.LocationNo='HPBCA'
									WHERE h.FilePO=@curINVPO 
										AND h.FileINV=@curINV 
										AND REPLACE(h.Sender,'-','')=REPLACE(@curINVSend,'-','')	
										AND NOT EXISTS (SELECT DISTINCT invoiceno FROM dbo.[810_Inv_Hdr] WHERE InvoiceNo=@curINV)
							END							
						SET @id = @@IDENTITY
						IF ISNULL(@id,0)<>0 AND @err=0
							BEGIN
								-- INSERT detail info
								INSERT INTO BLK.InvoiceDetail (InvoiceID,[LineNo],ItemIDCode,ItemIdentifier,ItemDesc,InvoiceQty,UnitPrice,DisCOUNTPrice,DisCOUNTCode,DisCOUNTPct,RetailPrice)
									SELECT	 @id
											,p.LineNum
											,p.ItemIDCode
											,p.ItemID
											,''
											,p.Qty
											,CAST(CAST(p.UnitPrice AS DECIMAL(12,2)) AS VARCHAR(6))
											,''
											,''
											,@curINVDisPct,p.RetAmt
									FROM @INVDtl p
									WHERE p.PONumber=@curINVPO 
										AND p.FileINV=@curINV						
								IF @err = 0 BEGIN SET @err = @@ERROR END
							END							
						IF @err=0
							COMMIT TRANSACTION VX_ReqSubmit
						ELSE
							ROLLBACK  TRANSACTION VX_ReqSubmit
						SET @INVloop = @INVloop-1
					END	
					
					----UPDATE any invoices that the ORDER originated IN DIPS.........
					--IF EXISTS	(	SELECT i.PONumber 
					--				FROM dbo.[810_Inv_Hdr] i 
					--					INNER JOIN (SELECT PONumber,LocationNo FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r 
					--						ON i.PONumber=r.PONumber
					--					INNER JOIN dbo.HPB_SAN_Codes s 
					--						ON s.LocationNo=r.LocationNo WHERE i.ShipToLoc='00944' AND i.Processed=0 AND ISNUMERIC(i.PONumber)=1
					--			)
					IF EXISTS	(	SELECT i.PONumber 
									FROM  (	SELECT ih.PONumber
											FROM BLK.InvoiceHeader ih
											WHERE ih.ShipToLoc = '00944'
												AND ih.Processed = 0
												AND ISNUMERIC(ih.PONumber) = 1) i 
										INNER JOIN (SELECT PONumber,LocationNo FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r 
											ON i.PONumber=r.PONumber
										INNER JOIN dbo.HPB_SAN_Codes s 
											ON s.LocationNo=r.LocationNo 
								)
						BEGIN  
							UPDATE i
								SET	 i.ShipToLoc=r.LocationNo
									,i.ShipToSAN=s.SANCode
							FROM blk.InvoiceHeader i 
								INNER JOIN (SELECT PONumber,LocationNo FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader) r 
									ON i.PONumber=r.PONumber
								INNER JOIN dbo.HPB_SAN_Codes s 
									ON s.LocationNo=r.LocationNo
							WHERE i.ShipToLoc='00944' 
								AND i.Processed=0
								AND ISNUMERIC(i.PONumber)=1
						END
			END
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
	
		SET @rVal = @err
		SELECT @rVal
	END
ELSE
	BEGIN		----IF the file IS NOT complete THEN send a false back to app......
		SET @err=1
		SET @rVal = @err
		SELECT @rVal	
	END

END

GO


