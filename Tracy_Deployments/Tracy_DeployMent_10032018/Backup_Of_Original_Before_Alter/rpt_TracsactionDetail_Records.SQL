USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[rpt_TransactionDetail_Records]    Script Date: 10/3/2018 2:32:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE [dbo].[rpt_TransactionDetail_Records] (
--DECLARE 
@LocationNo CHAR(5) 
	--='00001'
	,@TransactionNo VARCHAR(38)
	--= '91633'
	--='108977'
	--='77957'
	--='406426'
	,@TillNo VARCHAR(30)
	 --= '1'
	
	)
AS
/********************************************************************
created 02.17.2014 - dgreen

Gets the details for a single POS transaction.  

Updated 12/14/15 Tracy Dennis Ticket sw#76147 
Due to a another issue the BK prefix tables were created have the historical data.  
Robert put a process in place to copy to the tables nightly and we wil be using them for the reports.

Updated 5/6/16 Tracy Dennis Ticket F0073510 / F0068029 
Added Employee Discount.

Updated 5/26/16  Tracy Dennis
Added User Name

Updated 7/28/16 Tracy Dennis
Added logic if Quanity is '', transLineTypeTransLineType logic in Reason Code, got rid of '' operatorOperatorCode  in ASUsers, and addional user name logic.

Updated 5/10/2017 Tracy Dennis
Casted det.detailNumber as int so it would sort in numerical order

Update 5/22/2017 Tracy Dennis
Added logic to fix Product Type (level5Level5ID) where UC was getting labeled as PBC.  Robert thought PBC and PB coudld potentially be impacted thought the data 
didn't show.  Putting in fix just in case.

Update 6/21/18 Tracy Dennis
Changes to run on Orange
********************************************************************/
/*
**TransLineType = TXDE_DETAIL_TYPE in CDB.TxnDetail**
**Known codes used plus description
DTDT_KNOWN_ITEM_SALE		1	for a txn detail that is a known item sale 
DTDT_UNKNOWN_ITEM_SALE		3	for an unknown item 
DTDT_PLU_SALE				6	for a plu sale item 
DTDT_ACCOUNT_PAYMENT		12	for an account payment 
DTDT_POS_AUDIT_INFO_LINE	15	for a POS audit info line 
DTDT_SUBTOTAL				16	for a subtotal line 
DTDT_TXN_LEVEL_SERVICE		19	for a service line applied to the header 
DTDT_VOID_SALE				21	for a void sale line 
DTDT_GIFT_CARD_SALE			57	Gift Card Sale 
DTDT_GIFT_CARD_TOPUP_CREDIT 58 Gift Card Topup Credit 

**reasonReasonCode = TXDE_RESN_CODE in CDB.TxnDetail
MD		Mark Down
02		Duplicate
03		Gift
04		Changed Mind
05		Employee Error
06		Other
POPR	Price required
PO1		Incorrect Price
PO2		Damaged
PO3		Discontinued
PO4		Managers Discretion
MD		Markdown
COUPON	Coupon
*/

SELECT det.XML3ID
	,det.storeCode [LocationNo]
	,det.tillNumber [Till]
	,det.transactionNumber [Transaction]
	,det.detailNumber [LineNumber]
	,CASE 
		WHEN det.skuCode = '00000000000000005798'
			THEN 'UC'
		WHEN det.skuCode = '00000000000000005787'
			THEN 'PB'
		WHEN det.skuCode = '00000000000000005788'
			THEN 'PBC'
		ELSE det.level5Level5ID --No issues found for the other product types
		END [ProductType]
	,det.serialNumber [BarcodeScan]
	,det.pluNumber [PLUNumber]
	,det.skuCode [SKU]
	,det.description [Title]
	,det.saleDate
	,CASE det.quantitySold
		WHEN ''
			THEN 0
		ELSE convert(INT, convert(DECIMAL(9, 4), det.quantitySold))
		END [Quantity]
	--,convert(int, convert(decimal(9,4), det.quantitySold)) [Quantity]
	,det.valueLine
	,det.valueLineAllDiscounts
	,sum(ddis.amount) [DiscountLineAmount]
	,ddis.promotionCode [PromotionCode]
	,hdis.amount [TotalDiscount]
	,hdis.rate [DiscountPercent]
	,isnull(dtax.amount, 0.00) [TaxAmount]
	,isnull(dtax.rate, 0.00) [TaxRate]
	,CASE 
		WHEN det.lineRefund = '0'
			THEN 'N'
		ELSE 'Y'
		END [Return]
	,CASE 
		WHEN det.reasonReasonCode = 'MD'
			THEN 'Mark Down'
		WHEN det.reasonReasonCode = '02'
			THEN 'Duplicate'
		WHEN det.reasonReasonCode = '03'
			THEN 'Gift'
		WHEN det.reasonReasonCode = '04'
			THEN 'Changed Mind'
		WHEN det.reasonReasonCode = '05'
			THEN 'Employee Error'
		WHEN det.reasonReasonCode = '06'
			THEN 'Other'
		WHEN det.reasonReasonCode = 'POPR'
			THEN 'Price Required'
		WHEN det.reasonReasonCode = 'PO1'
			THEN 'Incorrect Price'
		WHEN det.reasonReasonCode = 'PO2'
			THEN 'Damaged'
		WHEN det.reasonReasonCode = 'PO3'
			THEN 'Discontinued'
		WHEN det.reasonReasonCode = 'PO4'
			THEN 'Manager''s Discretion'
		WHEN det.reasonReasonCode = 'COUPON'
			THEN 'Coupon'
		WHEN det.transLineTypeTransLineType = '15'
			AND det.managerCode <> ''
			THEN 'Mgr Override'
		WHEN det.transLineTypeTransLineType = '15'
			AND det.managerCode = ''
			THEN det.transactionType
		ELSE ''
		END [ReasonCode]
	,CASE 
		WHEN det.priceOverridden = '0'
			THEN 'N'
		ELSE 'Y'
		END [PriceOverridden]
	--,det.managerCode [ManagerOR]
	,isnull(man.NAME, det.managerCode) [ManagerOR]
	--,case when det.managerCode <>''
	--then (select max(Name) from ReportsData..ASUsers  where lower(rtrim(UserChar30)) =lower(det.managerCode) )
	--else det.managerCode
	--end
	--[ManagerOR]
	--,det.operatorOperatorCode [UserName]
	,isnull(ASU.NAME, det.operatorOperatorCode) [UserName]
	,det.originalStoreCode [OriginStore]
	,det.originalTillID [OriginTill]
	,det.originalTransactionNumber [OriginTransaction]
	,det.originalBarcode [OriginBarCode]
	,det.reasonReasonTypeReasonType [ReasonType]
	,det.sellingDepartmentCode [Category]
	,CASE 
		WHEN det.transLineTypeTransLineType = '1'
			THEN 'Known Item'
		WHEN det.transLineTypeTransLineType = '3'
			THEN 'Unknown Item'
		WHEN det.transLineTypeTransLineType = '6'
			THEN 'PLU Sale'
		WHEN det.transLineTypeTransLineType = '12'
			THEN 'AR Account Payment'
		WHEN det.transLineTypeTransLineType = '15'
			THEN 'POS Audit'
		WHEN det.transLineTypeTransLineType = '16'
			THEN 'Subtotal'
		WHEN det.transLineTypeTransLineType = '19'
			THEN 'Service'
		WHEN det.transLineTypeTransLineType = '21'
			THEN 'Void Line'
		WHEN det.transLineTypeTransLineType = '57'
			THEN 'Gift Card Sale'
		WHEN det.transLineTypeTransLineType = '58'
			THEN 'Gift Card Credit'
		ELSE ''
		END [TransactionLineType]
	,ddis.rate
	,ddis.staffDiscountCategory
FROM PCMS_IMPORT..BKTxnDetail det WITH (NOLOCK)
--from TxnDetail det with (nolock)
LEFT JOIN PCMS_IMPORT..BKTxnDetailDiscount ddis WITH (NOLOCK)
	--left join TxnDetailDiscount ddis  with (nolock)
	ON ddis.XML3ID = det.XML3ID
	AND ddis.tillNumber = det.tillNumber
	AND ddis.transactionNumber = det.transactionNumber
	AND ddis.detailNumber = det.detailNumber
	AND ddis.voided = 0
	AND ddis.voidingLine = 0
LEFT JOIN PCMS_IMPORT..BKTxnDiscount hdis WITH (NOLOCK)
	--left join TxnDiscount hdis  with (nolock)
	ON hdis.XML3ID = det.XML3ID
	AND hdis.transactionNumber = det.transactionNumber
	AND hdis.tillNumber = det.tillNumber
	AND hdis.voided = 0
	AND hdis.voidingLine = 0
	AND hdis.promotionCode = det.skuCode
LEFT JOIN PCMS_IMPORT..BKTxnDetailTaxes dtax WITH (NOLOCK)
	--left join TxnDetailTaxes dtax
	ON dtax.XML3ID = det.XML3ID
	AND dtax.tillNumber = det.tillNumber
	AND dtax.transactionNumber = det.transactionNumber
	AND dtax.detailNumber = det.detailNumber
	AND dtax.voided = 0
	AND dtax.voidingLine = 0
LEFT JOIN ReportsData..ASUsers ASU WITH (NOLOCK) ON det.operatorOperatorCode <> ''
	AND lower(det.operatorOperatorCode) = lower(rtrim(ASU.UserChar30))
LEFT JOIN ReportsData..ASUsers man WITH (NOLOCK) ON det.managerCode <> ''
	AND lower(det.managerCode) = lower(rtrim(man.UserChar30))
WHERE det.tillNumber = @TillNo
	AND det.transactionNumber = @TransactionNo
	AND det.storeCode = right(@LocationNo, 4)
	AND det.voidingLine = 0
	AND det.itemVoid = 0
GROUP BY det.XML3ID
	,det.storeCode
	,det.tillNumber
	,det.transactionNumber
	,det.detailNumber
	,det.level5Level5ID
	,det.serialNumber
	,det.pluNumber
	,det.skuCode
	,det.description
	,det.saleDate
	,det.quantitySold
	,det.valueLine
	,det.valueLineAllDiscounts
	--,ddis.amount						
	,ddis.promotionCode
	,hdis.amount
	,hdis.rate
	,dtax.amount
	,dtax.rate
	,det.lineRefund
	,CASE 
		WHEN det.reasonReasonCode = 'MD'
			THEN 'Mark Down'
		WHEN det.reasonReasonCode = '02'
			THEN 'Duplicate'
		WHEN det.reasonReasonCode = '03'
			THEN 'Gift'
		WHEN det.reasonReasonCode = '04'
			THEN 'Changed Mind'
		WHEN det.reasonReasonCode = '05'
			THEN 'Employee Error'
		WHEN det.reasonReasonCode = '06'
			THEN 'Other'
		WHEN det.reasonReasonCode = 'POPR'
			THEN 'Price Required'
		WHEN det.reasonReasonCode = 'PO1'
			THEN 'Incorrect Price'
		WHEN det.reasonReasonCode = 'PO2'
			THEN 'Damaged'
		WHEN det.reasonReasonCode = 'PO3'
			THEN 'Discontinued'
		WHEN det.reasonReasonCode = 'PO4'
			THEN 'Manager''s Discretion'
		WHEN det.reasonReasonCode = 'COUPON'
			THEN 'Coupon'
		WHEN det.transLineTypeTransLineType = '15'
			AND det.managerCode <> ''
			THEN 'Mgr Override'
		WHEN det.transLineTypeTransLineType = '15'
			AND det.managerCode = ''
			THEN det.transactionType
		ELSE ''
		END
	,det.priceOverridden
	--,det.managerCode
	,isnull(man.NAME, det.managerCode)
	--,det.operatorOperatorCode
	,isnull(ASU.NAME, det.operatorOperatorCode)
	,det.originalStoreCode
	,det.originalTillID
	,det.originalTransactionNumber
	,det.originalBarcode
	,det.reasonReasonTypeReasonType
	,det.sellingDepartmentCode
	,det.transLineTypeTransLineType
	,ddis.rate
	,ddis.staffDiscountCategory
ORDER BY cast(det.detailNumber AS INT)

GO

