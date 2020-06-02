USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[rpt_select_SearchAndShipStats_v3]    Script Date: 12/7/2018 11:33:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



Alter procedure [dbo].[rpt_select_SearchAndShipStats_v3]
(
--DECLARE
     @startdate DATETIME --= '11/1/18'
	,@enddate DATETIME --= '11/30/18'
	,@OrderSystem VARCHAR(10) --= 
	--'SAS'
	--'XFR'
	--'SAS,XFR'
)
as
/***************************************************************
SSRS Report - Search And Ship Stats
author: dgreen
date: 09.13.2013
about: Pulls various stats from order view for Search and Ship
	application.
update: 09.23.2013
	Add request month and YTD amounts, remove high / low ytd
	counts.

rthomas - 6/26/2015 
rewrite to use OFS data. 
due to the size of the report moved to monthly snapshots to reduce the quering on the OFS data

Tracy Dennis - 7/7/2016
Rewrite to use copied data off Orange instead of Silverbell. Changed to select order system and for it to pull by date again.

Tracy Dennis - 3/28/2017
Around Febuary 2017 a change was made to OFS to phase out printed status.  So the status of 1 - New and 4 - Printer are used so that history was not lost.

Tracy Dennis 12/7/2018 MarketOrderId was added to ReportsData..web_OrderInfo.  Added a union all to get the Search and Ship / Transfer orders part one Traditional and part two Cart.
   The Cosmos tables will eventually be going away at that time the report will be rewritten.  
***************************************************************/
/**************************************************************
Data Super Set
**************************************************************/
DECLARE @MainData TABLE (
	RequestID INT
	,RequestLocationNo CHAR(5)
	,FulfillLocationNo CHAR(5)
	,Price MONEY
	,RequestInitiated DATETIME
	)

INSERT INTO @MainData
SELECT oi.RequestID
	,h.OrderLocationNo [RequestLocationNo]
	,d.LocationNo
	,d.Price
	,RequestInitiated
FROM ReportsData.dbo.OFS_Order_Header h
JOIN ReportsData.dbo.OFS_Order_Detail d ON h.orderid = d.OrderID
	AND d.STATUS in (1, 4)  --both New and Printed are now completed, 2-2017 Printed is being phased out and both are checked so historical data is not lost.
JOIN ReportsData.dbo.web_orderinfo oi ON cast(oi.RequestID as varchar(100)) = h.MarketOrderID
	AND h.OrderSystem IN (
		SELECT DISTINCT sID
		FROM Reports..FN_CDC_ListStringToTable(@OrderSystem)
		)
WHERE RequestInitiated >= @startdate
	AND RequestInitiated < dateadd(day, 1, @enddate)
	AND h.STATUS = 3
	AND h.orderlocationno IS NOT NULL
	and isnumeric(h.MarketOrderID) = 1 --only Traditional Search and Ship / Transfers orders

union all

SELECT oi.RequestID
	,h.OrderLocationNo [RequestLocationNo]
	,d.LocationNo
	,d.Price
	,RequestInitiated
FROM ReportsData.dbo.OFS_Order_Header h 
JOIN ReportsData.dbo.OFS_Order_Detail d ON h.orderid = d.OrderID
	AND d.STATUS in (1, 4)  --both New and Printed are now completed, 2-2017 Printed is being phased out and both are checked so historical data is not lost.
JOIN ReportsData.dbo.web_orderinfo oi ON oi.marketorderid = h.MarketOrderID
		and oi.marketorderid is not null  --Cart Search and Ship  / Transfers orders
		AND h.OrderSystem IN (
		SELECT DISTINCT sID
		FROM Reports..FN_CDC_ListStringToTable(@OrderSystem)
		)
WHERE RequestInitiated >= @startdate
	AND RequestInitiated < dateadd(day, 1, @enddate)
	AND h.STATUS = 3
	AND h.orderlocationno IS NOT NULL
	and isnumeric(h.MarketOrderID) = 0 --Cart Search and Ship  / Transfers orders

DECLARE @Locations TABLE (LocationNo CHAR(5))

INSERT INTO @Locations
SELECT DISTINCT RequestLocationNo
FROM @MainData

INSERT INTO @Locations
SELECT DISTINCT FulfillLocationNo
FROM @MainData
WHERE FulfillLocationNo NOT IN (
		SELECT LocationNo
		FROM @Locations
		)

/**************************************************************
Request Data - Where store requested an item
**************************************************************/
--Month data
DECLARE @RequestMonth TABLE (
	RequestLocationNo CHAR(5)
	,NumberOfRequests INT
	,RequestAmt MONEY
	)

INSERT INTO @RequestMonth
SELECT RequestLocationNo
	,count(*) [NumberOfRequests]
	,sum(Price) [RequestAmt]
FROM @MainData
WHERE RequestInitiated >= @startdate
	AND RequestInitiated < dateadd(day, 1, @enddate)
GROUP BY RequestLocationNo

--Year data
DECLARE @RequestYear TABLE (
	RequestLocationNo CHAR(5)
	,NumberOfRequests INT
	,RequestAmt MONEY
	)

INSERT INTO @RequestYear
SELECT RequestLocationNo
	,count(*) [NumberOfRequests]
	,sum(Price) [RequestAmt]
FROM @MainData
WHERE RequestInitiated >= @startdate
	AND RequestInitiated < dateadd(day, 1, @enddate)
GROUP BY RequestLocationNo

/**************************************************************
Fulfill Data - where store fulfilled the item for another store
**************************************************************/
--Month data
DECLARE @FulfillMonth TABLE (
	FulfillLocationNo CHAR(5)
	,NumberFulfilled INT
	,TotalAmt MONEY
	,AvgPrice MONEY
	,HighPrice MONEY
	,LowPrice MONEY
	)

INSERT INTO @FulfillMonth
SELECT FulfillLocationNo
	,count(*) [NumberFulfilled]
	,sum(Price) [TotalAmt]
	,avg(Price) [AvgPrice]
	,max(Price) [HighPrice]
	,min(Price) [LowPrice]
FROM @MainData
WHERE RequestInitiated >= @startdate
	AND RequestInitiated < dateadd(day, 1, @enddate)
GROUP BY FulfillLocationNo

--Year data
DECLARE @FulfillYear TABLE (
	FulfillLocationNo CHAR(5)
	,NumberFulfilled INT
	,TotalAmt MONEY
	,AvgPrice MONEY
	,HighPrice MONEY
	,LowPrice MONEY
	)

INSERT INTO @FulfillYear
SELECT FulfillLocationNo
	,count(*) [NumberFulfilled]
	,sum(Price) [TotalAmt]
	,avg(Price) [AvgPrice]
	,max(Price) [HighPrice]
	,min(Price) [LowPrice]
FROM @MainData
WHERE RequestInitiated >= @startdate
	AND RequestInitiated < dateadd(day, 1, @enddate)
GROUP BY FulfillLocationNo

SELECT loc.LocationNo
	,l.DistrictCode
	--Request data
	,isnull(rm.NumberOfRequests, 0) [MonthReqCnt]
	,isnull(ry.NumberOfRequests, 0) [YearReqCnt]
	,isnull(rm.RequestAmt, 0) [MonthReqAmt]
	,isnull(ry.RequestAmt, 0) [YearReqAmt]
	--Fulfill data
	--Month
	,isnull(fm.NumberFulfilled, 0) [MonthFFCnt]
	,isnull(fm.TotalAmt, 0) [MonthFFTotalAmt]
	,isnull(fm.AvgPrice, 0) [MonthFFAvgPrice]
	,isnull(fm.HighPrice, 0) [MonthFFHighPrice]
	,isnull(fm.LowPrice, 0) [MonthFFLowPrice]
	--Year
	,isnull(fy.NumberFulfilled, 0) [YearFFCnt]
	,isnull(fy.TotalAmt, 0) [YearFFTotalAmt]
	,isnull(fy.AvgPrice, 0) [YearFFAvgPrice]
	,isnull(fy.HighPrice, 0) [YearFFHighPrice]
	,isnull(fy.LowPrice, 0) [YearFFLowPrice]
FROM @Locations loc
LEFT JOIN @RequestMonth rm ON rm.RequestLocationNo = loc.LocationNo
LEFT JOIN @RequestYear ry ON ry.RequestLocationNo = loc.LocationNo
LEFT JOIN @FulfillMonth fm ON fm.FulfillLocationNo = loc.LocationNo
LEFT JOIN @FulfillYear fy ON fy.FulfillLocationNo = loc.LocationNo
LEFT JOIN ReportsData..Locations l ON l.LocationNo = loc.LocationNo
ORDER BY l.DistrictCode
	,loc.LocationNo







GO

--EXEC sys.sp_addextendedproperty @name=N'reportreader', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'rpt_select_SearchAndShipStats_v3'
--GO


