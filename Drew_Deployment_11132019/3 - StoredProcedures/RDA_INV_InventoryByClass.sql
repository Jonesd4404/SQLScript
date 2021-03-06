USE [Reports]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[RDA_INV_InventoryByClass]
	@InventoryDescription1 VARCHAR(50),
	@InventoryDescription2 VARCHAR(50),
	@LocationType VARCHAR(20),
	@Location VARCHAR(30)
	
AS
/************************************************************************************************************************************************************
Updated: 6/6/2019
Updated By: William Miller
Description: Complete description of requested inventory report in document "Inventory Quantities Report Requirements" authored by Brian Carusella. 

Reason is decribed as follows "Currently there is not a report that compares two inventories, showing inventory quantities for all locations broken down by 
used, new, and frontline. Also none of the reports that compare inventories have the ability to filter out locations that did not participate in both 
inventories being compared."
*************************************************************************************************************************************************************/

--Prior to determining a list of stores which falls into the location grouping, determine the dates of the inventories selected.
--DECLARE @InvDate DATE

--SET @InvDate = (
--	SELECT DISTINCT
--		sir.StartDate
--	FROM HPB_INV..Scheduled_Inventory_Reporting sir
--	WHERE sir.Inventory_Description = @InventoryDescription
--	)



--Create table in which to store locations which fall within dynamic selection criteria.

CREATE TABLE #ReportLocations (
	LocationNo CHAR(5),
	LocationName VARCHAR(30)
	)

--Retrieve locations into table based on selection criteria.
--Reference to stored procedure Reports..PARAMS_DynFilter_Locations is necessary for full context.
IF @LocationType = 'All Locations'
	INSERT INTO #ReportLocations
	SELECT
		LocationNo,
		LocationNo + ' ' + loc.Name [LocationName]
	FROM ReportsData..Locations loc
	WHERE 
		loc.RetailStore = 'Y' AND
		CAST(RIGHT(loc.LocationNo, 4) AS INT) < 200 AND --Locations with LocationNo over 200 are frequently misrepresented in Reports..Locations currently
		loc.Status = 'A'
		--AND (
		--loc.ClosedDate IS NULL OR
		--loc.ClosedDate >= @Inv1Date OR
		--loc.ClosedDate >= @Inv2Date) --This set of criteria will not include any locations that closed before

IF @LocationType = 'Store'
	INSERT INTO #ReportLocations
	SELECT
		LocationNo,
		LocationNo + ' ' + loc.Name [LocationName]
	FROM ReportsData..Locations loc
	WHERE loc.LocationNo = @Location AND
		loc.RetailStore = 'Y' AND
		loc.Status = 'A' 
		--AND (
		--loc.ClosedDate IS NULL OR
		--loc.ClosedDate >= @Inv1Date OR
		--loc.ClosedDate >= @Inv2Date)

IF @LocationType = 'District'
	INSERT INTO #ReportLocations
	SELECT
		LocationNo,
		LocationNo + ' ' + loc.Name [LocationName]
	FROM ReportsData..Locations loc
	WHERE
		RTRIM(loc.DistrictCode) = @Location AND
		loc.RetailStore = 'Y' AND
		loc.Status = 'A' AND
		CAST(RIGHT(loc.LocationNo, 4) AS INT) < 200 
		--AND (
		--loc.ClosedDate IS NULL OR
		--loc.ClosedDate >= @Inv1Date OR
		--loc.ClosedDate >= @Inv2Date)

IF @LocationType = 'Region'
	INSERT INTO #ReportLocations
	SELECT DISTINCT
		loc.LocationNo,
		loc.LocationNo + ' ' + loc.Name [LocationName]
	FROM ReportsData..Locations loc
	INNER JOIN ReportsData..ReportLocations rl
		ON RTRIM(loc.DistrictCode) = rl.District
		AND rl.Region = @Location
	WHERE
		loc.RetailStore = 'Y' AND
		loc.Status = 'A' AND
		CAST(RIGHT(loc.LocationNo, 4) AS INT) < 200 
		--AND (
		--loc.ClosedDate IS NULL OR
		--loc.ClosedDate >= @Inv1Date OR
		--loc.ClosedDate >= @Inv2Date)


SELECT 
	rl.LocationName,
	sir.Inventory_Description,
	'Total' [ProductCategory],
	ISNULL(SUM(sir.Quantity * sir.Factor), 0) [total_Qty],
	ISNULL(SUM(sir.Cost * sir.Factor), 0) [total_Cost],
	ISNULL(SUM(sir.Cost) / NULLIF(SUM(sir.Quantity), 0), 0) [avg_Cost],
	ISNULL(SUM(sir.Price * sir.Factor), 0) [total_Price],
	ISNULL(SUM(sir.Price) / NULLIF(SUM(sir.Quantity), 0), 0) [avg_Price]
INTO #InvByClass
FROM HPB_INV..Scheduled_Inventory_Reporting sir
	INNER JOIN #ReportLocations rl
		ON sir.LocationNo = rl.LocationNo
	INNER JOIN ReportsData..RDA_InventoryProductClass ipc
		ON sir.ProductType = ipc.ProductType
		AND sir.ItemType_Description = ipc.Type_Description
WHERE sir.Inventory_Description IN (@InventoryDescription1, @InventoryDescription2)
GROUP BY rl.LocationName, sir.Inventory_Description
UNION ALL
SELECT 
	rl.LocationName,
	sir.Inventory_Description,
	ipc.Category [ProductCategory],
	ISNULL(SUM(sir.Quantity * sir.Factor), 0) [total_Qty],
	ISNULL(SUM(sir.Cost * sir.Factor), 0) [total_Cost],
	ISNULL(SUM(sir.Cost) / NULLIF(SUM(sir.Quantity), 0), 0) [avg_Cost],
	ISNULL(SUM(sir.Price * sir.Factor), 0) [total_Price],
	ISNULL(SUM(sir.Price) / NULLIF(SUM(sir.Quantity), 0), 0) [avg_Price]
FROM HPB_INV..Scheduled_Inventory_Reporting sir
	INNER JOIN #ReportLocations rl
		ON sir.LocationNo = rl.LocationNo
	INNER JOIN ReportsData..RDA_InventoryProductClass ipc
		ON sir.ProductType = ipc.ProductType
		AND sir.ItemType_Description = ipc.Type_Description
WHERE sir.Inventory_Description IN (@InventoryDescription1, @InventoryDescription2)
GROUP BY rl.LocationName, sir.Inventory_Description, ipc.Category
ORDER BY LocationName, Inventory_Description, ProductCategory

SELECT 
	ibc.LocationName,
	ibc.Inventory_Description,
	ProductCategory,
	total_Qty,
	total_Cost,
	avg_Cost,
	total_Price,
	avg_Price,
	CAST(ibc.total_Qty AS FLOAT) / CAST(qct.total_Qty_All AS FLOAT) [pct_Total_Qty],
	ibc.total_Cost / qct.total_Cost_All [pct_Total_Cost],
	ibc.total_Price / qct.total_Price_All [pct_Total_Price]
FROM #InvByClass ibc
	INNER JOIN (
		SELECT
			LocationName,
			Inventory_Description,
			total_Qty [total_Qty_All],
			total_Cost [total_Cost_All],
			total_Price [total_Price_All]
		FROM #InvByClass
		WHERE ProductCategory = 'Total') qct
		--GROUP BY LocationName, Inventory_Description) qct
			ON ibc.LocationName = qct.LocationName
			AND ibc.Inventory_Description = qct.Inventory_Description --Here for future proofing 
		

DROP TABLE #ReportLocations
DROP TABLE #InvByClass

