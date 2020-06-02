DECLARE @StartDate DATE = '1/1/2017'
DECLARE @EndDate DATE = '1/31/2019'


--Roll all buy information into into temp table (key = AD_Login)
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
	slm.LocationNo,
	'All' [Employee_Login],
	DATEADD(MONTH, DATEDIFF(MONTH, 0, bbh.CreateTime), 0) [BusinessMonth],
	COUNT(bbh.BuyBinNo) [count_BuyTrans],
	SUM(bbh.TotalQuantity) [total_Quantity],
	CAST(SUM(bbh.TotalQuantity) AS FLOAT)/
		CAST(COUNT(bbh.BuyBinNo) AS FLOAT) [avg_QuantityPerBuy],
	AVG(bbh.TotalOffer) [avg_TotalOffer],
	CAST(AVG(bbh.TotalOffer) AS FLOAT)/
		CAST(AVG(bbh.TotalQuantity) AS FLOAT) [avg_ItemOffer],
	CAST(AVG(DATEDIFF(SECOND, bbh.CreateTime, bbh.UpdateTime)) AS FLOAT)/60 [avg_BuyWait],
	(CAST(SUM(DATEDIFF(SECOND, bbh.CreateTime, bbh.UpdateTime)) AS FLOAT)/60)/SUM(bbh.TotalQuantity) [avg_BuyWaitItem],
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
	INNER JOIN ReportsView..StoreLocationMaster slm
		ON bbh.LocationNo = slm.LocationNo
		AND slm.StoreStatus = 'O'
WHERE 
		bbh.CreateTime >= @StartDate
	AND bbh.CreateTime < @EndDate
	AND	bbh.StatusCode = 1
GROUP BY 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, bbh.CreateTime), 0)

DROP TABLE #BuyItems