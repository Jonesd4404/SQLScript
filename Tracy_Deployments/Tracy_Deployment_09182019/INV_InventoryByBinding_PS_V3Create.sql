USE [Reports]
GO


/****** Object:  StoredProcedure [dbo].[INV_InventoryByBinding_PS_V3]    Script Date: 7/2/2019 2:36:39 PM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


Create PROCEDURE [dbo].[INV_InventoryByBinding_PS_V3]
	--DECLARE 
	@Inventory_ID1 INT
	--= 1144 --June 2019
	,@Inventory_ID2 INT
	--= 1016 --Jan 2019
	,@LocationNo1 CHAR(5) --= '00001'
	,@LocationNo2 CHAR(5) --= '00001'
AS
/************************************************************************************************************************************************************
Updated: 5/9/2016
Updated By: Tracy Dennis
Update Reason: 
Updated to use the new Inventory system tables. The Cost for New is done the same way the old system was.

Update: 7/21/16 Tracy Dennis Changed the percentages from -100 to 100 and vice versa.

Update: 5/16/18 Tracy Dennis Changed to use the same time period for used and new.  Also redid by binding instead of product type. Based off of INV_InventoryByType_PS_V5. 
                             Changed the New to use binding to do their averages for cost.

New Version:  7/1/2019 Tracy Dennis #15143 - Based on INV_InventoryByBinding to use Actual Cost for New Goods instead of Reports..RU_CDC_ShippedCost.  Actual Cost is in the   
                             HPB_INV..Scheduled_Inventory_Reporting which is derived from Product Master for New Goods.  Removed the date logic since it was used
		                     primarly to overide cost in the tables.  Did as version 3 to match with the other verions of the reports.
*************************************************************************************************************************************************************/
/*=========================================================================
INVENTORY data 1*/
SELECT @Inventory_ID1 AS Inventory_ID1
	,i.Inventory_Description AS Inventory_Description1
	,i.BindingName AS BindingName
	,Rpt.PTypeClass AS PTypeClass
	,Rpt.PTypeGroup AS PTypeGroup
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity1
	,ISNULL(SUM(i.Factor * i.Cost), 0) AS Cost1
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price1
INTO #INV1
FROM ReportsData..ShelfScan_Inventory_Bindings b
LEFT JOIN HPB_INV..Scheduled_Inventory_Reporting i ON i.BindingCode = b.BindingCode
	AND i.Inventory_ID = @Inventory_ID1
	AND i.LocationNo = @LocationNo1
LEFT JOIN ReportsData..ProductTypes Rpt ON Rpt.ProductType = i.ProductType
GROUP BY i.Inventory_ID
	,i.Inventory_Description
	,i.BindingName
	,Rpt.PTypeClass
	,Rpt.PTypeGroup

--SELECT * FROM #INV1
/*=======================================================================
inventory data 2*/
SELECT @Inventory_ID2 AS Inventory_ID2
	,i.Inventory_Description AS Inventory_Description2
	,i.BindingName AS BindingName
	,Rpt.PTypeClass AS PTypeClass
	,Rpt.PTypeGroup AS PTypeGroup
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity2
	,ISNULL(SUM(i.Factor * i.Cost), 0) AS Cost2
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price2
INTO #INV2
FROM ReportsData..ShelfScan_Inventory_Bindings b
LEFT JOIN HPB_INV..Scheduled_Inventory_Reporting i ON i.BindingCode = b.BindingCode
	AND Inventory_ID = @Inventory_ID2
	AND LocationNo = @LocationNo2
LEFT JOIN ReportsData..ProductTypes Rpt ON Rpt.ProductType = i.ProductType
GROUP BY i.Inventory_ID
	,i.Inventory_Description
	,i.BindingName
	,Rpt.PTypeClass
	,Rpt.PTypeGroup

--Select * from #INV2
/*========================================================================
Final report....
*/
--Select * from #INV1
--Select * from #INV2
SELECT isnull(i1.BindingName, i2.BindingName) [BindingName]
	,isnull(i1.PTypeGroup, i2.PTypeGroup) [ProdTypeGroup]
	,ISNULL(i1.PTypeClass, i2.PTypeClass) [TypeClass]
	,Inventory_ID1
	,Inventory_ID2
	,Inventory_Description1
	,Inventory_Description2
	,Isnull(Quantity1, 0) [CurrQty]
	,isnull(Cost1, 0) [CurrCost]
	,CASE 
		WHEN Quantity1 IS NULL
			OR Cost1 IS NULL
			THEN 0
		WHEN Quantity1 = 0
			THEN 0
		ELSE Cost1 / Quantity1
		END [CurrAvgCost]
	,isnull(Price1, 0) [CurrRetailPrice]
	,CASE 
		WHEN Quantity1 IS NULL
			OR Price1 IS NULL
			THEN 0
		WHEN Quantity1 = 0
			THEN 0
		ELSE Price1 / Quantity1
		END [CurrAvgPrice]
	,isnull(Quantity2, 0) [PrevQty]
	,isnull(Cost2, 0) [PrevCost]
	,CASE 
		WHEN Quantity2 IS NULL
			OR Cost2 IS NULL
			THEN 0
		WHEN Quantity2 = 0
			THEN 0
		ELSE Cost2 / Quantity2
		END [PrevAvgCost]
	,isnull(Price2, 0) [PrevRetailPrice]
	,CASE 
		WHEN Quantity2 IS NULL
			OR Price2 IS NULL
			THEN 0
		WHEN Quantity2 = 0
			THEN 0
		ELSE Price2 / Quantity2
		END [PrevAvgPrice]
	,(isnull(Quantity1, 0) - isnull(Quantity2, 0)) [QtyChange]
	,CASE 
		WHEN Quantity2 = 0
			THEN 100
		WHEN Quantity2 IS NULL
			THEN 100
		WHEN Quantity1 IS NULL
			OR Quantity1 = 0
			THEN - 100
		ELSE (((Convert(DECIMAL(12, 4), Quantity1)) - (Convert(DECIMAL(12, 4), Quantity2))) / (Convert(DECIMAL(12, 4), Quantity2))) * 100
		END [PctQtyChange]
	,(isnull(Cost1, 0) - isnull(Cost2, 0)) [CostChange]
	,CASE 
		WHEN Cost2 IS NULL
			THEN 100
		WHEN Cost1 IS NULL
			OR Cost1 = 0
			THEN - 100
		WHEN Cost2 = 0
			THEN 100
		ELSE ((Cost1 - Cost2) / Cost2) * 100
		END [PctCostChange]
	,(isnull(Price1, 0) - isnull(Price2, 0)) [PriceChange]
	,CASE 
		WHEN Price2 IS NULL
			THEN 100
		WHEN Price1 IS NULL
			OR Price1 = 0
			THEN - 100
		WHEN Price2 = 0
			THEN 100
		ELSE ((Price1 - Price2) / Price2) * 100
		END [PctPriceChange]
FROM #INV1 i1
FULL JOIN #INV2 i2 ON i1.BindingName = i2.BindingName
	AND i1.PTypeGroup = i2.PTypeGroup
	AND i1.PTypeClass = i2.PTypeClass
WHERE (
		Quantity1 > 0
		OR Quantity2 > 0
		)
ORDER BY isnull(i1.BindingName, i2.BindingName)
	,isnull(i1.PTypeGroup, i2.PTypeGroup)
	,ISNULL(i1.PTypeClass, i2.PTypeClass)

/*=======================================================================*/
DROP TABLE #INV1

DROP TABLE #INV2
GO


