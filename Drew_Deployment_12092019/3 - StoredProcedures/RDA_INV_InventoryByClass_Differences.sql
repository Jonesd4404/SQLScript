USE [Reports]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[RDA_INV_InventoryByClass_Difference]
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


CREATE TABLE #Inv1 (
	LocationName VARCHAR(30),
	Inventory_Description VARCHAR(50),
	ProductCategory VARCHAR(10),
	total_Qty INT,
	total_Cost DECIMAL (19, 4),
	avg_Cost DECIMAL (19, 4),
	total_Price DECIMAL (19, 4),
	avg_Price DECIMAL (19, 4),
	pct_Total_Qty DECIMAL (19, 4),
	pct_Total_Cost DECIMAL (19, 4),
	pct_Total_Price DECIMAL (19, 4)
)

CREATE TABLE #Inv2 (
	LocationName VARCHAR(30),
	Inventory_Description VARCHAR(50),
	ProductCategory VARCHAR(10),
	total_Qty INT,
	total_Cost DECIMAL (19, 4),
	avg_Cost DECIMAL (19, 4),
	total_Price DECIMAL (19, 4),
	avg_Price DECIMAL (19, 4),
	pct_Total_Qty DECIMAL (19, 4),
	pct_Total_Cost DECIMAL (19, 4),
	pct_Total_Price DECIMAL (19, 4)
)

INSERT INTO #Inv1
	EXEC RDA_INV_InventoryByClass @InventoryDescription1, 'None', @LocationType, @Location

INSERT INTO #Inv2 
	EXEC RDA_INV_InventoryByClass @InventoryDescription2, 'None', @LocationType, @Location

SELECT
	i1.LocationName,
	--CASE 
	--	WHEN GROUPING(i1.LocationName) = 1 
	--	THEN 'Total' 
	--	ELSE i1.LocationName 
	--	END [LocationName],
	--'Comparison' [Inventory_Description],
	i1.ProductCategory,
	--CASE 
	--	WHEN GROUPING(i1.ProductCategory) = 1 
	--	THEN 'Total' 
	--	ELSE i1.ProductCategory 
	--	END [ProductCategory],
	SUM(i1.total_Qty) - SUM(i2.total_Qty) [diff_Qty],
	SUM(i1.total_Cost) - SUM(i2.total_Cost) [diff_Cost],
	SUM(i1.avg_Cost) - SUM(i2.avg_Cost) [diff_AvgCost],
	SUM(i1.total_Price) - SUM(i2.total_Price) [diff_Price],
	SUM(i1.avg_Price) - SUM(i2.avg_Price) [diff_AvgPrice],
	SUM(i1.total_Cost)/SUM(i1.total_Qty) - SUM(i2.total_Cost)/SUM(i2.total_Qty) [total_DiffAvgCost],
	SUM(i1.total_Price)/SUM(i1.total_Qty) - SUM(i2.total_Price)/SUM(i2.total_Qty) [total_DiffAvgPrice],
	SUM(i1.pct_Total_Qty) - SUM(i2.pct_Total_Qty) [diff_PctQty],
	SUM(i1.pct_Total_Cost) - SUM(i2.pct_Total_Cost) [diff_PctCost],
	SUM(i1.pct_Total_Price) - SUM(i2.pct_Total_Price) [diff_PctPrice]
FROM #Inv1 i1 
INNER JOIN #Inv2 i2
	ON i1.LocationName = i2.LocationName
	AND i1.ProductCategory = i2.ProductCategory
	AND i1.Inventory_Description = @InventoryDescription1
	AND i2.Inventory_Description = @InventoryDescription2
GROUP BY i1.LocationName, i1.ProductCategory 
ORDER BY i1.LocationName

DROP TABLE #Inv1
DROP TABLE #Inv2