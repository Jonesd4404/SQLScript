USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[INV_InventoryQuantities_V9    Script Date: 05/23/2018 15:18:55 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[INV_InventoryQuantities_V9]
	--Declare
	@Inventory_Description1 VARCHAR(50)
	 --= 
	 --='APP TEST INVENTORY'
	--'2016 May New Store Inventory'
	--'June 2015 Scheduled Inventory'
	--'Jan 2015 Scheduled Inventory'
AS
/************************************************************************************************************************************************************
Updated: 5/9/2016
Updated By: Tracy Dennis
Update Reason: 
Updated to use the new Inventory system tables. The Cost for New is done the same way the old system was. Both the cost and price are not acurate since they 
are not used in the report.

Update: 5/23/18 Tracy Dennis Changed to use the same time period for used and new.  Also redid by binding instead of product type. Based off of INV_InventoryQuantities_V9. 
                             Changed the New to use binding to do their averages for cost.

*************************************************************************************************************************************************************/

/*INVENTORY data 1*/
declare @SqFtTotal int

set @SqFtTotal = (select sum(l.Sqft)[SqFtTotal]
from ReportsData.dbo.Locations l 
Where l.LocationNo in ( select distinct LocationNo
from HPB_INV..Scheduled_Inventory_Reporting i 
where Inventory_Description = @Inventory_Description1))

SELECT i.LocationNo
	,i.Inventory_Description AS Inventory_Description1
	,l.DistrictCode as District
	,l.Sqft as SqFeet
	,CASE 
		WHEN (len(rpt.RptPTypeGroup) > 12)
			THEN left(rpt.RptPTypeGroup, 9)
		ELSE rpt.RptPTypeGroup
		END[RptPTypeGroup]
	,rpt.RptPTypeClass 
	,ISNULL(SUM(i.Factor * i.Quantity), 0) AS Quantity1
	,ISNULL(SUM(i.Factor * i.Cost), 0) AS Cost1
	,ISNULL(SUM(i.Factor * i.Price), 0) AS Price1
	,@SqFtTotal[SqFtTotal]
FROM ReportsData..RptProductTypes rpt
JOIN HPB_INV..Scheduled_Inventory_Reporting i ON i.ProductType = rpt.ProductType
	AND Inventory_Description = @Inventory_Description1
JOIN ReportsData.dbo.Locations l ON i.LocationNo = l.LocationNo
GROUP BY i.LocationNo
	,i.Inventory_Description
	,l.DistrictCode
	,l.Sqft
	,CASE 
		WHEN (len(rpt.RptPTypeGroup) > 12)
			THEN left(rpt.RptPTypeGroup, 9)
		ELSE rpt.RptPTypeGroup
		END

	,rpt.RptPTypeClass
ORDER BY i.LocationNo
	,i.Inventory_Description
	,l.DistrictCode
	,CASE 
		WHEN (len(rpt.RptPTypeGroup) > 12)
			THEN left(rpt.RptPTypeGroup, 9)
		ELSE rpt.RptPTypeGroup
		END
	,rpt.RptPTypeClass
	


GO


