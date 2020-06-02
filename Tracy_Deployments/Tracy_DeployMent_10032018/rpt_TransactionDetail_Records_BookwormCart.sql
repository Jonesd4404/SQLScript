USE [SIPS]
GO

/****** Object:  StoredProcedure [dbo].[rpt_TransactionDetail_Records_BookwormCart]    Script Date: 09/19/2018 11:48:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[rpt_TransactionDetail_Records_BookwormCart] (
	--DECLARE 
	 @XML3ID int
     --=73589635
	,@TransactionNo VARCHAR(38)
	--='116034'
	,@TillNo VARCHAR(30)
	--= '1'
	 ,@DetailNumber VARCHAR(38)
	 --=0
	)
AS
/********************************************************************
created 09.27.2018 - Tracy Dennis

Gets the details for a single Bookworm Cart POS transaction.  This is what was in the Bookworm Cart so that it can be compared to what is rung up. This is specfically the one off when LP needs to see real time.
********************************************************************/

SELECT 
	bo.orderSystem [CartOrderSystem]
	,bo.binding [CartBinding]
	,bo.title [CartTitle]
	,bo.sku [CartSku]
	,bo.qty [CartQty]
	,bo.price [CartAmount]
	,bo.tax [CartTax]
	,bo.shippingcharge [CartShippingCharge]
	,bo.shippingtax [CartShippingTax]
	,(bo.price + bo.tax + bo.shippingcharge + bo.shippingtax)[CartTotal]
	,bos.NAME [CartStatus]
	,isnull(cu.NAME, bo.checkOutUser) [CartUser]
FROM  Bookworm..Orders bo WITH (NOLOCK) 
LEFT JOIN Bookworm..OrderStatus bos WITH (NOLOCK) ON bos.statusid = bo.statusid
LEFT JOIN Sips..ASUsers CU WITH (NOLOCK) ON bo.checkOutUser <> ''
	AND lower(bo.checkOutUser) = lower(rtrim(CU.UserChar30))
WHERE  bo.XML3ID = @XML3ID
	AND bo.detailNumber = @detailNumber
	AND bo.tillNumber = @TillNo
	AND bo.transactionNumber = @TransactionNo

GO


