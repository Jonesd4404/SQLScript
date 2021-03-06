DECLARE @StartDate DATE = '1/1/2018'
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
		WHEN spi.ProductType = 'CD'
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
		WHEN spi.ProductType = 'BGDU'
		THEN 1
		END) [count_qtyBGDU],
	COUNT(
		CASE
		WHEN spi.ProductType = 'ELTU'
		THEN 1
		END) [count_qtyELTU],
	AVG(spi.Price) [avg_amtAll],
	AVG(
		CASE
		WHEN spi.ProductType = 'UN'
		THEN spi.Price
		END) [avg_amtUN],
	AVG(
		CASE
		WHEN spi.ProductType = 'PB'
		THEN spi.Price
		END) [avg_amtPB],
	AVG(
		CASE
		WHEN spi.ProductType = 'NOST'
		THEN spi.Price
		END) [avg_amtNOST],
	AVG(
		CASE
		WHEN spi.ProductType = 'CD'
		THEN spi.Price
		END) [avg_amtCD],
	AVG(
		CASE
		WHEN spi.ProductType = 'LP'
		THEN spi.Price
		END) [avg_amtLP],
	AVG(
		CASE
		WHEN spi.ProductType = 'DVD'
		THEN spi.Price
		END) [avg_amtDVD],
	AVG(
		CASE
		WHEN spi.ProductType = 'BGDU'
		THEN spi.Price
		END) [avg_amtBGDU],
	AVG(
		CASE
		WHEN spi.ProductType = 'ELTU'
		THEN spi.Price
		END) [avg_amtELTU]
FROM ReportsData..SipsProductInventory spi
	INNER JOIN #AllCurrentEmployees ace
		ON spi.CreateUser = ('HPB\' + ace.Employee_Login)
WHERE spi.DateInStock >= @StartDate
	AND spi.DateInStock <= @EndDate
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, spi.DateInStock), 0)
ORDER BY 
	ace.LocationNo,
	ace.Employee_Login,
	BusinessMonth

DROP TABLE #AllCurrentEmployees