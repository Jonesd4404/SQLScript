USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[INV_InventoryByStoreSection_PS_V3]    Script Date: 7/2/2019 6:43:56 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[INV_InventoryByStoreSection_PS_V3]
	--DECLARE
	@Inventory_ID1 INT
	--=1034 --19 jan 2019
	--= 1144 --1 June 2019
	,@Inventory_ID2 INT
	--=0
	--=1016 --1 jan 2019
	,@LocationNo1 AS CHAR(5)
	--= '00019'
	--= '00001'
	,@LocationNo2 AS CHAR(5)
	--= '00001'
AS
/************************************************************************************************************************************************************
Created: 7/2/2019
Created By: Tracy Dennis

New Version:  Based off of INV_InventoryByStoreSection_PS_V9 (Binding version).  Changed to use Actual Cost for New Goods instead of Reports..RU_CDC_ShippedCost
			  that the _PS, _PS_V2, _PS_V5, and _PS_V9 versions use. This one is V3 since it was the original version that was to use Product Master for cost 
			  and price, but it was decided to keep using the roll up tables.  I kept the version 3 seperate since it was thought one day that we would use it. 
		      Actual Cost is in the HPB_INV..Scheduled_Inventory_Reporting which is derived from Product Master for New Goods.  Removed the date logic since 
		      it was used primarly to overide cost in the tables. SD #15143

Update Reason: 

*************************************************************************************************************************************************************/
SELECT DISTINCT (s.MainSection) AS Subject
INTO #Subject
FROM HPB_INV..INV_Subjects2 s

--select * from #Subject 
DECLARE @Inventory_Description1 VARCHAR(50)
	,@Inventory_Description2 VARCHAR(50)

SELECT @Inventory_Description1 = Inventory_Description
FROM HPB_INV..Scheduled_Inventory_Reporting
WHERE Inventory_ID = @Inventory_ID1
	AND LocationNo = @LocationNo1

SELECT @Inventory_Description2 = Inventory_Description
FROM HPB_INV..Scheduled_Inventory_Reporting
WHERE Inventory_ID = @Inventory_ID2
	AND LocationNo = @LocationNo2

/*=========================================================================
INVENTORY data 1*/
SELECT s.Subject
	,@Inventory_ID1 AS Inventory_ID1
	,i.Inventory_Description AS Inventory_Description1
	,i.BindingName
	,Rpt.PTypeClass AS RptPTypeClass
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity1
	,ISNULL(SUM(i.Factor * i.Cost), 0) AS Cost1
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price1
INTO #INV1
FROM #Subject s
LEFT JOIN HPB_INV..Scheduled_Inventory_Reporting i ON s.Subject = i.Inventory_SectionName
	AND i.Inventory_ID = @Inventory_ID1
	AND i.LocationNo = @LocationNo1
LEFT JOIN ReportsData..ShelfScan_Inventory_Bindings b ON i.BindingName = b.BindingName
LEFT JOIN ReportsData..ProductTypes Rpt ON Rpt.ProductType = i.ProductType
GROUP BY i.Inventory_ID
	,i.Inventory_Description
	,s.Subject
	,i.BindingName
	,Rpt.PTypeClass

/*=======================================================================
inventory data 2*/
SELECT s.Subject
	,i.Inventory_ID AS Inventory_ID2
	,i.Inventory_Description AS Inventory_Description2
	,i.BindingName
	,Rpt.PTypeClass AS RptPTypeClass
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity2
	,ISNULL(SUM(i.Factor * i.Cost), 0) AS Cost2
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price2
INTO #INV2
FROM #Subject s
LEFT JOIN HPB_INV..Scheduled_Inventory_Reporting i ON s.Subject = i.Inventory_SectionName
	AND Inventory_ID = @Inventory_ID2
	AND LocationNo = @LocationNo2
LEFT JOIN ReportsData..ShelfScan_Inventory_Bindings b ON i.Bindingname = b.Bindingname
LEFT JOIN ReportsData..ProductTypes Rpt ON Rpt.ProductType = i.ProductType
GROUP BY i.Inventory_ID
	,i.Inventory_Description
	,s.Subject
	,i.BindingName
	,Rpt.PTypeClass

/*========================================================================
Final report....
*/
--Select * from #INV1
--Select * from #INV2
SELECT isnull(i1.Subject, i2.Subject) [Subject]
	,isnull(i1.BindingName, i2.BindingName) [BindingName]
	,ISNULL(i1.RptPTypeClass, i2.RptPTypeClass) [RptPTypeClass]
	,Inventory_ID1
	,Inventory_ID2
	,Inventory_Description1
	,Inventory_Description2
	,isnull(Quantity1, 0) [CurrQty]
	,isnull(Quantity2, 0) [PrevQty]
	,(isnull(Quantity1, 0) - isnull(Quantity2, 0)) [QtyChange]
	,CASE 
		WHEN Quantity2 = 0
			OR Quantity2 IS NULL
			THEN 100
		WHEN Quantity1 = 0
			OR Quantity1 IS NULL
			THEN - 100
		ELSE (((Convert(DECIMAL(12, 4), Quantity1)) - (Convert(DECIMAL(12, 4), Quantity2))) / (Convert(DECIMAL(12, 4), Quantity2))) * 100
		END [PctQtyChange]
	,isnull(Cost1, 0) [CurrCost]
	,isnull(Cost2, 0) [PrevCost]
	,(isnull(Cost1, 0) - isnull(Cost2, 0)) [CostChange]
	,CASE 
		WHEN Cost2 = 0
			OR Cost2 IS NULL
			THEN 100
		WHEN Cost1 = 0
			OR Cost1 IS NULL
			THEN - 100
		ELSE ((Cost1 - Cost2) / Cost2) * 100
		END [PctCostChange]
	,CASE 
		WHEN Quantity1 = 0
			OR Quantity1 IS NULL
			OR Cost1 IS NULL
			THEN 0
		ELSE Cost1 / Quantity1
		END [CurrAvgCost]
	,CASE 
		WHEN Quantity2 = 0
			OR Quantity2 IS NULL
			OR Cost2 IS NULL
			THEN 0
		ELSE Cost2 / Quantity2
		END [PrevAvgCost]
	,isnull(Price1, 0) [CurrRetailPrice]
	,isnull(Price2, 0) [PrevRetailPrice]
	,CASE 
		WHEN Quantity1 = 0
			OR Quantity1 IS NULL
			OR Price1 IS NULL
			THEN 0
		ELSE Price1 / Quantity1
		END [CurrAvgPrice]
	,CASE 
		WHEN Quantity2 = 0
			OR Quantity2 IS NULL
			OR Price2 IS NULL
			THEN 0
		ELSE Price2 / Quantity2
		END [PrevAvgPrice]
	,(isnull(Price1, 0) - isnull(Price2, 0)) [PriceChange]
	,CASE 
		WHEN Price2 = 0
			OR Price2 IS NULL
			THEN 100
		WHEN Price1 = 0
			OR Price1 IS NULL
			THEN - 100
		ELSE ((Price1 - Price2) / Price2) * 100
		END [PctPriceChange]
FROM #INV1 i1
FULL JOIN #INV2 i2 ON i1.Subject = i2.Subject
	AND i1.RptPTypeClass = i2.RptPTypeClass
	AND i1.BindingName = i2.BindingName
WHERE (
		Quantity1 > 0
		OR Quantity2 > 0
		)
ORDER BY isnull(i1.Subject, i2.Subject)
	,isnull(i1.BindingName, i2.BindingName)
	,ISNULL(i1.RptPTypeClass, i2.RptPTypeClass)

/*=======================================================================*/
DROP TABLE #INV1

DROP TABLE #INV2

DROP TABLE #Subject
GO


