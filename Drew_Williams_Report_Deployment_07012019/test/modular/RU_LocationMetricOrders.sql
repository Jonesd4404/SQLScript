DECLARE @StartDate DATE = '2/1/2018'
DECLARE @EndDate DATE = '2/28/2019'

SELECT 
	slm.LocationNo,
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
FROM ReportsData..web_OrderInfo_v2 oi
	INNER JOIN ReportsView..StoreLocationMaster slm
		ON oi.OriginLocationNo = slm.LocationNo
		AND slm.StoreStatus = 'O'
	INNER JOIN OFS..Order_Detail od 
		ON oi.RequestID = od.OrderId
WHERE 
		oi.RequestInitiated >= @StartDate
	AND oi.RequestInitiated <= @EndDate
	--AND oi.OrderStatus = 7 --Since 3/10/15 OrderStatus 7 denotes completed orders. This line is commented out since we want to measure orders placed, not necessarily completed.
GROUP BY 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, oi.RequestInitiated), 0)
ORDER BY slm.LocationNo, BusinessMonth
