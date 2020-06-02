USE [Reports]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 03/27/2019
-- Description:	Inserts employee metric data into RU_EmployeeMetrics
-- =============================================
CREATE PROCEDURE [dbo].[RU_Populate_EmployeeMetrics]
	-- Add the parameters for the stored procedure here
	@FirstDayOfMonth DATE
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @StartDate DATE 
DECLARE @EndDate DATE 

--Use stored procedure PARAMS_CreateDateRangeSelect to create a table of valid report months

--This will be joined to the table of all employee names and locations 
CREATE TABLE #DateRange (StartOfMonth DATE, EndOfMonth DATE)

INSERT #DateRange (StartOfMonth, EndOfMonth)
EXEC PARAMS_CreateDateRangeSelect 

--Since this PARAMS_CreateDateRangeSelect generates the list of selectable dates for the report, 
--it is used to set @StartDate and @EndDate.
SELECT
	@StartDate = MIN(d.StartOfMonth),
	@EndDate = DATEADD(DAY, 1, MAX(d.EndOfMonth)) --Adding a day is important as TSQL stores dates starting at the very beginning of the day)
FROM #DateRange d


--Get login IDs for all current employees in the company
SELECT
	m.HR_EmployeeID,
	MAX(u.AddDate) [LastAddDate]
INTO #CurrentEmployeeIDs
FROM ReportsData..ASUsers u
INNER JOIN ReportsData..ADAccountMappings m
	ON u.UserID = m.POS_UserID
GROUP BY HR_EmployeeID


--Get names and keys for all current employees in company
SELECT
	'00' + m.HR_Location [LocationNo],
	m.HR_NameLast + ', ' + m.HR_NamePreferred [EmployeeName],
	m.AD_Login [Employee_Login],
	m.POS_UserID [Employee_POSUserID],
	m.POS_UserNo [Employee_POSUserNo]
INTO #AllCurrentEmployees
FROM ReportsData..ASUsers u 
	INNER JOIN ReportsData..ADAccountMappings m
		ON u.UserID = m.POS_UserID
	INNER JOIN #CurrentEmployeeIDs curr
		--Inner join on the most recent record associated with a given employee ID
		--Each employee has a record under their HR_Employee ID for each location they've worked at.
		--ASUsers.AddDate can point us to which one is most current.
		ON m.HR_EmployeeID = curr.HR_EmployeeID
		AND u.AddDate = curr.LastAddDate
		AND u.Status = 'A'
	INNER JOIN ReportsData..Locations slm
		ON ('00' + m.HR_Location) = slm.LocationNo
		AND slm.[Status] = 'A'
		AND slm.RetailStore = 'Y'	
WHERE LEN(m.AD_Login) > 0


--Cross join DateRange table and employee table to create the key table
SELECT 
	d.StartOfMonth [BusinessMonth],
	ace.LocationNo,
	ace.Employee_Login
INTO #KeyTable
FROM #DateRange d
	CROSS JOIN #AllCurrentEmployees ace
ORDER BY Employee_Login, BusinessMonth

DROP TABLE #DateRange

--Roll all register transaction info into temp table (key = AD_Login)
SELECT 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, shh.BusinessDate), 0) [BusinessMonth],
	COUNT(DISTINCT shh.SalesXactionID) [count_SalesTransations],
	COUNT(DISTINCT
			CASE
			WHEN sih.IsReturn = 'Y'
			THEN shh.SalesXactionID
			END) [count_SalesReturns],
	COUNT(DISTINCT
			CASE
			WHEN shh.VoidUserNo = ace.Employee_POSUserNo
			THEN shh.SalesXactionID
			END) [count_SalesVoids]
INTO #RU_Register
FROM rHPB_Historical..SalesHeaderHistory_Recent shh
	LEFT OUTER JOIN rHPB_Historical..SalesItemHistory_Recent sih
		ON shh.SalesXactionID = sih.SalesXactionId
		AND shh.LocationID = sih.LocationID
	INNER JOIN #AllCurrentEmployees ace
		ON shh.UserNo = ace.Employee_POSUserNo
WHERE
			shh.BusinessDate >= @StartDate
		AND shh.BusinessDate < @EndDate
		AND shh.XactionType = 'S'
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, shh.BusinessDate), 0)


--Roll all back office session deviation info into temp table (key = AD_Login)
--Not yet available as of February 2019.

--Roll all buy information into into temp table (key = AD_Login)
--BuyType	BuyTypeID
--BCD 	1
--BTU 	2
--CDU 	3
--CSU 	4
--CX  	5
--DVD 	6
--ELTU	7
--LP  	8
--MG  	9
--MMU 	10
--MSCU	11
--NOST	12
--PB  	13
--SWU 	14
--TXTU	15
--UN  	16
--VDU 	17
--VGU 	18
SELECT 
	bbh.LocationNo,
	bbh.BuyBinNo,
	CAST(COUNT(bbi.SearchResultSourceID) AS FLOAT) [total_ScanCount],
	SUM(CASE
			WHEN bbi.BuyTypeID = 16
			THEN bbi.Quantity
			END) [qty_Book],
	SUM(CASE
			WHEN bbi.BuyTypeID = 16
			THEN bbi.Offer
			END) [amt_Book],
	SUM(CASE
			WHEN bbi.BuyTypeID = 13
			THEN bbi.Quantity
			END) [qty_Paperback],
	SUM(CASE
			WHEN bbi.BuyTypeID = 13
			THEN bbi.Offer
			END) [amt_Paperback],
	SUM(CASE
			WHEN bbi.BuyTypeID = 3
			THEN bbi.Quantity
			END) [qty_CD],
	SUM(CASE
			WHEN bbi.BuyTypeID = 3
			THEN bbi.Offer
			END) [amt_CD],
	SUM(CASE
			WHEN bbi.BuyTypeID = 8
			THEN bbi.Quantity
			END) [qty_LP],
	SUM(CASE
			WHEN bbi.BuyTypeID = 8
			THEN bbi.Offer
			END) [amt_LP],
	SUM(CASE
			WHEN bbi.BuyTypeID = 6
			THEN bbi.Quantity
			END) [qty_DVD],
	SUM(CASE
			WHEN bbi.BuyTypeID = 6
			THEN bbi.Offer
			END) [amt_DVD]
INTO #BuyItems
FROM BUYS..BuyBinItems bbi
	INNER JOIN BUYS..BuyBinHeader bbh
		ON bbi.LocationNo = bbh.LocationNo
		AND bbi.BuyBinNo = bbh.BuyBinNo
WHERE 
		bbh.CreateTime >= @StartDate
	AND bbh.CreateTime < @EndDate
	AND	bbh.StatusCode = 1 --ensure that only accepted buys are captured, may add other status codes
	AND bbi.StatusCode = 1 --ensure that only items which were not deleted or corrected are captured
	AND bbi.Offer < 10000 --eliminates mistaken offer entries for ISBN amounts
	AND bbi.Quantity < 10000 --eliminates mistaken offer entries for ISBN quantities

GROUP BY 
	bbh.LocationNo, 
	bbh.BuyBinNo

SELECT 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, bbh.CreateTime), 0) [BusinessMonth],
	COUNT(bbh.BuyBinNo) [count_BuyTrans],
	SUM(bbh.TotalQuantity) [total_Quantity],
	SUM(bbh.TotalOffer) [total_TotalOffer],
	CAST(SUM(DATEDIFF(SECOND, bbh.CreateTime, bbh.UpdateTime)) AS FLOAT)/60 [total_BuyWait],
	SUM(i.total_ScanCount) [total_BuyScans],
	--Item type averages
	SUM(i.amt_Book) [total_amtHB],
	SUM(i.qty_Book) [total_qtyHB],
	SUM(i.amt_Paperback) [total_amtPB],
	SUM(i.qty_Paperback) [total_qtyPB],
	SUM(i.amt_CD) [total_amtCD],
	SUM(i.qty_CD) [total_qtyCD],
	SUM(i.amt_LP) [total_amtLP],
	SUM(i.qty_LP) [total_qtyLP],
	SUM(i.amt_DVD) [total_amtDVD],
	SUM(i.qty_DVD) [total_qtyDVD]
INTO #RU_Buys
FROM BUYS..BuyBinHeader bbh
	INNER JOIN #BuyItems i
		ON bbh.BuyBinNo = i.BuyBinNo
		AND bbh.LocationNo = i.LocationNo
	INNER JOIN #AllCurrentEmployees ace
		ON bbh.StatusUpdateUser = ace.Employee_Login --Employee must be the end buyer
WHERE 
		bbh.CreateTime >= @StartDate
	AND bbh.CreateTime < @EndDate
	AND	bbh.StatusCode = 1
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, bbh.CreateTime), 0)



--Roll all scanning info into temp table (key = AD_Login)
SELECT 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sis.ScannedOn), 0) [BusinessMonth],
	COUNT(CASE	
			WHEN ScanMode = 1
			THEN sis.ShelfItemScanID
			END)										[count_FullScans],
	COUNT(CASE	
			WHEN ScanMode = 2
			THEN sis.ShelfItemScanID
			END)										[count_SingleScans]
INTO #RU_Scans
FROM  #AllCurrentEmployees ace
	INNER JOIN 
		(SELECT 
			 sis.ShelfItemScanID,
			 sis.ScannedBy,
			 sis.ScanMode,
			 sis.ScannedOn
		 FROM ReportsData..ShelfItemScan sis
		 WHERE 
				sis.ScannedOn >= @StartDate
			AND sis.ScannedOn <= @EndDate
		UNION ALL
		SELECT 
			 sish.ShelfItemScanID,
			 sish.ScannedBy,
			 sish.ScanMode,
			 sish.ScannedOn
		 FROM ReportsView..vw_ShelfItemScanHistory sish
		 WHERE 
				sish.ScannedOn >= @StartDate
			AND sish.ScannedOn < @EndDate) sis
		 ON ace.Employee_Login = sis.ScannedBy
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sis.ScannedOn), 0)



--Roll all pricing info into  temp table (key = AD_Login)
--For now, conversion to binding may be done on the back end, unless it is determined that SubjectKey can directly map to binding, in which case code will be refactored.
SELECT
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, spi.DateInStock), 0) [BusinessMonth],
	COUNT(spi.ItemCode) [count_qtyAll],
	COUNT(
		CASE
		WHEN spi.ProductType = 'UN'
		THEN 1
		END) [count_qtyUN],
	COUNT(
		CASE
		WHEN spi.ProductType = 'PB'
		THEN 1
		END) [count_qtyPB],
	COUNT(
		CASE
		WHEN spi.ProductType = 'NOST'
		THEN 1
		END) [count_qtyNOST],
	COUNT(
		CASE
		WHEN spi.ProductType = 'CDU'
		THEN 1
		END) [count_qtyCD],
	COUNT(
		CASE
		WHEN spi.ProductType = 'LP'
		THEN 1
		END) [count_qtyLP],
	COUNT(
		CASE
		WHEN spi.ProductType = 'DVD'
		THEN 1
		END) [count_qtyDVD],
	COUNT(
		CASE
		WHEN spi.ProductType = 'BDGU' --BoarDGamesUsed (I keep messing this up)
		THEN 1
		END) [count_qtyBDGU],
	COUNT(
		CASE
		WHEN spi.ProductType = 'ELTU'
		THEN 1
		END) [count_qtyELTU],
	SUM(spi.Price) [total_amtAll],
	SUM(
		CASE
		WHEN spi.ProductType = 'UN'
		THEN spi.Price
		END) [total_amtUN],
	SUM(
		CASE
		WHEN spi.ProductType = 'PB'
		THEN spi.Price
		END) [total_amtPB],
	SUM(
		CASE
		WHEN spi.ProductType = 'NOST'
		THEN spi.Price
		END) [total_amtNOST],
	SUM(
		CASE
		WHEN spi.ProductType = 'CDU'
		THEN spi.Price
		END) [total_amtCD],
	SUM(
		CASE
		WHEN spi.ProductType = 'LP'
		THEN spi.Price
		END) [total_amtLP],
	SUM(
		CASE
		WHEN spi.ProductType = 'DVD'
		THEN spi.Price
		END) [total_amtDVD],
	SUM(
		CASE
		WHEN spi.ProductType = 'BDGU'  --BoarDGamesUsed (I keep messing this up)
		THEN spi.Price
		END) [total_amtBDGU],
	SUM(
		CASE
		WHEN spi.ProductType = 'ELTU'
		THEN spi.Price
		END) [total_amtELTU]
INTO #RU_Pricing
FROM ReportsData..SipsProductInventory spi
	INNER JOIN #AllCurrentEmployees ace
		ON spi.CreateUser = ('HPB\' + ace.Employee_Login)
WHERE 
		spi.DateInStock >= @StartDate
	AND spi.DateInStock < @EndDate
	AND spi.Price < 100000 --Eliminates prices entered as ISBNs
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, spi.DateInStock), 0)


--Roll all SAS/XFR info into temp table (key = AD_Login)
SELECT 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, oi.RequestInitiated), 0) [BusinessMonth],
	COUNT(
		CASE 
		WHEN oi.OrderType = 1 --OrderType 1 denotes SAS orders
		THEN 1
		END) [count_SASOrders],
	ISNULL(SUM(
		CASE 
		WHEN oi.OrderType = 1 
		THEN od.Price
		END), 0) [sum_SASSales], --This is intended to be an approximation so that added value of SAS can be evaluated.
	COUNT(
		CASE 
		WHEN oi.OrderType = 2 --OrderType 2 denotes transfer orders.
		THEN 1
		END) [count_XFROrders],
	ISNULL(SUM(
		CASE 
		WHEN oi.OrderType = 2 
		THEN od.Price
		END), 0) [sum_XFRSales] --This is intended to be an approximation so that added value of XFRs can be evaluated.
INTO #RU_Orders
FROM ReportsData..web_OrderInfo_v2 oi
	INNER JOIN #AllCurrentEmployees ace
		ON oi.OriginUserName = ace.Employee_Login
	INNER JOIN OFS..Order_Detail od 
		ON oi.RequestID = od.OrderId
WHERE 
		oi.RequestInitiated >= @StartDate
	AND oi.RequestInitiated < @EndDate
	--AND oi.OrderStatus = 7 --Since 3/10/15 OrderStatus 7 denotes completed orders. This line is commented out since we want to measure orders placed, not necessarily completed.
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, oi.RequestInitiated), 0)

--If a new roll-up is necessary a script will set @FirstDayOfMonth to the month to be re-rolled, 
--that month will be deleted, then it will be inserted in the INSERT statement that follows.
DELETE FROM RU_EmployeeMetrics WHERE BusinessMonth = @FirstDayOfMonth
--Combine all temp tables, joining on key AD_Login
INSERT INTO RU_EmployeeMetrics
SELECT 
	kt.LocationNo,
	kt.Employee_Login,
	kt.BusinessMonth,
	--Register data
	rur.count_SalesTransations	[reg_count_SalesTrans],
	rur.count_SalesReturns		[reg_count_SalesReturns],
	rur.count_SalesVoids		[reg_count_SalesVoids],
	--Buy data (buy level)
	rub.count_BuyTrans			[buys_count_BuyTrans],
	rub.total_Quantity			[buys_count_TotalQty],
	rub.total_TotalOffer		[buys_total_TotalOffer],
	rub.total_BuyScans			[buys_total_BuyScans],
	rub.total_BuyWait			[buys_total_BuyWait],
	--Buy data (item level)
	rub.total_qtyHB				[buys_total_qtyHB],
	rub.total_amtHB				[buys_total_amtHB],
	rub.total_qtyPB				[buys_total_qtyPB],
	rub.total_amtPB				[buys_total_amtPB],
	rub.total_qtyDVD			[buys_total_qtyDVD],
	rub.total_amtDVD			[buys_total_amtDVD],
	rub.total_qtyCD				[buys_total_qtyCD],
	rub.total_amtCD				[buys_total_amtCD],
	rub.total_qtyLP				[buys_total_qtyLP],
	rub.total_amtLP				[buys_total_amtLP],
	--Scan data
	rus.count_SingleScans		[scans_count_SingleScans],
	rus.count_FullScans			[scans_count_FullScans],
	--Pricing data
	--All SIPS
	rup.count_qtyAll			[SIPS_count_qtyAll],
	rup.total_amtAll			[SIPS_total_amtAll],
	--UN SIPS
	rup.count_qtyUN				[SIPS_count_qtyUN],
	rup.total_amtUN				[SIPS_total_amtUN],
	--PB SIPS
	rup.count_qtyPB				[SIPS_count_qtyPB],
	rup.total_amtPB				[SIPS_total_amtPB],
	--NOST SIPS
	rup.count_qtyNOST			[SIPS_count_qtyNOST],
	rup.total_amtNOST			[SIPS_total_amtNOST],
	--DVD SIPS
	rup.count_qtyDVD			[SIPS_count_qtyDVD],
	rup.total_amtDVD			[SIPS_total_amtDVD],
	--CD SIPS
	rup.count_qtyCD				[SIPS_count_qtyCD],
	rup.total_amtCD				[SIPS_total_amtCD],
	--LP SIPS
	rup.count_qtyLP				[SIPS_count_qtyLP],
	rup.total_amtLP				[SIPS_total_amtLP],
	--BDGU SIPS
	rup.count_qtyBDGU			[SIPS_count_qtyBDGU],
	rup.total_amtBDGU			[SIPS_total_amtBDGU],
	--ELTU SIPS
	rup.count_qtyELTU			[SIPS_count_qtyELTU],
	rup.total_amtELTU			[SIPS_total_amtELTU],
	--OrdersData
	ruo.count_SASOrders			[orders_count_SAS],
	ruo.count_XFROrders			[orders_count_XFR],
	ruo.sum_SASSales			[orders_amt_SAS],
	ruo.sum_XFRSales			[orders_amt_XFR]
FROM #KeyTable kt
	LEFT OUTER JOIN #RU_Register rur
		ON kt.LocationNo = rur.LocationNo
		AND kt.BusinessMonth = rur.BusinessMonth
		AND kt.Employee_Login = rur.Employee_Login
	LEFT OUTER JOIN #RU_Buys rub
		ON kt.LocationNo = rub.LocationNo
		AND kt.Employee_Login = rub.Employee_Login
		AND kt.BusinessMonth = rub.BusinessMonth
	LEFT OUTER JOIN #RU_Scans rus
		ON kt.LocationNo = rus.LocationNo
		AND kt.Employee_Login = rus.Employee_Login
		AND kt.BusinessMonth = rus.BusinessMonth
	LEFT OUTER JOIN #RU_Pricing rup
		ON kt.LocationNo = rup.LocationNo
		AND kt.Employee_Login = rup.Employee_Login
		AND kt.BusinessMonth = rup.BusinessMonth		
	LEFT OUTER JOIN #RU_Orders ruo
		ON kt.LocationNo = ruo.LocationNo
		AND kt.Employee_Login = ruo.Employee_Login
		AND kt.BusinessMonth = ruo.BusinessMonth
ORDER BY 
	kt.LocationNo,
	kt.Employee_Login,
	kt.BusinessMonth


DROP TABLE #RU_Orders
DROP TABLE #RU_Pricing
DROP TABLE #RU_Scans
DROP TABLE #RU_Buys
DROP TABLE #BuyItems
DROP TABLE #RU_Register
DROP TABLE #AllCurrentEmployees
DROP TABLE #KeyTable

END
GO
