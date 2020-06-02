DECLARE @StartDate DATE = '9/1/2019'
DECLARE @EndDate DATE = '10/1/2019'

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

--SAS, XFR, STS by User
SELECT 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, oi.RequestInitiated), 0) [BusinessMonth],
	COUNT(
		CASE 
		WHEN LEFT(ISNULL(oi.marketOrderId, oh.OrderNo), 3) = 'SAS'
		THEN ISNULL(oi.marketOrderId, oh.OrderNo)
		END) [count_SASOrders],
	ISNULL(SUM(
		CASE 
		WHEN LEFT(ISNULL(oi.marketOrderId, oh.OrderNo), 3) = 'SAS'
		THEN ii.Price
		END), 0) [sum_SASSales], --This is intended to be an approximation so that added value of SAS can be evaluated.
	COUNT(
		CASE 
		WHEN LEFT(ISNULL(oi.marketOrderId, oh.OrderNo), 3) = 'STS'
		THEN ISNULL(oi.marketOrderId, oh.OrderNo)
		END) [count_STSOrders],
	ISNULL(SUM(
		CASE 
		WHEN LEFT(ISNULL(oi.marketOrderId, oh.OrderNo), 3) = 'STS'
		THEN ii.Price
		END), 0) [sum_STSSales], --This is intended to be an approximation so that added value of SAS can be evaluated.
	COUNT(
		CASE 
		WHEN LEFT(ISNULL(oi.marketOrderId, oh.OrderNo), 3) = 'XFR' 
		THEN ISNULL(oi.marketOrderId, oh.OrderNo)
		END) [count_XFROrders],
	ISNULL(SUM(
		CASE 
		WHEN LEFT(ISNULL(oi.marketOrderId, oh.OrderNo), 3) = 'XFR'
		THEN ii.Price
		END), 0) [sum_XFRSales] --This is intended to be an approximation so that added value of XFRs can be evaluated.
FROM ReportsData..web_OrderInfo oi
	INNER JOIN ReportsData..web_ItemInfo ii
		ON oi.RequestID = ii.RequestID
	INNER JOIN #AllCurrentEmployees ace
		ON oi.OriginUserName = ace.Employee_Login
	LEFT OUTER JOIN OFS..Order_Header oh
		ON CAST(oi.RequestID AS VARCHAR(30)) = oh.MarketOrderID
WHERE 
		oi.RequestInitiated >= @StartDate
	AND oi.RequestInitiated < @EndDate
	--AND oi.OrderStatus = 7 --Since 3/10/15 OrderStatus 7 denotes completed orders. This line is commented out since we want to measure orders placed, not necessarily completed.
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, oi.RequestInitiated), 0)
ORDER BY LocationNo, Employee_Login