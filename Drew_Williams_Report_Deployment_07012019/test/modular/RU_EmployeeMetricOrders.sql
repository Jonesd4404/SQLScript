DECLARE @StartDate DATE = '2/1/2019'
DECLARE @EndDate DATE = '2/28/2019'

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

SELECT 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, oi.RequestInitiated), 0) [BusinessMonth],
	COUNT(
		CASE 
		WHEN oi.OrderType = 1 --OrderType 1 denotes SAS orders
		THEN 1
		END) [count_SASOrders],
	SUM(
		CASE 
		WHEN oi.OrderType = 1 
		THEN od.Price
		END) [sum_SASSales], --This is intended to be an approximation so that added value of SAS can be evaluated.
	COUNT(
		CASE 
		WHEN oi.OrderType = 2 --OrderType 2 denotes transfer orders.
		THEN 1
		END) [count_XFROrders],
	SUM(
		CASE 
		WHEN oi.OrderType = 2 
		THEN od.Price
		END) [sum_XFRSales] --This is intended to be an approximation so that added value of XFRs can be evaluated.
FROM ReportsData..web_OrderInfo_v2 oi
	INNER JOIN #AllCurrentEmployees ace
		ON oi.OriginUserName = ace.Employee_Login
	INNER JOIN OFS..Order_Detail od 
		ON oi.RequestID = od.OrderId
WHERE 
		oi.RequestInitiated >= @StartDate
	AND oi.RequestInitiated <= @EndDate
	--AND oi.OrderStatus = 7 --Since 3/10/15 OrderStatus 7 denotes completed orders. This line is commented out since we want to measure orders placed, not necessarily completed.
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, oi.RequestInitiated), 0)
ORDER BY ace.LocationNo, ace.Employee_Login, BusinessMonth

DROP TABLE #AllCurrentEmployees