USE [Reports]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 9/20/19
-- Description:	Rolls up store metrics into reference table for EOM/STAR report.
-- =============================================
CREATE PROCEDURE [dbo].[RDA_RU_POPULATE_EndOfMonth]
	-- Add the parameters for the stored procedure here
		-- Add the parameters for the stored procedure here
		@FirstDayOfMonth DATE
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @StartDate DATE 
DECLARE @EndDate DATE 


/*************
Set up StartDate and EndDate based on @FirstDateOfMonth
*************/
--If @FirstDayOfMonth is passed, roll up only that month. Otherwise, roll-up all months selectable in PARAMS_CreateDateRangeSelect
IF @FirstDayOfMonth IS NULL
BEGIN
	--Since this PARAMS_CreateDateRangeSelect generates the list of selectable dates for the report, 
	--it is used to set @StartDate and @EndDate.
		SET @StartDate = '1/1/2016'
		SET @EndDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0) 
END

IF @FirstDayOfMonth IS NOT NULL
BEGIN
	SET @StartDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, CAST(@FirstDayOfMonth AS DATE)) - 1, 0) 
	SET	@EndDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, CAST(@FirstDayOfMonth AS DATE)), 0) 
END

/*************
--Define included locations
*************/

SELECT 
	slm.RegionName,
	slm.DistrictName,
	slm.LocationNo,
	slm.LocationId,
	CASE
		WHEN slm.StoreType = 'S'
		AND slm.OpenDate < DATEADD(YEAR, -2, @StartDate)
		THEN 1
		ELSE 0
		END [bool_CompLoc]
INTO #Locations
FROM ReportsData..StoreLocationMaster slm
WHERE
		slm.StoreType IN ('S', 'O')
	AND slm.ClosedDate IS NULL 

/*************
--Gather data from relevant sources.
*************/

SELECT 
	sds.LocationID,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sds.BusinessDate), 0) [BusinessMonth],
	SUM(sds.NonTaxableSales) + SUM(sds.TaxableSalesNetGCRedeemedAmt) + SUM(sds.PromoRedeemedTotalAmt) + SUM(sds.EmployeeGiftCardRedeemedAmt) [ZPage6TotalSales]
INTO #SalesSummary
FROM ReportsData..StoreDailySummary sds
WHERE	sds.BusinessDate >= @StartDate
	AND sds.BusinessDate < @EndDate
GROUP BY 
	sds.LocationId,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sds.BusinessDate), 0)

--Header-level register sales to be incorporated after aggregating item-level data and payment data
--This three-part method is necessary to remove fixed discounts that only occur on header level while still accounting for item-level sales correctly.
SELECT 
	shh.LocationID,
	shh.EndDate,
	shh.SalesXactionID,
	shh.CouponFixedDctAmt
INTO #SalesHeader
FROM HPB_SALES..SHH2019 shh
WHERE	
		shh.XactionType = 'S'
	AND shh.Status = 'A'
	AND shh.EndDate >= @StartDate
	AND shh.EndDate < @EndDate
UNION
SELECT 
	shh.LocationID,
	shh.EndDate,
	shh.SalesXactionID,
	shh.CouponFixedDctAmt
FROM HPB_SALES..SHH2018 shh
WHERE	
		shh.XactionType = 'S'
	AND shh.Status = 'A'
	AND shh.EndDate >= @StartDate
	AND shh.EndDate < @EndDate
UNION
SELECT 
	shh.LocationID,
	shh.EndDate,
	shh.SalesXactionID,
	shh.CouponFixedDctAmt
FROM HPB_SALES..SHH2017 shh
WHERE	
		shh.XactionType = 'S'
	AND shh.Status = 'A'
	AND shh.EndDate >= @StartDate
	AND shh.EndDate < @EndDate
UNION
SELECT 
	shh.LocationID,
	shh.EndDate,
	shh.SalesXactionID,
	shh.CouponFixedDctAmt
FROM HPB_SALES..SHH2016 shh
WHERE	
		shh.XactionType = 'S'
	AND shh.Status = 'A'
	AND shh.EndDate >= @StartDate
	AND shh.EndDate < @EndDate



SELECT 
	sih.LocationID,
	sih.SalesXactionId,
	sih.ExtendedAmt, 
	sih.Quantity
INTO #SalesItemHeader
FROM HPB_SALES..SIH2019 sih
UNION 
SELECT 
	sih.LocationID,
	sih.SalesXactionId,
	sih.ExtendedAmt, 
	sih.Quantity
FROM HPB_SALES..SIH2018 sih
UNION 
SELECT 
	sih.LocationID,
	sih.SalesXactionId,
	sih.ExtendedAmt, 
	sih.Quantity
FROM HPB_SALES..SIH2017 sih
UNION 
SELECT 
	sih.LocationID,
	sih.SalesXactionId,
	sih.ExtendedAmt, 
	sih.Quantity
FROM HPB_SALES..SIH2016 sih


--Item-level register sales (second step in accounting for register sales)
--SELECT 
--	sih.LocationID,
--	sih.SalesXactionId,
--	SUM(CASE
--			WHEN sih.ExtendedAmt > 0 --Filter out returned items and items with sold at $0.00 from quantity 
--			THEN sih.Quantity
--			END)	[total_ItemQuantity] 
--	--SUM(CASE
--	--		WHEN sih.ExtendedAmt > 0 --Filter out returned items and items with sold at $0.00 from sales amount
--	--		THEN sih.ExtendedAmt
--	--		END)	[total_NetSalesBeforeHeaderDiscounts],
--	--SUM(CASE
--	--		WHEN sih.ItemCode IN (Reports.dbo.GetFullLengthItemCode('5768'))
--	--		THEN sih.Quantity
--	--		END)	[total_GCCount], --Count gift card sales for subtraction from quantity.
--	--SUM(CASE
--	--		WHEN sih.ItemCode IN (Reports.dbo.GetFullLengthItemCode('5768'))
--	--		THEN sih.ExtendedAmt
--	--		END)	[total_GCSales] --Sum up gift card sales for subtraction from sales.
--INTO #SalesItem
--FROM #SalesHeader shh
--	INNER JOIN #SalesItemHeader sih
--		ON shh.LocationID = sih.LocationID
--		AND shh.SalesXactionID = sih.SalesXactionId
--GROUP BY sih.LocationID, sih.SalesXactionId


--Combine header-level and item-level register sales (final step in accounting for register sales)
SELECT	
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sh.EndDate), 0) [BusinessMonth],
	sh.LocationID,
	COUNT(DISTINCT sh.SalesXactionID) [count_SalesTrans],
	--SUM(si.total_NetSalesBeforeHeaderDiscounts) - SUM(sh.CouponFixedDctAmt) [total_NetSales], --Sales after discounts, before taxes, not including returns, minus fixed discounts
	SUM(CASE
			WHEN si.ExtendedAmt > 0 --Filter out returned items and items with sold at $0.00 from quantity 
			THEN si.Quantity
			END) [count_ItemsSold]											  --Count of items that were not returned or sold for $0.00
INTO #RegisterSales
FROM #SalesHeader sh
	--Some rows in SalesHeaderHistory do not have items, and therefore do not have rows in SalesItemHistory. 
	--Historically these have not been counted towards sales totals, so an inner join is used to exclude them here.
	INNER JOIN #SalesItemHeader si
		ON sh.LocationID = si.LocationID
		AND sh.SalesXactionID = si.SalesXactionId
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, sh.EndDate), 0), sh.LocationID

SELECT 
	ssa.BusinessMonth,
	loc.RegionName,
	loc.DistrictName,
	loc.LocationNo,
	ssa.count_SalesTrans,
	ssa.count_ItemsSold,
	ssu.ZPage6TotalSales [total_NetSales]
INTO #StoreSales
FROM #RegisterSales ssa
	INNER JOIN #SalesSummary ssu
		ON ssa.BusinessMonth = ssu.BusinessMonth
		AND ssa.LocationId = ssu.LocationId
	INNER JOIN #Locations loc
		ON ssa.LocationID = loc.LocationId

--Used buys metrics. All necessary information can be extract from the header, at this time.
SELECT 
	DATEADD(MONTH, DATEDIFF(MONTH, 0, bhh.EndDate), 0) [BusinessMonth],
	loc.RegionName,
	loc.DistrictName,
	loc.LocationNo,
	COUNT(bhh.BuyXactionID) [count_BuyTrans], --count of buys
	--CAST(COUNT(bhh.BuyXactionID) AS FLOAT) / 
	--	CAST(DAY(EOMONTH(DATEADD(MONTH, DATEDIFF(MONTH, 0, bhh.EndDate), 0))) AS FLOAT) [avg_BuysPerDay], --number of buys divided by number of days in month
	SUM(bhh.TotalOffer) [total_BuyOffers], --sum total buy offer
	SUM(bhh.TotalQuantity) [total_BuyQty] --sum total buy quantity
INTO #BuyHeader
FROM rHPB_Historical..BuyHeaderHistory bhh
	INNER JOIN #Locations loc
		ON bhh.LocationID = loc.LocationID
WHERE 
		bhh.Status = 'A' --accepted buys only 
	AND bhh.EndDate >= @StartDate
	AND bhh.EndDate < @EndDate
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, bhh.EndDate), 0), loc.RegionName, loc.DistrictName, loc.LocationNo


--iStore sales
SELECT 
	DATEADD(MONTH, DATEDIFF(MONTH, 0, om.ShipDate), 0) [BusinessMonth],
	loc.RegionName,
	loc.DistrictName,
	loc.LocationNo,
	COUNT(om.ISIS_OrderID) [count_iStoreOrders], --count of iStore orders
	SUM(om.Price) [total_iStoreSales], --sum of iStore sales
	SUM(om.RefundAmount) [total_iStoreRefunds],
	SUM(om.ShippingFee) [total_iStoreShipping],
	SUM(om.ShippedQuantity) [total_iStoreQty] --sum of iStore quantity sold (multiple items per order occurs)
INTO #iStoreSales
FROM OnlineSalesReporting..Order_Monsoon om
	LEFT OUTER JOIN OnlineSalesReporting..App_Facilities fac
		ON om.FacilityID = fac.FacilityID
	LEFT OUTER JOIN ReportsData..OFS_Order_Header oh
		ON om.ISIS_OrderID = oh.ISISOrderID
		AND oh.OrderSystem = 'MON' --Excludes SAS and XFR, which are included in register sales
	LEFT OUTER JOIN ReportsData..OFS_Order_Detail od --Purpose of order detail is only to get fulfilling location 
		ON oh.OrderID = od.OrderID
		AND od.[Status] IN (1, 4) --Status codes of shipped orders
		AND (od.ProblemStatusID IS NULL
		OR od.ProblemStatusID = 0)
		 --Problem orders have ProblemStatusID not null
	INNER JOIN #Locations loc
		ON ISNULL(od.LocationNo, fac.HPBLocationNo) = loc.LocationNo --This logic takes the store which was originally assigned a problem order when the fulfilling location can not be determined
WHERE 
		om.ShipDate >= @StartDate
	AND om.ShipDate < @EndDate
	AND ISNULL(od.LocationNo, fac.HPBLocationNo) IS NOT NULL
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, om.ShipDate), 0), loc.RegionName, loc.DistrictName, loc.LocationNo

--HPB.com sales
SELECT 
	DATEADD(MONTH, DATEDIFF(MONTH, 0, oh.ShipDate), 0) [BusinessMonth],
	loc.RegionName,
	loc.DistrictName,
	loc.LocationNo,
	COUNT(od.OrderID) [count_HPBComOrders],
	SUM(od.Price) [total_HPBComSales],
	SUM(od.ShippingFee) [total_HPBComShipping],
	SUM(od.Qty) [total_HPBComQty]
INTO #HPBComSales 
FROM ReportsData..OFS_Order_Header oh
	INNER JOIN ReportsData..OFS_Order_Detail od
		ON oh.OrderID = od.OrderID
	INNER JOIN #Locations loc
		ON od.LocationNo = loc.LocationNo
 WHERE oh.OrderSystem = 'HMP'
  	AND od.[Status] IN (1, 4) --Status codes of shipped orders
	AND oh.ShipDate >= @StartDate
	AND oh.ShipDate < @EndDate
	AND (od.ProblemStatusID IS NULL
	OR od.ProblemStatusID = 0)
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, oh.ShipDate), 0), loc.RegionName, loc.DistrictName, loc.LocationNo

--BookSmarter sales
--Union of both current and archive tables is necessary prior to aggregations because dates overlap between the two tables
SELECT
	od.OrderItemID,
	--If the item has been refunded, use the refund date. If it has not been refunded, refund date will be null and ShipDate should be used instead.
	ISNULL(r.RefundDate, od.ShipDate) [ShipDate],
	loc.RegionName,
	loc.DistrictName,
	loc.LocationNo,
	od.OrderNumber,
	od.Price,
	od.ShippingFee,
	od.RefundAmount,
	od.ShippedQuantity
INTO #BookSmarterAllSales
FROM Monsoon..OrderDetails od
	INNER JOIN #Locations loc
		ON CAST(('00' + od.LocationNo) AS CHAR(5)) = loc.LocationNo  --OrderDetails stores locations in CHAR(3) format, necessitating conversion to CHAR(5) for locations table
	LEFT OUTER JOIN Monsoon..Refunds r
		ON od.OrderNumber = r.OrderNumber
WHERE 
		od.[ServerID] IN (4, 5) --Dallas and Ohio BookSmarter servers
	AND ISNULL(r.RefundDate, od.ShipDate) >= @StartDate
	AND ISNULL(r.RefundDate, od.ShipDate) < @EndDate
UNION
SELECT
	od.OrderItemID,
	ISNULL(r.RefundDate, od.ShipDate) [ShipDate],
	loc.RegionName,
	loc.DistrictName,
	loc.LocationNo,
	od.OrderNumber,
	od.Price,
	od.ShippingFee,
	od.RefundAmount,
	od.ShippedQuantity
FROM Monsoon..OrderDetailsArchive od
	INNER JOIN #Locations loc
		ON CAST(('00' + od.LocationNo) AS CHAR(5)) = loc.LocationNo  --OrderDetails stores locations in CHAR(3) format, necessitating conversion to CHAR(5) for locations table
	LEFT OUTER JOIN Monsoon..Refunds r
		ON od.OrderNumber = r.OrderNumber
WHERE 
		od.[ServerID] IN (4, 5) --Dallas and Ohio BookSmarter servers
	AND ISNULL(r.RefundDate, od.ShipDate) >= @StartDate
	AND ISNULL(r.RefundDate, od.ShipDate) < @EndDate

SELECT 
	DATEADD(MONTH, DATEDIFF(MONTH, 0, bas.ShipDate), 0) [BusinessMonth],
	bas.RegionName,
	bas.DistrictName,
	bas.LocationNo,
	COUNT(bas.OrderNumber) [count_BSOrders],  --Count of all BookSmarter Orders
	SUM(bas.Price - ISNULL(bas.RefundAmount, 0)) [total_BSSales], --Sum of all BookSmarter Sales
	SUM(bas.ShippingFee) [total_BSShipping],
	SUM(bas.ShippedQuantity) [total_BSQty] --Sum of BookSmarter quantitity sold (multiple items per order occurs).
INTO #BookSmarterSales
FROM #BookSmarterAllSales bas
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, bas.ShipDate), 0), bas.RegionName, bas.DistrictName, bas.LocationNo
ORDER BY BusinessMonth, LocationNo

DROP TABLE #BookSmarterAllSales


--Creates index from the coallation of all tables above for deletion/insertion from existing table
SELECT
	COALESCE(ss.BusinessMonth, bh.BusinessMonth, iss.BusinessMonth, bss.BusinessMonth) [BusinessMonth],
	COALESCE(ss.RegionName, bh.RegionName, iss.RegionName, hcs.RegionName, bss.RegionName) [RegionName],
	COALESCE(ss.DistrictName, bh.DistrictName, iss.DistrictName, hcs.DistrictName, bss.DistrictName) [DistrictName],
	COALESCE(ss.LocationNo, bh.LocationNo, iss.LocationNo, hcs.LocationNo, bss.LocationNo) [LocationNo]
INTO #RUIndex
FROM #StoreSales ss
	--Full outer joins are used in case a particular location does not participate in an certain aspect of operations.
	FULL OUTER JOIN #BuyHeader bh
		ON ss.BusinessMonth = bh.BusinessMonth
		AND ss.LocationNo = bh.LocationNo
	FULL OUTER JOIN #iStoreSales iss
		ON ss.BusinessMonth = iss.BusinessMonth
		AND ss.LocationNo = iss.LocationNo
	FULL OUTER JOIN #HPBComSales hcs
		ON ss.BusinessMonth = hcs.BusinessMonth
		AND ss.LocationNo = hcs.LocationNo
	FULL OUTER JOIN #BookSmarterSales bss
		ON ss.BusinessMonth = bss.BusinessMonth
		AND ss.LocationNo = bss.LocationNo

--Inserts or overwrites data in existing table using coallation of all tables above.
DELETE ReportsData..RDA_EndOfMonth
FROM ReportsData..RDA_EndOfMonth eom
	INNER JOIN #RUIndex rui
		ON eom.BusinessMonth = rui.BusinessMonth
		AND eom.LocationNo = rui.LocationNo
INSERT INTO ReportsData..RDA_EndOfMonth
SELECT	
	--Take the first non-null BusinessMonth and LocationNo in all of the prior tables, in case stores have or have had limited operations
	COALESCE(ss.BusinessMonth, bh.BusinessMonth, iss.BusinessMonth, bss.BusinessMonth) [BusinessMonth],
	COALESCE(ss.RegionName, bh.RegionName, iss.RegionName, hcs.RegionName, bss.RegionName) [RegionName],
	COALESCE(ss.DistrictName, bh.DistrictName, iss.DistrictName, hcs.DistrictName, bss.DistrictName) [DistrictName],
	COALESCE(ss.LocationNo, bh.LocationNo, iss.LocationNo, hcs.LocationNo, bss.LocationNo) [LocationNo],
	ss.total_NetSales,
	ss.count_SalesTrans,
	ss.count_ItemsSold,
	bh.total_BuyOffers,
	bh.count_BuyTrans,
	bh.total_BuyQty,
	--ISNULLs will prevent the entire total from showing up as NULL if either iStore or HPB.com has no sales for a location
	ISNULL(iss.total_iStoreSales, 0) + ISNULL(iss.total_iStoreShipping, 0) - ISNULL(iss.total_iStoreRefunds, 0) +
		ISNULL(hcs.total_HPBComSales, 0) + ISNULL(hcs.total_HPBComShipping, 0)  [total_iStoreSales],
	ISNULL(iss.count_iStoreOrders, 0) + ISNULL(hcs.count_HPBComOrders, 0) [count_iStoreOrders],
	ISNULL(iss.total_iStoreQty, 0) + ISNULL(hcs.total_HPBComQty, 0) [total_iStoreQty],
	ISNULL(bss.total_BSSales, 0) + ISNULL(bss.total_BSShipping, 0) [total_BookSmarterSales],
	bss.count_BSOrders [count_BookSmarterOrders],
	bss.total_BSQty [total_BookSmarterQty]
FROM #StoreSales ss
	--Full outer joins are used in case a particular location does not participate in an certain aspect of operations.
	FULL OUTER JOIN #BuyHeader bh
		ON ss.BusinessMonth = bh.BusinessMonth
		AND ss.LocationNo = bh.LocationNo
	FULL OUTER JOIN #iStoreSales iss
		ON ss.BusinessMonth = iss.BusinessMonth
		AND ss.LocationNo = iss.LocationNo
	FULL OUTER JOIN #HPBComSales hcs
		ON ss.BusinessMonth = hcs.BusinessMonth
		AND ss.LocationNo = hcs.LocationNo
	FULL OUTER JOIN #BookSmarterSales bss
		ON ss.BusinessMonth = bss.BusinessMonth
		AND ss.LocationNo = bss.LocationNo
ORDER BY LocationNo, BusinessMonth



DROP TABLE #SalesHeader
DROP TABLE #SalesItemHeader
DROP TABLE #BuyHeader
DROP TABLE #StoreSales
DROP TABLE #iStoreSales
DROP TABLE #BookSmarterSales
DROP TABLE #HPBComSales
DROP TABLE #Locations
DROP TABLE #RegisterSales
DROP TABLE #SalesSummary
DROP TABLE #RUIndex

END
