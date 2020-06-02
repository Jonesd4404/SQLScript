DECLARE @StartDate DATE = '6/1/2018'
DECLARE @EndDate DATE = '6/30/2018'

--Get names and keys for all current employees in company
SELECT
	m.HR_Location [LocationNo],
	m.HR_NameLast + ', ' + m.HR_NamePreferred [EmployeeName],
	m.AD_Login [Employee_Login],
	m.POS_UserID [Employee_POSUserID],
	m.POS_UserNo [Employee_POSUserNo]
INTO #AllCurrentEmployees
FROM ReportsData..ASUsers u
	INNER JOIN ReportsData..ADAccountMappings m
		ON u.UserID = m.POS_UserID
	INNER JOIN
			--Inner join on the most recent record associated with a given employee ID
			--Each employee has a record under their HR_Employee ID for each location they've worked at.
			--ASUsers.AddDate can point us to which one is most current.
			(SELECT
				m.HR_EmployeeID,
				MAX(u.AddDate) [LastAddDate]
			FROM ReportsData..ASUsers u
			INNER JOIN ReportsData..ADAccountMappings m
				ON u.UserID = m.POS_UserID
			GROUP BY HR_EmployeeID) curr
		ON m.HR_EmployeeID = curr.HR_EmployeeID
		AND u.AddDate = curr.LastAddDate
AND u.Status = 'A'
ORDER BY HR_NameLast

--Get quantities and amounts divided by buy type for each buy transaction.
--(Separated for readability and to avoid multiple DISTINCT statements)
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
	AND bbh.StatusCode = '1'
	AND bbi.StatusCode = '1'
	AND bbi.Offer < 10000
	AND bbi.Quantity < 10000

GROUP BY 
	bbh.LocationNo, 
	bbh.BuyBinNo

SELECT 
	ace.LocationNo,
	ace.Employee_Login [end_User],
	DATEADD(MONTH, DATEDIFF(MONTH, 0, bbh.CreateTime), 0) [BusinessMonth],
	--# of buys performed by user
	COUNT(bbh.BuyBinNo) [count_BuyTrans],
	--# of items purchased by user
	SUM(bbh.TotalQuantity) [total_Quantity],
	--avg # of items per buy
	CAST(SUM(bbh.TotalQuantity) AS FLOAT)/
		CAST(COUNT(bbh.BuyBinNo) AS FLOAT) [avg_QuantityPerBuy],
	--avg total offer per buy
	AVG(bbh.TotalOffer) [avg_TotalOffer],
	--avg offer per item
	CAST(AVG(bbh.TotalOffer) AS FLOAT)/
		CAST(AVG(bbh.TotalQuantity) AS FLOAT) [avg_ItemOffer],
	--average wait from customer info entry to completion
	CAST(AVG(DATEDIFF(SECOND, bbh.CreateTime, bbh.UpdateTime)) AS FLOAT)/60 [avg_BuyWait],
	--average wait per item
	(CAST(SUM(DATEDIFF(SECOND, bbh.CreateTime, bbh.UpdateTime)) AS FLOAT)/60)/SUM(bbh.TotalQuantity) [avg_BuyWaitItem],
	--average number of scans per buy
	AVG(i.total_ScanCount) [avg_ScannedPerBuy],
	--Item type averages
	SUM(i.amt_Book)/SUM(i.qty_Book) [avg_OfferHB],
	SUM(i.amt_Paperback)/SUM(i.qty_Paperback) [avg_OfferPB],
	SUM(i.amt_CD)/SUM(i.qty_CD) [avg_OfferCD],
	SUM(i.amt_LP)/SUM(i.qty_LP) [avg_OfferLP],
	SUM(i.amt_DVD)/SUM(i.qty_DVD) [avg_OfferDVD]
FROM BUYS..BuyBinHeader bbh
	INNER JOIN #BuyItems i
		ON bbh.BuyBinNo = i.BuyBinNo
		AND bbh.LocationNo = i.LocationNo
	INNER JOIN #AllCurrentEmployees ace
		ON bbh.StatusUpdateUser = ace.Employee_Login
WHERE 
		bbh.CreateTime >= @StartDate
	AND bbh.CreateTime < @EndDate
	AND	bbh.StatusCode = '1'
GROUP BY 
	ace.LocationNo,
	bbh.StatusUpdateUser,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, bbh.CreateTime), 0)
ORDER BY 
	ace.LocationNo,
	bbh.StatusUpdateUser,
	BusinessMonth

DROP TABLE #BuyItems
DROP TABLE #AllCurrentEmployees
