USE [Reports]
GO
/****** Object:  StoredProcedure [dbo].[RDA_RU_POPULATE_EndOfMonth]    Script Date: 5/4/2020 1:32:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 9/20/19
-- Description:	Rolls up store metrics into reference table for EOM/STAR report.
-- =============================================
ALTER PROCEDURE [dbo].[RDA_RU_POPULATE_EndOfMonth]
	-- Add the parameters for the stored procedure here
		@FirstDayOfMonth DATE
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @StartDate DATE 
DECLARE @EndDate DATE 
--DECLARE @FirstDayOfMonth DATE = NULL
--Use stored procedure PARAMS_CreateDateRangeSelect to create a table of valid report months


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

SELECT 
	nrf.Store_Date [BusinessMonth]
INTO #Calendar
FROM ReportsData.dbo.RDA_NRF_Daily nrf
	INNER JOIN (
		SELECT 
			DATEADD(MONTH, DATEDIFF(MONTH, 0, nrf.Store_Date), 0) [BusinessMonth],
			MIN(nrf.Store_Date) [first_DayOfMonth]
		FROM ReportsData.dbo.RDA_NRF_Daily nrf
		WHERE nrf.Store_Date >= @StartDate
		AND nrf.Store_Date < @EndDate
		GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, nrf.Store_Date), 0)
		) s
		ON nrf.Store_Date = s.first_DayOfMonth

--Define included locations, set which locations will be used for chain comp
SELECT 
	slm.RegionName,
	slm.DistrictName,
	slm.LocationNo,
	slm.LocationId,
	cal.BusinessMonth,
	CASE
		WHEN slm.StoreType = 'S'
		AND slm.OpenDate < DATEADD(YEAR, -2, @StartDate)
		THEN 1
		ELSE 0
		END [bool_CompLoc]
INTO #KeyTable
FROM ReportsData.dbo.StoreLocationMaster slm
	CROSS JOIN #Calendar cal
WHERE
		slm.StoreType IN ('S', 'O')
	AND slm.ClosedDate IS NULL 


SELECT 
	sds.LocationID,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sds.BusinessDate), 0) [BusinessMonth],
	SUM(sds.NonTaxableSales) + SUM(sds.TaxableSalesNetGCRedeemedAmt) + SUM(sds.PromoRedeemedTotalAmt) + SUM(sds.EmployeeGiftCardRedeemedAmt) [ZPage6TotalSales]
INTO #SalesSummary
FROM ReportsData.dbo.StoreDailySummary sds
WHERE	sds.BusinessDate >= @StartDate
	AND sds.BusinessDate < @EndDate
	AND sds.Status = 'A'
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
FROM HPB_SALES..SHH2020 shh
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

--SELECT 
--	shh.LocationID,
--	shh.EndDate,
--	shh.SalesXactionID,
--	shh.CouponFixedDctAmt
--INTO #SalesHeader
--FROM rHPB_Historical..SalesHeaderHistory_Recent shh
--	INNER JOIN #Locations loc
--		ON shh.LocationID = loc.LocationID
--WHERE	shh.XactionType = 'S'
--	AND shh.Status = 'A'
--	AND shh.EndDate >= @StartDate
--	AND shh.EndDate < @EndDate
--AND NOT (shh.TotalDue = 0 AND shh.NumberItems = 1) --Filter out transactions containing only one zero-dollar item

SELECT 
	sih.LocationID,
	sih.SalesXactionId,
	sih.ExtendedAmt, 
	sih.Quantity
INTO #SalesItemHeader
FROM HPB_SALES..SIH2020 sih
UNION 
SELECT 
	sih.LocationID,
	sih.SalesXactionId,
	sih.ExtendedAmt, 
	sih.Quantity
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
	kt.BusinessMonth,
	kt.RegionName,
	kt.DistrictName,
	kt.LocationNo,
	ssa.count_SalesTrans,
	ssa.count_ItemsSold,
	ssu.ZPage6TotalSales [total_NetSales]
INTO #StoreSales
FROM #KeyTable kt
	INNER JOIN #RegisterSales ssa
		ON kt.LocationId = ssa.LocationID
		AND kt.BusinessMonth = ssa.BusinessMonth
	INNER JOIN #SalesSummary ssu
		ON ssa.BusinessMonth = ssu.BusinessMonth
		AND ssa.LocationId = ssu.LocationId


--Used buys metrics. All necessary information can be extract from the header, at this time.
SELECT 
	kt.BusinessMonth,
	kt.RegionName,
	kt.DistrictName,
	kt.LocationNo,
	COUNT(bhh.BuyXactionID) [count_BuyTrans], --count of buys
	--CAST(COUNT(bhh.BuyXactionID) AS FLOAT) / 
	--	CAST(DAY(EOMONTH(DATEADD(MONTH, DATEDIFF(MONTH, 0, bhh.EndDate), 0))) AS FLOAT) [avg_BuysPerDay], --number of buys divided by number of days in month
	SUM(bhh.TotalOffer) [total_BuyOffers], --sum total buy offer
	SUM(bhh.TotalQuantity) [total_BuyQty] --sum total buy quantity
INTO #BuyHeader
FROM #KeyTable kt
	INNER JOIN rHPB_Historical.dbo.BuyHeaderHistory bhh
		ON kt.LocationID = bhh.LocationID
		AND kt.BusinessMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, bhh.EndDate), 0)
WHERE 
		bhh.Status = 'A' --accepted buys only 
GROUP BY kt.BusinessMonth, kt.RegionName, kt.DistrictName, kt.LocationNo


--iStore sales
SELECT 
	kt.BusinessMonth,
	kt.RegionName,
	kt.DistrictName,
	kt.LocationNo,
	COUNT(om.ISIS_OrderID) [count_iStoreOrders], --count of iStore orders
	SUM(om.Price) [total_iStoreSales], --sum of iStore sales
	SUM(om.RefundAmount) [total_iStoreRefunds],
	SUM(om.ShippingFee) [total_iStoreShipping],
	SUM(om.ShippedQuantity) [total_iStoreQty] --sum of iStore quantity sold (multiple items per order occurs)
INTO #iStoreSales
FROM OnlineSalesReporting.dbo.Order_Monsoon om
	INNER JOIN OnlineSalesReporting.dbo.App_Facilities fac
		ON om.FacilityID = fac.FacilityID
	INNER JOIN ReportsData.dbo.OFS_Order_Header oh
		ON om.ISIS_OrderID = oh.ISISOrderID
		AND oh.OrderSystem = 'MON' --Excludes SAS and XFR, which are included in register sales
	INNER JOIN ReportsData.dbo.OFS_Order_Detail od --Purpose of order detail is only to get fulfilling location 
		ON oh.OrderID = od.OrderID
		 --Problem orders have ProblemStatusID not null
		AND od.[Status] IN (1, 4) --Status codes of shipped orders
		AND (od.ProblemStatusID IS NULL
		OR od.ProblemStatusID = 0)
	INNER JOIN #KeyTable kt
		ON ISNULL(od.LocationNo, fac.HPBLocationNo) = kt.LocationNo --This logic takes the store which was originally assigned a problem order when the fulfilling location can not be determined
		AND DATEADD(MONTH, DATEDIFF(MONTH, 0, om.ShipDate), 0) = kt.BusinessMonth
WHERE 
		om.ShipDate >= @StartDate
	AND om.ShipDate < @EndDate
	AND ISNULL(od.LocationNo, fac.HPBLocationNo) IS NOT NULL
	AND om.ShippedQuantity > 0
GROUP BY 
	kt.BusinessMonth,
	kt.RegionName,
	kt.DistrictName,
	kt.LocationNo

--HPB.com sales

SELECT 
	kt.BusinessMonth,
	kt.RegionName,
	kt.DistrictName,
	kt.LocationNo,
	COUNT(od.OrderID) [count_HPBComOrders],
	SUM(od.Price) [total_HPBComSales],
	SUM(oo.ItemRefundAmount) [total_HPBComRefunds],
	SUM(od.ShippingFee) [total_HPBComShipping],
	SUM(od.Qty) [total_HPBComQty]
INTO #HPBComSales 
FROM ReportsData.dbo.OFS_Order_Header oh
	INNER JOIN ReportsData.dbo.OFS_Order_Detail od
		ON oh.OrderID = od.OrderID
	INNER JOIN #KeyTable kt
		ON od.LocationNo = kt.LocationNo
		AND DATEADD(MONTH, DATEDIFF(MONTH, 0, oh.ShipDate), 0) = kt.BusinessMonth
	LEFT OUTER JOIN OnlineSalesReporting.dbo.Order_OMNI oo
		ON CAST(od.MarketOrderItemID AS VARCHAR) = CAST(oo.MarketOrderItemID AS VARCHAR)
 WHERE oh.OrderSystem = 'HMP'
  	AND od.[Status] IN (1, 4) --Status codes of shipped orders
	AND oh.ShipDate >= @StartDate
	AND oh.ShipDate < @EndDate
	AND (od.ProblemStatusID IS NULL
	OR od.ProblemStatusID = 0)
GROUP BY 	
	kt.BusinessMonth,
	kt.RegionName,
	kt.DistrictName,
	kt.LocationNo

--BookSmarter sales
--Union of both current and archive tables is necessary prior to aggregations because dates overlap between the two tables

SELECT
	od.OrderItemID,
	od.ShipDate [ShipDate],
	CAST(('00' + od.LocationNo) AS CHAR(5)) [LocationNo],

	od.OrderNumber,
	od.Price,
	od.ShippingFee,
	od.ShippedQuantity
INTO #BookSmarterAllSales
FROM Monsoon..OrderDetails od
WHERE 
		od.[ServerID] IN (4, 5) --Dallas and Ohio BookSmarter servers
	AND od.ShipDate >= @StartDate
	AND od.ShipDate < @EndDate
UNION
SELECT
	od.OrderItemID,
	od.ShipDate [ShipDate],
	CAST(('00' + od.LocationNo) AS CHAR(5)) [LocationNo],
	od.OrderNumber,
	od.Price,
	od.ShippingFee,
	od.ShippedQuantity
FROM Monsoon..OrderDetailsArchive od
WHERE 
		od.[ServerID] IN (4, 5) --Dallas and Ohio BookSmarter servers
	AND od.ShipDate >= @StartDate
	AND od.ShipDate < @EndDate

SELECT 
      DATEADD(MONTH, DATEDIFF(MONTH, 0, r.refundDate), 0) [BusinessMonth],
      CAST(('00' + od.LocationNo) AS CHAR(5)) [LocationNo],
      SUM(od.RefundAmount) [RefundAmount]
INTO #BookSmarterRefunds
FROM Monsoon..Refunds r
       INNER JOIN Monsoon..OrderDetails od
              ON r.MarketOrderItemID = od.MarketOrderItemID
WHERE 
       r.RefundDate >= @StartDate
       AND r.RefundDate < @EndDate
       AND od.ServerID IN (4, 5)
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, r.refundDate), 0), CAST(('00' + od.LocationNo) AS CHAR(5))


SELECT 
	kt.BusinessMonth,
	kt.RegionName,
	kt.DistrictName,
	kt.LocationNo,
	COUNT(DISTINCT bas.OrderNumber) [count_BSOrders],  --Count of all BookSmarter Orders
	SUM(bas.Price) [total_BSSales], --Sum of all BookSmarter sales 
	bsr.RefundAmount [total_BSRefunds], --Sum of all BookSmarter refunds
	SUM(bas.ShippingFee) [total_BSShipping],
	SUM(bas.ShippedQuantity) [total_BSQty] --Sum of BookSmarter quantitity sold (multiple items per order occurs).
INTO #BookSmarterSales
FROM #KeyTable kt 
	INNER JOIN #BookSmarterAllSales bas
		ON kt.BusinessMonth = DATEADD(MONTH, DATEDIFF(MONTH, 0, bas.ShipDate), 0) 
		AND kt.LocationNo = bas.LocationNo
	LEFT OUTER JOIN #BookSmarterRefunds bsr
             ON bas.LocationNo = bsr.LocationNo
			 AND DATEADD(MONTH, DATEDIFF(MONTH, 0, bas.ShipDate), 0) = bsr.businessmonth
GROUP BY 	
	kt.BusinessMonth,
	kt.RegionName,
	kt.DistrictName,
	kt.LocationNo, 
	bsr.RefundAmount
ORDER BY BusinessMonth, LocationNo


--Creates index from the coallation of all tables above for deletion/insertion from existing table
--SELECT
--	COALESCE(ss.BusinessMonth, bh.BusinessMonth, iss.BusinessMonth, bss.BusinessMonth) [BusinessMonth],
--	COALESCE(ss.RegionName, bh.RegionName, iss.RegionName, hcs.RegionName, bss.RegionName) [RegionName],
--	COALESCE(ss.DistrictName, bh.DistrictName, iss.DistrictName, hcs.DistrictName, bss.DistrictName) [DistrictName],
--	COALESCE(ss.LocationNo, bh.LocationNo, iss.LocationNo, hcs.LocationNo, bss.LocationNo) [LocationNo]
--INTO #RUIndex
--FROM #StoreSales ss
--	--Full outer joins are used in case a particular location does not participate in an certain aspect of operations.
--	FULL OUTER JOIN #BuyHeader bh
--		ON ss.BusinessMonth = bh.BusinessMonth
--		AND ss.LocationNo = bh.LocationNo
--	FULL OUTER JOIN #iStoreSales iss
--		ON ss.BusinessMonth = iss.BusinessMonth
--		AND ss.LocationNo = iss.LocationNo
--	FULL OUTER JOIN #HPBComSales hcs
--		ON ss.BusinessMonth = hcs.BusinessMonth
--		AND ss.LocationNo = hcs.LocationNo
--	FULL OUTER JOIN #BookSmarterSales bss
--		ON ss.BusinessMonth = bss.BusinessMonth
--		AND ss.LocationNo = bss.LocationNo

--Inserts or overwrites data in existing table using coallation of all tables above.
DELETE ReportsData.dbo.RDA_EndOfMonth
FROM ReportsData.dbo.RDA_EndOfMonth eom
	INNER JOIN #KeyTable kt
		ON eom.BusinessMonth = kt.BusinessMonth
		AND eom.LocationNo = kt.LocationNo

INSERT INTO ReportsData.dbo.RDA_EndOfMonth
SELECT	
	--Take the first non-null BusinessMonth and LocationNo in all of the prior tables, in case stores have or have had limited operations
	kt.BusinessMonth [BusinessMonth],
	kt.RegionName [RegionName],
	kt.DistrictName [DistrictName],
	kt.LocationNo [LocationNo],
	ss.total_NetSales,
	ss.count_SalesTrans,
	ss.count_ItemsSold,
	bh.total_BuyOffers,
	bh.count_BuyTrans,
	bh.total_BuyQty,
	--ISNULLs will prevent the entire total from showing up as NULL if either iStore or HPB.com has no sales for a location
	ISNULL(iss.total_iStoreSales, 0) + ISNULL(iss.total_iStoreShipping, 0) - ISNULL(iss.total_iStoreRefunds, 0) +
		ISNULL(hcs.total_HPBComSales, 0) + ISNULL(hcs.total_HPBComShipping, 0) - ISNULL(hcs.total_HPBComRefunds, 0) [total_iStoreSales],
	ISNULL(iss.count_iStoreOrders, 0) + ISNULL(hcs.count_HPBComOrders, 0) [count_iStoreOrders],
	ISNULL(iss.total_iStoreQty, 0) + ISNULL(hcs.total_HPBComQty, 0) [total_iStoreQty],
	ISNULL(bss.total_BSSales, 0) + ISNULL(bss.total_BSShipping, 0) - ISNULL(bss.total_BSRefunds, 0) [total_BookSmarterSales],
	bss.count_BSOrders [count_BookSmarterOrders],
	bss.total_BSQty [total_BookSmarterQty]
FROM #KeyTable kt
	LEFT OUTER JOIN #StoreSales ss
		ON kt.BusinessMonth = ss.BusinessMonth
		AND kt.LocationNo = ss.LocationNo
	--Full outer joins are used in case a particular location does not participate in an certain aspect of operations.
	LEFT OUTER JOIN #BuyHeader bh
		ON kt.BusinessMonth = bh.BusinessMonth
		AND kt.LocationNo = bh.LocationNo
	LEFT OUTER JOIN #iStoreSales iss
		ON kt.BusinessMonth = iss.BusinessMonth
		AND kt.LocationNo = iss.LocationNo
	LEFT OUTER JOIN #HPBComSales hcs
		ON kt.BusinessMonth = hcs.BusinessMonth
		AND kt.LocationNo = hcs.LocationNo
	LEFT OUTER JOIN #BookSmarterSales bss
		ON kt.BusinessMonth = bss.BusinessMonth
		AND kt.LocationNo = bss.LocationNo
ORDER BY LocationNo, BusinessMonth





DROP TABLE #SalesHeader
DROP TABLE #SalesItemHeader
DROP TABLE #BuyHeader
DROP TABLE #StoreSales
DROP TABLE #iStoreSales
DROP TABLE #BookSmarterSales
DROP TABLE #HPBComSales
DROP TABLE #RegisterSales
DROP TABLE #SalesSummary
DROP TABLE #BookSmarterAllSales
DROP TABLE #BookSmarterRefunds
DROP TABLE #Calendar
DROP TABLE #KeyTable

END