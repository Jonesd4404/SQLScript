USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[INV_InventoryByLocation_PS_V3]    Script Date: 6/24/2019 11:05:35 AM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


Create PROCEDURE [dbo].[INV_InventoryByLocation_PS_V3]
	--DECLARE 
	@Inventory_Description1 VARCHAR(50) 
	--='2019 January Scheduled Inventory'
	,@Inventory_Description2 VARCHAR(50) 
	--='2018 January Scheduled Inventory'
AS
/************************************************************************************************************************************************************
New: 6/24/2019
Created By: Tracy Dennis

            Based off of INV_InventoryByLocation_PS_V9 (Binding version).  Changed to use Actual Cost for New Goods instead of Reports..RU_CDC_ShippedCost
			that the _PS, _PS_V2, _PS_V5, and _PS_V9 versions use. This one is V3 since it was the original version that was to use Product master for cost 
			and price, but it was decided to keep using the roll up tables.  I kept the version 3 seperate since it was thought one day that we would use it. 
		    Actual Cost is in the HPB_INV..Scheduled_Inventory_Reporting which is derived from Product Master for New Goods.  Removed the date logic since 
		    it was used primarly to overide cost in the tables. Note this version does not have any specfic logic for binding since product type is the best 
			way to get the RptPTypeClass. SD #15143

Update Reason: 

*************************************************************************************************************************************************************/

/*INVENTORY data 1*/
SELECT i.LocationNo
	,i.Inventory_Description AS Inventory_Description1
	,rpt.RptPTypeClass AS rptPTypeClass
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity1
	,ISNULL(SUM(i.Factor * i.Cost), 0)	AS Cost1
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price1
INTO #INV1
FROM ReportsData..RptProductTypes rpt
JOIN HPB_INV..Scheduled_Inventory_Reporting i ON i.ProductType = rpt.ProductType
	AND Inventory_Description = @Inventory_Description1
GROUP BY i.LocationNo
	,i.Inventory_Description
	,rpt.RptPTypeClass

/*=======================================================================
inventory data 2*/
SELECT i.LocationNo
	,i.Inventory_Description AS Inventory_Description2
	,rpt.RptPTypeClass AS rptPTypeClass
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity2
	,ISNULL(SUM(i.Factor * i.Cost), 0)	AS Cost2
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price2
INTO #INV2
FROM ReportsData..RptProductTypes rpt
JOIN HPB_INV..Scheduled_Inventory_Reporting i ON i.ProductType = rpt.ProductType
	AND Inventory_Description = @Inventory_Description2
GROUP BY i.LocationNo
	,i.Inventory_ID
	,i.Inventory_Description
	,rpt.RptPTypeClass

/*========================================================================
Final report....
*/
--Select * from #INV1
--Select * from #INV2
SELECT isnull(i1.LocationNo, i2.LocationNo) [LocationNo]
	,NAME [LocationName]
	,Inventory_Description1
	,Inventory_Description2
	,ISNULL(i1.rptPTypeClass, i2.rptPTypeClass) [RptPTypeClass]
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
			OR Quantity2 IS NULL
			THEN 100
		WHEN Quantity1 = 0
			OR Quantity1 IS NULL
			THEN - 100
		ELSE (((Convert(DECIMAL(12, 4), Quantity1)) - (Convert(DECIMAL(12, 4), Quantity2))) / (Convert(DECIMAL(12, 4), Quantity2))) * 100
		END [PctQtyChange]
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
FULL JOIN #INV2 i2 ON i2.LocationNo = i1.LocationNo
	AND i1.rptPTypeClass = i2.rptPTypeClass
JOIN ReportsData..Locations loc ON loc.LocationNo = ISNULL(i1.LocationNo, i2.LocationNo)
WHERE (
		Quantity1 > 0
		OR Quantity2 > 0
		)
ORDER BY isnull(i1.LocationNo, i2.LocationNo)
	,ISNULL(i1.rptPTypeClass, i2.rptPTypeClass)

/*=======================================================================*/
DROP TABLE #INV1

DROP TABLE #INV2

GO


