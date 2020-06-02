--Original_Updated_On_08062018_Backup_For_Tracy_Deployment

USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[rpt_TransactionHeader_XML3ID]    Script Date: 8/6/2018 1:26:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




create PROCEDURE [dbo].[rpt_TransactionHeader_XML3ID] (
	--declare
	@LocationNo CHAR(5) --= '00001' 
	,@StartDate DATETIME --= '12/1/2016' 
	,@EndDate DATETIME --= '12/1/2016'
	)
AS
/******************************************************************
Created: 02.07.2014 - dgreen

Transaction History Report (Procedure)

Pull transaction header data from PCMS_IMPORT tables by store code
for a date range.

This will be the initial report most users run so that they can
take a deeper dive into the details of the transactions.

Updated 12/14/15 Tracy Dennis Ticket sw#76147 
Due to a another issue the BK prefix tables were created have the historical data.  
Robert put a process in place to copy to the tables nightly and we wil be using them for the reports.

Updated 2/23/16  Tracy Dennis
Changed BKTxnMedia to left join, PaymentAmount and ChangeDue to display 0 when null.  This is so that payments made with coupon for total amount show on the report.

Updated 5/26/16  Tracy Dennis
Added User Name. Added the insert into #media to get redeemed buys that were only for cash.  

Updated 7/27/2016  Tracy Dennis
Added User Name for the #media records.

Updated 1/31/2018 Tracy Dennis
Added join to PCMS_IMPORT..BKTransactionQueue to get session information.  This will not work after the Back Office changes.  Looking at the records from #Media noticed that joins to
BKSession and BKTxnTaxes were not needed since they were not pulling back the needed information and the BKTxnHeader is available for all the redeemed buys that were only for cash.

Update 6/27/2018 Tracy Dennis
Changes to run on Orange
******************************************************************/
/*
declare @LocationNo char(5), 
	@StartDate datetime, 
	@EndDate datetime
set @LocationNo = '00060'
set @StartDate = '2/1/2014'
set @EndDate = '2/1/2014'

update 07/27/18 Bijoy Paul
1.FN_BK_XML3ID_RangeByDate, 
2.@debug
3. removed individual order by 
	--ORDER BY tillNumber
	--,transactionNumber
replaced with final order by with union

*/

--BKTxnHeader

declare @debug bit = 0


declare @XML3IDStart bigint, @XML3IDEnd bigint, @LocationNo4Join char(4)
declare @EndDatePlus1Day date = dateadd(day, 1, @EndDate)

if @debug = 1 select getdate() 'exec fn'

select @XML3IDStart = XML3IDStart, @XML3IDEnd = XML3IDEnd
from PCMS_IMPORT.dbo.FN_BK_XML3ID_RangeByDate (@StartDate, @EndDate)

if @debug = 1 select getdate() 'exec fn-done'
if @debug = 1 select @XML3IDStart '@XML3IDStart', @XML3IDEnd '@XML3IDEnd'

set @LocationNo4Join = right(@LocationNo, 4)

--@myHeader --PCMS_IMPORT..BKTxnHeader
declare @myHeader TABLE(
	[XML3ID] [int] NOT NULL,
	[database] [varchar](60) NULL,
	[build] [varchar](60) NULL,
	[transactionType] [varchar](512) NULL,
	[bonusPoints] [decimal](38, 6) NULL,
	[businessTransaction] [bit] NULL,
	[chargeCompanyCode] [varchar](10) NULL,
	[chargeDept] [varchar](10) NULL,
	[chargeEmployee] [varchar](60) NULL,
	[chargeStoreCode] [varchar](10) NULL,
	[collectionDate] [varchar](22) NULL,
	[companyCode] [varchar](10) NULL,
	[consumeItem] [int] NULL,
	[customerDesignatorID] [varchar](38) NULL,
	[customerID] [varchar](100) NULL,
	[customerIdMethod] [varchar](255) NULL,
	[customerLoyaltyCardLoyaltyCardNumber] [varchar](2048) NULL,
	[deferredStaffDiscount] [bit] NULL,
	[destinationCode] [varchar](10) NULL,
	[earnedPoints] [decimal](38, 6) NOT NULL,
	[externalAccount] [varchar](2048) NULL,
	[externalRef] [varchar](100) NULL,
	[externalRefVersion] [varchar](38) NULL,
	[flightCode] [varchar](10) NULL,
	[finishDateTime] [varchar](22) NULL,
	[giftReceipt] [bit] NULL,
	[giftReceiptRefundExpiry] [varchar](10) NULL,
	[guestCount] [varchar](38) NULL,
	[legalTender] [varchar](10) NULL,
	[logonString] [varchar](2048) NULL,
	[loyaltyCardExpiryDate] [varchar](10) NULL,
	[loyaltyCardTypeConstant] [int] NULL,
	[loyaltySchemeName] [varchar](60) NULL,
	[loyaltyValue] [decimal](38, 6) NULL,
	[operatorOperatorCode] [varchar](60) NULL,
	[orderValue] [decimal](38, 6) NULL,
	[originalCompanyCode] [varchar](10) NULL,
	[originalDate] [varchar](22) NULL,
	[originalStoreCode] [varchar](10) NULL,
	[originalTillID] [varchar](30) NULL,
	[originalTransactionNumber] [varchar](10) NULL,
	[pickupNumber] [varchar](38) NULL,
	[processingTypeValidationCodeConst] [int] NULL,
	[promotionPoints] [decimal](38, 6) NULL,
	[publishID] [varchar](38) NULL,
	[reasonCodeCompany] [varchar](10) NULL,
	[reasonCodeTaxExemption] [varchar](10) NULL,
	[reasonReasonCode] [varchar](10) NULL,
	[reasonReasonTypeReasonType] [varchar](10) NULL,
	[reasonTypeTaxExemption] [varchar](10) NULL,
	[recallRef] [varchar](255) NULL,
	[receiptNumber] [varchar](10) NULL,
	[redeemPoints] [decimal](38, 6) NULL,
	[refundExpiry] [varchar](10) NULL,
	[salesPersonCode] [varchar](60) NULL,
	[salesPersonCode2] [varchar](10) NULL,
	[sealNumber] [varchar](2048) NULL,
	[socialSecurityNumber] [varchar](1024) NULL,
	[sourceSystem] [varchar](10) NULL,
	[staffDiscountRequested] [bit] NULL,
	[startDateTime] [varchar](22) NULL,
	[status] [varchar](10) NULL,
	[storeCode] [varchar](10) NULL,
	[supervisorCode] [varchar](60) NULL,
	[supervisorDateTime] [varchar](22) NULL,
	[taxExempt] [bit] NULL,
	[taxExemptCertificate] [varchar](10) NULL,
	[taxExemptionExpiryDate] [varchar](60) NULL,
	[taxOverride] [varchar](10) NULL,
	[tillLocation] [varchar](30) NULL,
	[tillNumber] [varchar](30) NOT NULL,
	[tillPersonality] [varchar](10) NULL,
	[tillStatus] [int] NULL,
	[totalTime] [varchar](20) NULL,
	[tradingDate] [varchar](22) NULL,
	[trainingMode] [bit] NULL,
	[transactionNumber] [varchar](38) NOT NULL,
	[transactionTypeTransactionType] [varchar](38) NULL,
	[valueDue] [decimal](38, 6) NULL,
	[valueGross] [decimal](38, 6) NULL,
	[valueNett] [decimal](38, 6) NULL,
	[valueRounding] [decimal](38, 6) NULL,
	[valueTax] [decimal](38, 6) NULL,
	[voided] [bit] NULL,
	[Class] [varchar](255) NULL,
	[action] [varchar](38) NULL)

--PCMS_IMPORT..BKTxnHeader
if @XML3IDEnd is null begin
	insert @myHeader
	select h.* from PCMS_IMPORT..BKTxnHeader h WITH (NOLOCK)
	where	h.XML3ID >= @XML3IDStart
			and h.storeCode = @LocationNo4Join
end else begin

	insert @myHeader
	select h.* from PCMS_IMPORT..BKTxnHeader h WITH (NOLOCK)
	where	h.XML3ID >= @XML3IDStart
			and h.XML3ID <= @XML3IDEnd
			and h.storeCode = @LocationNo4Join
end

/*
--PCMS_IMPORT..BKTxnHeader
select * into #myHeader from PCMS_IMPORT..BKTxnHeader h WITH (NOLOCK)
where	h.XML3ID >= @XML3IDStart
		and h.XML3ID <= @XML3IDEnd
		and h.storeCode = @LocationNo4Join
*/

if @debug = 1 select getdate() 'BKTxnHeader-done'

--CREATE CLUSTERED INDEX [IX_myHeader] ON #myHeader ([XML3ID] ASC, tillNumber ASC, transactionNumber ASC)

--PCMS_IMPORT..BKTxnMedia
select m.* into #myMedia from PCMS_IMPORT..BKTxnMedia m WITH (NOLOCK)
inner join @myHeader h 
on m.XML3ID = h.XML3ID

if @debug = 1 select getdate() 'BKTxnMedia-done'

CREATE NONCLUSTERED INDEX [IX_myMedia] ON #myMedia ([XML3ID] ASC, tillNumber ASC, transactionNumber ASC) include ( type, voided, voidingLine, amountLocal)

/*
select * into #myMedia2 from #myMedia


if @debug = 1 select getdate() '#myMedia2-done'

CREATE CLUSTERED INDEX [IX_myMedia2] ON #myMedia2 ([XML3ID] ASC, tillNumber ASC, transactionNumber ASC)
*/
--BKTxnDetail
select d.* into #myDetail from PCMS_IMPORT..BKTxnDetail d WITH (NOLOCK)
inner join @myHeader h 
on h.XML3ID = d.XML3ID

if @debug = 1 select getdate() 'BKTxnDetail-done'

CREATE CLUSTERED INDEX [IX_myDetail] ON #myDetail ([XML3ID] ASC, tillNumber ASC, transactionNumber ASC)

--BKTransactionQueue
select q.* into #myQueue from PCMS_IMPORT..BKTransactionQueue q WITH (NOLOCK)
inner join @myHeader h 
on h.XML3ID = q.XML3ID

CREATE CLUSTERED INDEX [IX_myQueue] ON #myQueue ([XML3ID] ASC, tillNumber ASC, transactionNumber ASC, SessionID asc)

if @debug = 1 select getdate() 'BKTransactionQueue-done'


SELECT h.XML3ID
	,h.customerLoyaltyCardLoyaltyCardNumber [EmployeeCard]
	,convert(DATETIME, h.finishDateTime) [TransactionDate]
	--,h.operatorOperatorCode [User]	
	,isnull(ASU.NAME, h.operatorOperatorCode) [User]
	,ret.ReturnCodeAlias [ReturnReason]
	,h.storeCode
	,CASE 
		WHEN h.taxExempt = 1
			THEN 'Y'
		ELSE 'N'
		END [TaxExempt]
	,h.transactionNumber
	,h.tillNumber
	,s.sessionid
	,h.tradingDate
	,h.valueDue
	,h.valueTax
	,isnull(m1.amountLocal, 0) [PaymentAmount]
	--,m1.amountLocal [PaymentAmount]		
	,m1.detailNumber
	,isnull(m2.amountLocal, 0) [ChangeDue]
	--,m2.amountLocal [ChangeDue]
	,isnull(CASE 
			WHEN media.MediaType = 4
				AND media.MediaNumber = 99
				THEN '5'
			ELSE media.MediaType
			END, '15') [MediaType] --changing gift cards to media type 5 to make payment filtering simpler
	,isnull(media.MediaNumber, '') [MediaNumber]
	,CASE 
		WHEN media.MediaType = 6
			AND media.MediaNumber = 270
			THEN 'REDEEMEDBUY'
		WHEN media.SalesPaymentType = 'GIFTCARD'
			THEN m1.cardProductName
		WHEN media.SalesPaymentType IS NULL
			THEN 'AR'
		ELSE media.SalesPaymentType
		END [PaymentType]
	--,case when m1.accountNumber <> '' then m1.accountNumber else m1.serialNumber end [PaymentMediaNumber] ---RAF 092315 added below to get the AR account info when possible.
	,CASE 
		WHEN isnull(TXD.paymentRef, '') <> ''
			THEN TxD.paymentRef
		WHEN m1.accountNumber <> ''
			THEN m1.accountNumber
		ELSE m1.serialNumber
		END [PaymentMediaNumber]
INTO #Detail
FROM @myHeader h -- WITH (NOLOCK)
--from TxnHeader h with (nolock)
LEFT JOIN #myMedia m1 WITH (NOLOCK)
	--join BKTxnMedia m1 with (nolock)
	--join TxnMedia m1 with (nolock)
	ON m1.XML3ID = h.XML3ID
	AND m1.tillNumber = h.tillNumber
	AND m1.transactionNumber = h.transactionNumber
	AND m1.type <> 11 --do not include change due
	AND m1.voided = 0
	AND m1.voidingLine = 0
	AND m1.amountLocal <> 0.00

LEFT JOIN #myMedia m2 WITH (NOLOCK)
	--left join TxnMedia m2 with (nolock)
	ON m2.XML3ID = h.XML3ID
	AND m1.tillNumber = h.tillNumber
	AND m1.transactionNumber = h.transactionNumber
	AND m2.type = 11 --only include change due
	AND m2.voided = 0
	AND m2.voidingLine = 0

LEFT JOIN PCMS_IMPORT..PCMSMediaLookup media WITH (NOLOCK) ON media.MediaNumber = m1.mediaInfoMediaNumber
	AND media.MediaType = m1.mediaInfoMediaTypeMediaType
LEFT JOIN PCMS_IMPORT..ReturnCodeTranslate ret WITH (NOLOCK) ON ret.ReturnCode = h.reasonReasonCode
LEFT JOIN #myDetail TxD WITH (NOLOCK)
	--left join TxnDetail TxD with (nolock)
	ON TxD.XML3ID = h.XML3ID
	AND TxD.transLineTypeTransLineType = 12

LEFT JOIN ReportsData..ASUsers ASU WITH (NOLOCK) ON lower(h.operatorOperatorCode) = lower(rtrim(ASU.UserChar30))
left Join #myQueue S with (nolock) on
				S.storeCode = h.storeCode and
				S.tillNumber = h.tillNumber and
				S.transactionNumber = h.transactionNumber and 
				h.transactionType = 'transactionSale' and
		        S.SessionID > ''
WHERE h.storeCode = @LocationNo4Join --right(@LocationNo, 4)
	AND Convert(DATE, h.finishDateTime) >= @StartDate
	AND convert(DATE, h.finishDateTime) < @EndDatePlus1Day --dateadd(day, 1, @EndDate)
	AND h.transactionTypeTransactionType IN (3)
	AND h.trainingMode = 0
	AND h.voided = 0
	AND h.STATUS = 0 --0=Normal, 1=Suspended, 2=Recalled, 3=Rekeyed, 4=Quick-refunded, 5=Post-voided
--ORDER BY h.tillNumber
--	,h.transactionNumber

if @debug = 1 select getdate() 'select1-done'

--select * from #Detail
--This is get the Redeemed Buys for only cash / nothing is purchased
SELECT m1.XML3ID
	,'' [EmployeeCard]
	,convert(DATETIME, m1.tenderDateTime) [TransactionDate]
	--,s.operatorOperatorCode [UserName]	
	,isnull(ASU.NAME, TxH.operatorOperatorCode) [User]
	,ret.ReturnCodeAlias [ReturnReason]
	,m1.storeCode
	--,'' [TaxExempt]
	,CASE 
		WHEN TxH.taxExempt = 1
			THEN 'Y'
		ELSE 'N'
		END [TaxExempt]
	,m1.transactionNumber
	,m1.tillNumber
	,s.sessionId
	,TxH.tradingDate
	--,s.tradingDate
	--,0 [valueDue]
	,TxH.valueDue
	--,tax.amount [valueTax]
	,TxH.valueTax
	,isnull(m1.amountLocal, 0) [PaymentAmount]
	,m1.detailNumber
	,isnull(m2.amountLocal, 0) [ChangeDue]
	,isnull(CASE 
			WHEN media.MediaType = 4
				AND media.MediaNumber = 99
				THEN '5'
			ELSE media.MediaType
			END, '15') [MediaType] --changing gift cards to media type 5 to make payment filtering simpler
	,isnull(media.MediaNumber, '') [MediaNumber]
	,CASE 
		WHEN media.MediaType = 6
			AND media.MediaNumber = 270
			THEN 'REDEEMEDBUY'
		WHEN media.SalesPaymentType = 'GIFTCARD'
			THEN m1.cardProductName
		WHEN media.SalesPaymentType IS NULL
			THEN 'AR'
		ELSE media.SalesPaymentType
		END [PaymentType]
	,CASE 
		WHEN isnull(TXD.paymentRef, '') <> ''
			THEN TxD.paymentRef
		WHEN m1.accountNumber <> ''
			THEN m1.accountNumber
		ELSE m1.serialNumber
		END [PaymentMediaNumber]
INTO #Media
FROM #myMedia  m1 WITH (NOLOCK)
LEFT JOIN #myMedia m2 WITH (NOLOCK) ON m2.XML3ID = m1.XML3ID
	AND m1.tillNumber = m1.tillNumber
	AND m1.transactionNumber = m1.transactionNumber
	AND m2.type = 11 --only include change due
	AND m2.voided = 0
	AND m2.voidingLine = 0
LEFT JOIN PCMS_IMPORT..PCMSMediaLookup media WITH (NOLOCK) ON media.MediaNumber = m1.mediaInfoMediaNumber
	AND media.MediaType = m1.mediaInfoMediaTypeMediaType
LEFT JOIN PCMS_IMPORT..ReturnCodeTranslate ret WITH (NOLOCK) ON ret.ReturnCode = m1.reasonReasonCode
LEFT JOIN #myDetail TxD WITH (NOLOCK) ON TxD.XML3ID = m1.XML3ID
	AND TxD.transLineTypeTransLineType = 12
--LEFT JOIN dbo.BKSession s WITH (NOLOCK) ON s.XML3ID = m1.XML3ID
--	AND s.tillTillNumber = m1.tillNumber
--	AND s.transactionNumber = m1.transactionNumber
--LEFT JOIN BKTxnTaxes tax WITH (NOLOCK) ON tax.XML3ID = m1.XML3ID
--	AND tax.transactionNumber = m1.transactionNumber
--	AND tax.tillNumber = m1.tillNumber
--	AND tax.voided = 0
LEFT JOIN @myHeader TxH --WITH (NOLOCK) 
	ON TxH.XML3ID = m1.XML3ID
LEFT JOIN ReportsData..ASUsers ASU WITH (NOLOCK) ON lower(TxH.operatorOperatorCode) = lower(rtrim(ASU.UserChar30))
left Join #myQueue S with (nolock) on
				S.storeCode = TxH.storeCode and
				S.tillNumber =TxH.tillNumber and
				S.transactionNumber = TxH.transactionNumber and 
				S.SessionID > ''

WHERE m1.storeCode = @LocationNo4Join --right(@LocationNo, 4)
	AND Convert(DATE, m1.tenderDateTime) >= @StartDate
	AND convert(DATE, m1.tenderDateTime) < @EndDatePlus1Day --dateadd(day, 1, @EndDate)
	--AND isnull(s.trainingMode, 0) = 0
	AND m1.voided = 0
	AND m1.type <> 11 --do not include change due
	AND m1.voided = 0
	AND m1.voidingLine = 0
	AND m1.amountLocal <> 0.00
	AND m1.XML3ID NOT IN (
		SELECT DISTINCT XML3ID
		FROM #Detail
		) --don't get records that have a #Detail record, this ends up adding only the redeemed buys for cash only
--ORDER BY tillNumber
	--,transactionNumber

if @debug = 1 select getdate() 'select2-done'

--SELECT *
--FROM #Media

(
SELECT *
FROM #Detail

UNION ALL

SELECT *
FROM #Media)

ORDER BY tillNumber
	,transactionNumber

DROP TABLE #Detail

DROP TABLE #Media



GO


