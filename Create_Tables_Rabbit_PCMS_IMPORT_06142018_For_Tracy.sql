USE [PCMS_IMPORT]
GO

/****** Object:  Table [dbo].[BKSession]    Script Date: 6/14/2018 10:44:56 AM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[BKSession](
--	[XML3ID] [int] NOT NULL,
--	[database] [varchar](60) NULL,
--	[build] [varchar](60) NULL,
--	[transactionType] [varchar](512) NULL,
--	[actualEndDateTime] [varchar](22) NULL,
--	[closeMethod] [int] NULL,
--	[companyCode] [varchar](10) NULL,
--	[expectedEndDateTime] [varchar](22) NULL,
--	[forced] [bit] NULL,
--	[frequency] [int] NULL,
--	[imbalanceReason] [varchar](2048) NULL,
--	[openMethod] [int] NULL,
--	[operatorOperatorCode] [varchar](60) NULL,
--	[sapControlNumber] [varchar](38) NULL,
--	[sessionID] [varchar](38) NULL,
--	[startDateTime] [varchar](22) NULL,
--	[statusStatusCode] [int] NULL,
--	[storeCode] [varchar](10) NULL,
--	[tillTillNumber] [varchar](30) NULL,
--	[tradingDate] [varchar](10) NULL,
--	[trainingMode] [bit] NULL,
--	[transactionNumber] [varchar](38) NULL,
--	[Class] [varchar](255) NULL,
--	[action] [varchar](38) NULL,
-- CONSTRAINT [PK_BKSession] PRIMARY KEY CLUSTERED 
--(
--	[XML3ID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--) ON [PRIMARY]

--GO

/****** Object:  Table [dbo].[BKTransactionQueue]    Script Date: 6/14/2018 10:44:56 AM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[BKTransactionQueue](
--	[XML3ID] [int] NOT NULL,
--	[database] [varchar](60) NULL,
--	[build] [varchar](60) NULL,
--	[transactionType] [varchar](512) NULL,
--	[companyCode] [varchar](10) NULL,
--	[sessionId] [varchar](38) NULL,
--	[status] [varchar](10) NULL,
--	[storeCode] [varchar](10) NULL,
--	[tillNumber] [varchar](30) NOT NULL,
--	[transactionNumber] [varchar](38) NOT NULL,
--	[Class] [varchar](255) NULL,
--	[action] [varchar](38) NULL,
-- CONSTRAINT [PK_BKTransactionQueue] PRIMARY KEY CLUSTERED 
--(
--	[XML3ID] ASC,
--	[tillNumber] ASC,
--	[transactionNumber] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--) ON [PRIMARY]

--GO

/****** Object:  Table [dbo].[BKTxnDetail]    Script Date: 6/14/2018 10:44:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BKTxnDetail](
	[XML3ID] [int] NOT NULL,
	[database] [varchar](60) NULL,
	[build] [varchar](60) NULL,
	[transactionType] [varchar](512) NULL,
	[acNumber] [varchar](100) NULL,
	[addressAddressId] [varchar](38) NULL,
	[assetNumber] [varchar](100) NULL,
	[barCodeUsage] [int] NULL,
	[bomReference] [varchar](10) NULL,
	[bonusPoints] [decimal](38, 6) NULL,
	[byDepartment] [bit] NULL,
	[calculatedReading] [varchar](42) NULL,
	[collectionDate] [varchar](22) NULL,
	[colour] [varchar](60) NULL,
	[colourAdditionalInformation] [varchar](255) NULL,
	[companyCode] [varchar](10) NULL,
	[consumeItem] [int] NULL,
	[costCode] [varchar](10) NULL,
	[costPrice] [decimal](38, 6) NULL,
	[delivery] [bit] NULL,
	[departmentCode] [varchar](60) NULL,
	[depositRefundDept] [varchar](38) NULL,
	[depositSaleDept] [varchar](38) NULL,
	[description] [varchar](2048) NULL,
	[detailNumber] [varchar](38) NOT NULL,
	[documentRef] [varchar](100) NULL,
	[earnPoints] [decimal](38, 6) NULL,
	[eftGroup] [varchar](10) NULL,
	[externalStockGroup] [varchar](10) NULL,
	[externalStockNumber] [varchar](10) NULL,
	[extRefNo] [varchar](100) NULL,
	[fuelingPoint] [varchar](10) NULL,
	[fulfilmentInformation] [varchar](255) NULL,
	[giftReceipt] [bit] NULL,
	[includedTaxFreeShopping] [bit] NULL,
	[includeTaxReceipt] [bit] NULL,
	[information] [varchar](2048) NULL,
	[internalProductCode] [varchar](60) NULL,
	[itemRecalled] [bit] NULL,
	[itemReduced] [bit] NULL,
	[itemScanned] [bit] NULL,
	[itemUnknown] [bit] NULL,
	[itemVoid] [bit] NULL,
	[keyedPrice] [decimal](38, 6) NULL,
	[legalTender] [varchar](10) NULL,
	[level] [varchar](38) NULL,
	[level5CompanyCode] [varchar](10) NULL,
	[level5Level5ID] [varchar](60) NULL,
	[level5ProductGroupType] [int] NULL,
	[lineRefund] [bit] NULL,
	[loyaltyParameterExternalCode] [varchar](10) NULL,
	[make] [varchar](255) NULL,
	[managerCode] [varchar](60) NULL,
	[manufacturer] [varchar](100) NULL,
	[material] [varchar](60) NULL,
	[measure] [varchar](42) NULL,
	[measureKeyed] [bit] NULL,
	[merchandisingFormat] [varchar](2048) NULL,
	[mobileTelephone] [varchar](100) NULL,
	[model] [varchar](255) NULL,
	[normallyStocked] [bit] NULL,
	[nozzleNumber] [varchar](10) NULL,
	[operatorOperatorCode] [varchar](60) NULL,
	[orderLineNo] [varchar](38) NULL,
	[orderPriceForeign] [decimal](38, 6) NULL,
	[orderQty] [varchar](42) NULL,
	[originalBarcode] [varchar](60) NULL,
	[originalCompanyCode] [varchar](10) NULL,
	[originalDate] [varchar](22) NULL,
	[originalDetailNumber] [varchar](38) NULL,
	[originalStoreCode] [varchar](10) NULL,
	[originalTillID] [varchar](30) NULL,
	[originalTransactionNumber] [varchar](38) NULL,
	[parentNumber] [varchar](38) NULL,
	[paymentRef] [varchar](100) NULL,
	[pluNumber] [varchar](60) NULL,
	[priceDiscountable] [decimal](38, 6) NULL,
	[priceOverridden] [bit] NULL,
	[priceReducedCode] [varchar](10) NULL,
	[priceReducedPercentage] [decimal](9, 6) NULL,
	[priceSold] [decimal](38, 6) NULL,
	[priceSoldForeign] [decimal](38, 6) NULL,
	[productGender] [varchar](60) NULL,
	[productHandling] [int] NULL,
	[productStopCode] [varchar](60) NULL,
	[promotionPoints] [decimal](38, 6) NULL,
	[pumpNumber] [varchar](10) NULL,
	[quantitySold] [varchar](42) NULL,
	[reasonCodeCompany] [varchar](10) NULL,
	[reasonReasonCode] [varchar](10) NULL,
	[reasonReasonCode2] [varchar](10) NULL,
	[reasonReasonCode3] [varchar](10) NULL,
	[reasonReasonCode4] [varchar](10) NULL,
	[reasonReasonType2] [varchar](10) NULL,
	[reasonReasonType3] [varchar](10) NULL,
	[reasonReasonType4] [varchar](10) NULL,
	[reasonReasonTypeReasonType] [varchar](10) NULL,
	[redeemPoints] [decimal](38, 6) NULL,
	[refundable] [bit] NULL,
	[resellable] [bit] NULL,
	[returnDate] [varchar](10) NULL,
	[returningCompany] [varchar](10) NULL,
	[returningStore] [varchar](10) NULL,
	[returnsUID] [varchar](38) NULL,
	[saleDate] [varchar](22) NULL,
	[saleRefused] [bit] NULL,
	[salesPersonCode] [varchar](60) NULL,
	[salesPersonCode2] [varchar](10) NULL,
	[selfScanItemType] [int] NULL,
	[selfScanPrice] [decimal](38, 6) NULL,
	[selfScanType] [int] NULL,
	[sellingCompany] [varchar](10) NULL,
	[sellingDepartmentCode] [varchar](2048) NULL,
	[sellingStore] [varchar](10) NULL,
	[sellingSubDepartmentCode] [varchar](2048) NULL,
	[serialNumber] [varchar](100) NULL,
	[shape] [varchar](60) NULL,
	[shapeAdditionalInformation] [varchar](2048) NULL,
	[size] [varchar](60) NULL,
	[size2] [varchar](60) NULL,
	[size3] [varchar](60) NULL,
	[sizeAdditionalInformation] [varchar](255) NULL,
	[skuCode] [varchar](60) NULL,
	[skuOwner] [varchar](10) NULL,
	[skuOwnerType] [int] NULL,
	[skuStatus] [int] NULL,
	[staffDiscountable] [bit] NULL,
	[stockCategory] [int] NULL,
	[stockCondition] [int] NULL,
	[stockLocation] [varchar](30) NULL,
	[stockLocationReturn] [varchar](60) NULL,
	[storeCode] [varchar](10) NULL,
	[storeText] [varchar](255) NULL,
	[subReasonCodes] [varchar](2048) NULL,
	[substitutedPluNumber] [varchar](60) NULL,
	[substitutedSkuCode] [varchar](60) NULL,
	[supplierCode] [varchar](100) NULL,
	[supplierManualEntry] [bit] NULL,
	[supplierProductCode] [varchar](60) NULL,
	[systemPrice] [decimal](38, 6) NULL,
	[taxCode] [varchar](10) NULL,
	[taxOverride] [varchar](10) NULL,
	[testerName] [varchar](60) NULL,
	[tillNumber] [varchar](30) NOT NULL,
	[transactionNumber] [varchar](38) NOT NULL,
	[transLineTypeTransLineType] [varchar](10) NULL,
	[unitOfMeasure] [varchar](10) NULL,
	[valConstPayRef] [int] NULL,
	[valConstReasonAction] [int] NULL,
	[valueLine] [decimal](38, 6) NULL,
	[valueLineAllDiscounts] [decimal](38, 6) NULL,
	[valueLineExcludingStaffDiscount] [decimal](38, 6) NULL,
	[vended] [int] NULL,
	[vendorText] [varchar](255) NULL,
	[voidingLine] [bit] NULL,
	[warrantyText] [varchar](255) NULL,
	[wasSplitPack] [bit] NULL,
	[Class] [varchar](255) NULL,
	[action] [varchar](38) NULL,
 CONSTRAINT [PK_BKTxnDetail] PRIMARY KEY CLUSTERED 
(
	[XML3ID] ASC,
	[detailNumber] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_BKTxnDetail] UNIQUE NONCLUSTERED 
(
	[companyCode] ASC,
	[storeCode] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC,
	[detailNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[BKTxnDetailDiscount]    Script Date: 6/14/2018 10:44:56 AM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[BKTxnDetailDiscount](
--	[XML3ID] [int] NOT NULL,
--	[database] [varchar](60) NULL,
--	[build] [varchar](60) NULL,
--	[transactionType] [varchar](512) NULL,
--	[amount] [decimal](38, 6) NULL,
--	[amountDiscountable] [decimal](38, 6) NULL,
--	[canBeRecall] [bit] NULL,
--	[companyCode] [varchar](10) NULL,
--	[detailNumber] [varchar](38) NOT NULL,
--	[discountCodeDiscountCode] [varchar](10) NULL,
--	[discountCodeDiscountTypeDiscountType] [varchar](10) NULL,
--	[discountCostCode] [varchar](10) NULL,
--	[discountCostCodeOwner] [varchar](10) NULL,
--	[discountDate] [varchar](22) NULL,
--	[discountNumber] [varchar](38) NOT NULL,
--	[discountText] [varchar](255) NULL,
--	[noTaxEffect] [bit] NULL,
--	[parentDiscountNumber] [varchar](38) NULL,
--	[pluNumber] [varchar](60) NULL,
--	[promotionCampaignCode] [varchar](60) NULL,
--	[promotionCampaignName] [varchar](60) NULL,
--	[promotionCode] [varchar](10) NULL,
--	[promotionID] [varchar](38) NULL,
--	[promotionSetName] [varchar](60) NULL,
--	[promotionUserType] [varchar](255) NULL,
--	[promReceiptText] [varchar](30) NULL,
--	[quantity] [varchar](42) NULL,
--	[rate] [decimal](9, 6) NULL,
--	[reasonCodeCompany] [varchar](10) NULL,
--	[reasonReasonCode] [varchar](10) NULL,
--	[reasonReasonGroup] [int] NULL,
--	[reasonReasonTypeReasonType] [varchar](10) NULL,
--	[reasonRef] [varchar](255) NULL,
--	[reasonRefType] [int] NULL,
--	[redeemPoints] [decimal](38, 6) NULL,
--	[SDTaxCode] [varchar](10) NULL,
--	[SDTaxRate] [decimal](9, 6) NULL,
--	[staffDiscountCategory] [varchar](10) NULL,
--	[storeCode] [varchar](10) NULL,
--	[subReasonCodes] [varchar](2048) NULL,
--	[tillNumber] [varchar](30) NOT NULL,
--	[transactionNumber] [varchar](38) NOT NULL,
--	[triggerDetailNumber] [varchar](38) NULL,
--	[voided] [bit] NULL,
--	[voidingLine] [bit] NULL,
--	[Class] [varchar](255) NULL,
--	[action] [varchar](38) NULL,
-- CONSTRAINT [PK_BKTxnDetailDiscount] PRIMARY KEY CLUSTERED 
--(
--	[XML3ID] ASC,
--	[detailNumber] ASC,
--	[discountNumber] ASC,
--	[tillNumber] ASC,
--	[transactionNumber] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
-- CONSTRAINT [IX_BKTxnDetailDiscount] UNIQUE NONCLUSTERED 
--(
--	[companyCode] ASC,
--	[storeCode] ASC,
--	[tillNumber] ASC,
--	[transactionNumber] ASC,
--	[detailNumber] ASC,
--	[discountNumber] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--) ON [PRIMARY]

--GO

/****** Object:  Table [dbo].[BKTxnDetailTaxes]    Script Date: 6/14/2018 10:44:56 AM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--CREATE TABLE [dbo].[BKTxnDetailTaxes](
--	[XML3ID] [int] NOT NULL,
--	[database] [varchar](60) NULL,
--	[build] [varchar](60) NULL,
--	[transactionType] [varchar](512) NULL,
--	[amount] [decimal](38, 6) NULL,
--	[companyCode] [varchar](10) NULL,
--	[detailNumber] [varchar](38) NOT NULL,
--	[detailNumberVoided] [varchar](38) NULL,
--	[flatAmountExcTax] [decimal](38, 6) NULL,
--	[flatAmountIncTax] [decimal](38, 6) NULL,
--	[parentTaxNumber] [int] NULL,
--	[rate] [decimal](9, 6) NULL,
--	[storeCode] [varchar](10) NULL,
--	[taxCode] [varchar](10) NULL,
--	[taxDate] [varchar](22) NULL,
--	[taxNumber] [varchar](1024) NULL,
--	[taxRuleCode] [varchar](10) NOT NULL,
--	[taxRuleName] [varchar](60) NULL,
--	[tillNumber] [varchar](30) NOT NULL,
--	[transactionNumber] [varchar](38) NOT NULL,
--	[valueTaxable] [decimal](38, 6) NULL,
--	[voided] [bit] NULL,
--	[voidingLine] [bit] NULL,
--	[Class] [varchar](255) NULL,
--	[action] [varchar](38) NULL,
-- CONSTRAINT [PK_BKTxnDetailTaxes] PRIMARY KEY CLUSTERED 
--(
--	[XML3ID] ASC,
--	[detailNumber] ASC,
--	[taxRuleCode] ASC,
--	[tillNumber] ASC,
--	[transactionNumber] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
-- CONSTRAINT [IX_BKTxnDetailTaxes] UNIQUE NONCLUSTERED 
--(
--	[companyCode] ASC,
--	[storeCode] ASC,
--	[tillNumber] ASC,
--	[transactionNumber] ASC,
--	[detailNumber] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--) ON [PRIMARY]

--GO

/****** Object:  Table [dbo].[BKTxnDiscount]    Script Date: 6/14/2018 10:44:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BKTxnDiscount](
	[XML3ID] [int] NOT NULL,
	[database] [varchar](60) NULL,
	[build] [varchar](60) NULL,
	[transactionType] [varchar](512) NULL,
	[amount] [decimal](38, 6) NULL,
	[amountDiscountable] [decimal](38, 6) NULL,
	[bonusPoints] [decimal](38, 6) NULL,
	[companyCode] [varchar](10) NULL,
	[departmentCode] [varchar](60) NULL,
	[discountCodeDiscountCode] [varchar](10) NULL,
	[discountCodeDiscountTypeDiscountType] [varchar](10) NULL,
	[discountCostCode] [varchar](10) NULL,
	[discountCostCodeOwner] [varchar](10) NULL,
	[discountDateTime] [varchar](22) NULL,
	[discountNumber] [varchar](38) NOT NULL,
	[displayDetailNumber] [varchar](38) NULL,
	[earnPoints] [decimal](38, 6) NULL,
	[loyaltyScheduleCode] [varchar](10) NULL,
	[loyaltyScheduleLevelCode] [varchar](10) NULL,
	[loyaltySchemeCode] [varchar](10) NULL,
	[parentDiscountNumber] [varchar](38) NULL,
	[promotionActivationCount] [varchar](38) NULL,
	[promotionCampaignCode] [varchar](60) NULL,
	[promotionCampaignName] [varchar](60) NULL,
	[promotionCode] [varchar](10) NULL,
	[promotionID] [varchar](38) NULL,
	[promotionPoints] [decimal](38, 6) NULL,
	[promotionSetName] [varchar](60) NULL,
	[promotionUserType] [varchar](255) NULL,
	[promReceiptText] [varchar](30) NULL,
	[rate] [decimal](9, 6) NULL,
	[reasonCodeCompany] [varchar](10) NULL,
	[reasonReasonCode] [varchar](10) NULL,
	[reasonReasonGroup] [int] NULL,
	[reasonReasonTypeReasonType] [varchar](10) NULL,
	[reasonRef] [varchar](255) NULL,
	[reasonRefType] [int] NULL,
	[redeemPoints] [decimal](38, 6) NULL,
	[SDTaxCode] [varchar](10) NULL,
	[SDTaxRate] [decimal](9, 6) NULL,
	[staffDiscountCategory] [varchar](10) NULL,
	[storeCode] [varchar](10) NULL,
	[subReasonCodes] [varchar](2048) NULL,
	[tillNumber] [varchar](30) NOT NULL,
	[transactionNumber] [varchar](38) NOT NULL,
	[triggerDetailNumber] [varchar](38) NULL,
	[voided] [bit] NULL,
	[voidingLine] [bit] NULL,
	[Class] [varchar](255) NULL,
	[action] [varchar](38) NULL,
 CONSTRAINT [PK_BKTxnDiscount] PRIMARY KEY CLUSTERED 
(
	[XML3ID] ASC,
	[discountNumber] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[BKTxnHeader]    Script Date: 6/14/2018 10:44:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BKTxnHeader](
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
	[action] [varchar](38) NULL,
 CONSTRAINT [PK_BKTxnHeader] PRIMARY KEY CLUSTERED 
(
	[XML3ID] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_BKTxnHeader] UNIQUE NONCLUSTERED 
(
	[companyCode] ASC,
	[storeCode] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[BKTxnMedia]    Script Date: 6/14/2018 10:44:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BKTxnMedia](
	[XML3ID] [int] NOT NULL,
	[database] [varchar](60) NULL,
	[build] [varchar](60) NULL,
	[transactionType] [varchar](512) NULL,
	[AID] [varchar](60) NULL,
	[AIP] [varchar](2048) NULL,
	[ATC] [varchar](2048) NULL,
	[ATSD] [varchar](10) NULL,
	[CAV] [varchar](255) NULL,
	[CVM] [int] NULL,
	[CVMR] [varchar](2048) NULL,
	[ECI] [varchar](10) NULL,
	[IAD] [varchar](2048) NULL,
	[MDStatus] [varchar](38) NULL,
	[TVR] [varchar](2048) NULL,
	[XID] [varchar](255) NULL,
	[accountNumber] [varchar](100) NULL,
	[amountForeign] [decimal](38, 6) NULL,
	[amountLocal] [decimal](38, 6) NULL,
	[appEffectiveDate] [varchar](2048) NULL,
	[appExpiryDate] [varchar](2048) NULL,
	[appPANSequenceNumber] [varchar](38) NULL,
	[applicationLabel] [varchar](2048) NULL,
	[applicationUsageControl] [varchar](2048) NULL,
	[applicationVersion] [varchar](2048) NULL,
	[authMethod] [varchar](38) NULL,
	[authorisingBank] [varchar](60) NULL,
	[authSystem] [int] NULL,
	[authorisationCode] [varchar](60) NULL,
	[captureMode] [int] NULL,
	[cardLoyaltyPointsBalance] [decimal](38, 6) NULL,
	[cardLoyaltyPointsExpiryDate] [varchar](10) NULL,
	[cardLoyaltyPointsOnlineStatus] [varchar](38) NULL,
	[cardLoyaltyPointsVoucherStatus] [varchar](38) NULL,
	[cardProductName] [varchar](60) NULL,
	[chequeAccountNumber] [varchar](100) NULL,
	[companyCode] [varchar](10) NULL,
	[countryCode] [varchar](10) NULL,
	[cryptogram] [varchar](2048) NULL,
	[cryptogramInformationData] [varchar](2048) NULL,
	[cryptogramType] [varchar](38) NULL,
	[currencyCode] [varchar](2048) NULL,
	[custInstructions] [varchar](255) NULL,
	[customerSequenceNumber] [varchar](38) NULL,
	[detailNumber] [varchar](38) NOT NULL,
	[eftSequenceNumber] [int] NULL,
	[EMVIssuerActionCodeDefault] [varchar](10) NULL,
	[EMVIssuerActionCodeDenial] [varchar](10) NULL,
	[EMVIssuerActionCodeOnline] [varchar](10) NULL,
	[exchangeRate] [decimal](9, 6) NULL,
	[expiryDate] [varchar](6) NULL,
	[issueNumber] [varchar](38) NULL,
	[issuingBank] [varchar](60) NULL,
	[legalTenderNumericCode] [varchar](10) NULL,
	[loyaltySchemeCode] [varchar](10) NULL,
	[loyaltyScheduleCode] [varchar](10) NULL,
	[loyaltyScheduleLevelCode] [varchar](10) NULL,
	[mediaInfoMediaNumber] [varchar](38) NULL,
	[mediaInfoMediaTypeMediaType] [int] NULL,
	[merchantID] [varchar](30) NULL,
	[mileage] [varchar](30) NULL,
	[mnemonic] [varchar](10) NULL,
	[numberTendered] [varchar](38) NULL,
	[olaMethod] [int] NULL,
	[orderNumber] [varchar](2048) NULL,
	[otherCardData] [varchar](2048) NULL,
	[panEncryptedExternal] [varchar](2048) NULL,
	[panEncryptedInternal] [varchar](2048) NULL,
	[panHashed] [varchar](255) NULL,
	[parentDetailNumber] [varchar](38) NULL,
	[pointsOriginal] [decimal](38, 6) NULL,
	[pointsRedeemed] [varchar](38) NULL,
	[posEntryMode] [varchar](2048) NULL,
	[reasonCodeCardKeyed] [varchar](10) NULL,
	[reasonCodeCompany] [varchar](10) NULL,
	[reasonReasonCode] [varchar](10) NULL,
	[reasonReasonTypeReasonType] [varchar](10) NULL,
	[reasonTypeCardKeyed] [varchar](10) NULL,
	[reference] [varchar](2048) NULL,
	[referralCode] [varchar](10) NULL,
	[responseCode] [varchar](2048) NULL,
	[serialNumber] [varchar](100) NULL,
	[serviceCode] [varchar](2048) NULL,
	[sortCode] [varchar](60) NULL,
	[startDate] [varchar](2048) NULL,
	[state] [varchar](38) NULL,
	[storeCode] [varchar](10) NULL,
	[tenderDateTime] [varchar](22) NULL,
	[tenderProcessingError] [int] NULL,
	[terminalCapabilities] [varchar](2048) NULL,
	[terminalID] [varchar](60) NULL,
	[terminalTransactiondate] [varchar](2048) NULL,
	[terminalType] [varchar](2048) NULL,
	[tillNumber] [varchar](30) NOT NULL,
	[transactionNumber] [varchar](38) NOT NULL,
	[transactionStatusInformation] [varchar](2048) NULL,
	[triggerDetailNumber] [varchar](38) NULL,
	[type] [int] NULL,
	[unpredictableNumber] [varchar](38) NULL,
	[voidCode] [varchar](10) NULL,
	[voided] [bit] NULL,
	[voidingLine] [bit] NULL,
	[Class] [varchar](255) NULL,
	[action] [varchar](38) NULL,
 CONSTRAINT [PK_BKTxnMedia] PRIMARY KEY CLUSTERED 
(
	[XML3ID] ASC,
	[detailNumber] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_BKTxnMedia] UNIQUE NONCLUSTERED 
(
	[companyCode] ASC,
	[storeCode] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC,
	[detailNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[BKTxnTaxes]    Script Date: 6/14/2018 10:44:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BKTxnTaxes](
	[XML3ID] [int] NOT NULL,
	[database] [varchar](60) NULL,
	[build] [varchar](60) NULL,
	[transactionType] [varchar](512) NULL,
	[amount] [decimal](38, 6) NULL,
	[companyCode] [varchar](10) NULL,
	[detailNumber] [varchar](38) NOT NULL,
	[rate] [decimal](9, 6) NULL,
	[storeCode] [varchar](10) NULL,
	[taxDate] [varchar](22) NULL,
	[taxLegalDesc] [varchar](1024) NULL,
	[taxNumber] [varchar](1024) NULL,
	[taxRuleCode] [varchar](10) NULL,
	[taxRuleName] [varchar](60) NULL,
	[tillNumber] [varchar](30) NOT NULL,
	[transactionNumber] [varchar](38) NOT NULL,
	[valueTaxable] [decimal](38, 6) NULL,
	[voided] [bit] NULL,
	[Class] [varchar](255) NULL,
	[action] [varchar](38) NULL,
 CONSTRAINT [PK_BKTxnTaxes] PRIMARY KEY CLUSTERED 
(
	[XML3ID] ASC,
	[detailNumber] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[PCMSMediaLookup]    Script Date: 6/14/2018 10:44:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PCMSMediaLookup](
	[MediaType] [int] NOT NULL,
	[MediaNumber] [int] NOT NULL,
	[SalesPaymentType] [char](10) NOT NULL,
 CONSTRAINT [PK_PCMSMediaLookup] PRIMARY KEY CLUSTERED 
(
	[MediaType] ASC,
	[MediaNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[ReturnCodeTranslate]    Script Date: 6/14/2018 10:44:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReturnCodeTranslate](
	[ReturnCode] [varchar](10) NOT NULL,
	[ReturnCodeAlias] [varchar](10) NOT NULL,
	[ReturnCodeOldPOS] [varchar](10) NULL
) ON [PRIMARY]

GO

/****** Object:  Table [dbo].[TxnCustomer]    Script Date: 6/14/2018 10:44:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TxnCustomer](
	[XML3ID] [int] NOT NULL,
	[database] [varchar](60) NULL,
	[build] [varchar](60) NULL,
	[transactionType] [varchar](512) NULL,
	[addCustomer] [bit] NULL,
	[companyCode] [varchar](10) NULL,
	[customerCode] [varchar](100) NULL,
	[customerStatus] [int] NULL,
	[customerSubType] [int] NULL,
	[customerType] [int] NULL,
	[dateOfBirth] [varchar](10) NULL,
	[driversLicense] [varchar](100) NULL,
	[driversLicenseGeogRegion] [varchar](10) NULL,
	[firstName] [varchar](1024) NULL,
	[gender] [int] NULL,
	[initials] [varchar](1024) NULL,
	[languageCode] [varchar](10) NULL,
	[lastName] [varchar](1024) NULL,
	[maritalStatus] [int] NULL,
	[middleName] [varchar](1024) NULL,
	[militaryID] [varchar](1024) NULL,
	[name] [varchar](1024) NULL,
	[occupationCode] [varchar](10) NULL,
	[occupationOther] [varchar](1024) NULL,
	[pan] [varchar](1024) NULL,
	[passportNumber] [varchar](1024) NULL,
	[passportGeogRegion] [varchar](1024) NULL,
	[personalIDNumber] [varchar](1024) NULL,
	[printTaxReceipt] [bit] NULL,
	[preferredContactMethod] [int] NULL,
	[proofOfIdentityMethod1] [int] NULL,
	[proofOfIdentityMethod2] [int] NULL,
	[promoEmail] [bit] NULL,
	[promoMail] [bit] NULL,
	[promoPhone] [bit] NULL,
	[promoText] [bit] NULL,
	[securityAnswer] [varchar](1024) NULL,
	[securityQuestion] [varchar](10) NULL,
	[sequenceNumber] [varchar](38) NOT NULL,
	[shareInformation] [bit] NULL,
	[socialSecurityNumber] [varchar](1024) NULL,
	[storeCode] [varchar](10) NULL,
	[surname2] [varchar](1024) NULL,
	[taxExemptID] [varchar](100) NULL,
	[taxNumber] [varchar](1024) NULL,
	[taxReceiptPrintType] [int] NULL,
	[tillNumber] [varchar](30) NOT NULL,
	[title] [varchar](1024) NULL,
	[transactionNumber] [varchar](38) NOT NULL,
	[Class] [varchar](255) NULL,
	[action] [varchar](38) NULL,
 CONSTRAINT [PK_TxnCustomer] PRIMARY KEY CLUSTERED 
(
	[XML3ID] ASC,
	[sequenceNumber] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_TxnCustomer] UNIQUE NONCLUSTERED 
(
	[companyCode] ASC,
	[storeCode] ASC,
	[tillNumber] ASC,
	[transactionNumber] ASC,
	[sequenceNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


