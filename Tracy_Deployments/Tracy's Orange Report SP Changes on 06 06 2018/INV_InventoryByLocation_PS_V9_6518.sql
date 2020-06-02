/****** Object:  StoredProcedure [dbo].[INV_InventoryByLocation_PS_V9]    Script Date: 05/23/2018 11:27:53 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[INV_InventoryByLocation_PS_V9]
	--DECLARE 
	@Inventory_Description1 VARCHAR(50) --= 'June 2015 Scheduled Inventory' 
	--='APP TEST INVENTORY'
	,@Inventory_Description2 VARCHAR(50) -- = 'Jan 2015 Scheduled Inventory'
	--='2018 January Scheduled Inventory'
AS
/************************************************************************************************************************************************************
Updated: 5/9/2016
Updated By: Tracy Dennis
Update Reason: 
Updated to use the new Inventory system tables. The Cost for New is done the same way the old system was.

Update: 5/23/18 Tracy Dennis Changed to use the same time period for used and new.  Also redid by binding instead of product type. Based off of INV_InventoryByLocation_PS_V9. 
                             Changed the New to use binding to do their averages for cost.

*************************************************************************************************************************************************************/
DECLARE @StartDate1 DATETIME
	,@EndDate1 DATETIME
	,@StartDate2 DATETIME
	,@EndDate2 DATETIME
	,@UsedDate1 DATETIME
	,@UsedDate2 DATETIME
--get the official date of the inventory  
DECLARE @InvDate1 DATETIME
	,@InvDate2 DATETIME

SET @InvDate1 = (
		SELECT Min(StartDate)
		FROM HPB_INV..Scheduled_Inventory_Reporting i
		WHERE Inventory_Description = @Inventory_Description1
		)
SET @InvDate2 = (
		SELECT min(StartDate)
		FROM HPB_INV..Scheduled_Inventory_Reporting i
		WHERE Inventory_Description = @Inventory_Description2
		)

--make sure the inventory date is the first day of the month.
SELECT @InvDate1 = dateadd(mm, 1, CAST(DATEPART(MM, @InvDate1) AS CHAR(2)) + '/01/' + CAST(DATEPART(YYYY, @InvDate1) AS CHAR(4)))

SELECT @InvDate2 = dateadd(mm, 1, CAST(DATEPART(MM, @InvDate2) AS CHAR(2)) + '/01/' + CAST(DATEPART(YYYY, @InvDate2) AS CHAR(4)))

---compute start and end dates for shipments/BUYS
--Orginial
--SELECT @StartDate1 = DATEADD(MONTH, - 12, @InvDate1)
--SELECT @StartDate2 = DATEADD(MONTH, - 12, @InvDate2)

--Match Avg Book Cost timing and the timing of the RU_CDC_ShippedCost 
SELECT @StartDate1 = DATEADD(MONTH, - 13, @InvDate1)

SELECT @StartDate2 = DATEADD(MONTH, - 13, @InvDate2)

--Original
--SET @EndDate1 = DATEADD(dd, - 1, @InvDate1)
--SET @EndDate2 = DATEADD(dd, - 1, @InvDate2)
SET @EndDate1 = DATEADD(dd, - 1, DATEADD(yy, 1, @StartDate1))
SET @EndDate2 = DATEADD(dd, - 1, DATEADD(yy, 1, @StartDate2))
SET @UsedDate1 = CAST(DATEPART(MM, @EndDate1) AS CHAR(2)) + '/01/' + CAST(DATEPART(YYYY, @EndDate1) AS CHAR(4))
SET @UsedDate2 = CAST(DATEPART(MM, @EndDate2) AS CHAR(2)) + '/01/' + CAST(DATEPART(YYYY, @EndDate2) AS CHAR(4))

IF @Inventory_Description1 = 'Dec 2015 New Store Inventory'
BEGIN
	SET @StartDate1 = '1/1/2014'
	SET @EndDate1 = '12/31/2015'
	SET @UsedDate1 = '12/1/2015'
END;

IF @Inventory_Description2 = 'Dec 2015 New Store Inventory'
BEGIN
	SET @StartDate2 = '1/1/2014'
	SET @EndDate2 = '12/31/2015'
	SET @UsedDate2 = '12/1/2015'
END;

--select @StartDate1 as StartDate1 
--select @EndDate1 as EndDate1 
--select @UsedDate1 as UsedDate1
--select @StartDate2 as StartDate2 
--select @EndDate2 as EndDate2
--select @UsedDate2 as UsedDate2 
/*=========================================================================*/
--summarize 12 months of shipment data for invcode1 to get average New price
SELECT sc.LocationNo
	--,rptProductType
	,b.BindingName
	,SUM(CostShipped) AS YearCostShippedTotal
	,SUM(QtyShipped) AS YearQtyShippedTotal
	,isnull(CASE 
			WHEN SUM(QtyShipped) = 0
				THEN 0
			ELSE SUM(CostShipped) / SUM(QtyShipped)
			END, 0) AS AvgNewCost
INTO #YearShipments1
FROM Reports..RU_CDC_ShippedCost sc WITH (NOLOCK)
left join ReportsData..ShelfScan_Inventory_Mapping_ProductTypeToBinding pb on pb.ProductType=sc.ProductType
left JOIN ReportsData..ShelfScan_Inventory_Bindings b WITH (NOLOCK) ON b.BindingCode = pb.BindingCode
left JOIN ReportsData..RptProductTypes rpt WITH (NOLOCK) ON rpt.ProductType = sc.ProductType
WHERE sc.FirstDayOfMonth BETWEEN @StartDate1
		AND @EndDate1
	AND rpt.rptPTypeClass = 'NEW'
GROUP BY sc.LocationNo
	--,rptProductType
		,b.BindingName
ORDER BY sc.locationno
	,b.BindingName

--SELECT * FROM #YearShipments1
/*=========================================================================*/
--summarize 12 months of shipment data for invcode2 to get average New  price
SELECT sc.LocationNo
	--,rptProductType
	,b.BindingName
	,SUM(CostShipped) AS YearCostShippedTotal
	,SUM(QtyShipped) AS YearQtyShippedTotal
	,isnull(CASE 
			WHEN SUM(QtyShipped) = 0
				THEN 0
			ELSE SUM(CostShipped) / SUM(QtyShipped)
			END, 0) AS AvgNewCost
INTO #YearShipments2
FROM Reports..RU_CDC_ShippedCost sc WITH (NOLOCK)
left join ReportsData..ShelfScan_Inventory_Mapping_ProductTypeToBinding pb on pb.ProductType=sc.ProductType
left JOIN ReportsData..ShelfScan_Inventory_Bindings b WITH (NOLOCK) ON b.BindingCode = pb.BindingCode
left JOIN ReportsData..RptProductTypes rpt WITH (NOLOCK) ON rpt.ProductType = sc.ProductType
WHERE sc.FirstDayOfMonth BETWEEN @StartDate2
		AND @EndDate2
	AND rptPTypeClass = 'NEW'
GROUP BY sc.LocationNo
	--,rptProductType
		,b.BindingName
ORDER BY sc.locationno
	,b.BindingName

--SELECT * FROM #YearShipments2
/*INVENTORY data 1*/
SELECT i.LocationNo
	,i.Inventory_Description AS Inventory_Description1
	,rpt.RptPTypeClass AS rptPTypeClass
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity1
	,CASE 
		WHEN rpt.RptPTypeClass = 'USED'
			THEN ISNULL(SUM(i.Factor * i.Cost), 0)
		ELSE ISNULL(SUM(i.Factor * i.Quantity * AvgNewCost), 0)
		END AS Cost1
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price1
INTO #INV1
FROM ReportsData..RptProductTypes rpt
JOIN HPB_INV..Scheduled_Inventory_Reporting i ON i.ProductType = rpt.ProductType
	AND Inventory_Description = @Inventory_Description1
LEFT JOIN #YearShipments1 s1 ON s1.BindingName=i.BindingName
--s1.rptProductType = rpt.RptProductType
	AND s1.LocationNo = i.LocationNo
GROUP BY i.LocationNo
	,i.Inventory_Description
	,rpt.RptPTypeClass

/*=======================================================================
inventory data 2*/
SELECT i.LocationNo
	,i.Inventory_Description AS Inventory_Description2
	,rpt.RptPTypeClass AS rptPTypeClass
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity2
	,CASE 
		WHEN rpt.RptPTypeClass = 'USED'
			THEN ISNULL(SUM(i.Factor * i.Cost), 0)
		ELSE ISNULL(SUM(i.Factor * i.Quantity * AvgNewCost), 0)
		END AS Cost2
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price2
INTO #INV2
FROM ReportsData..RptProductTypes rpt
JOIN HPB_INV..Scheduled_Inventory_Reporting i ON i.ProductType = rpt.ProductType
	AND Inventory_Description = @Inventory_Description2
LEFT JOIN #YearShipments2 s2 ON s2.BindingName=i.BindingName
--s2.rptProductType = rpt.RptProductType
	AND s2.LocationNo = i.LocationNo
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

DROP TABLE #YearShipments1

DROP TABLE #YearShipments2

GO


