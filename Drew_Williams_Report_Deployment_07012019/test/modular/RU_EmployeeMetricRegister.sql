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
FROM rHPB_Historical..SalesHeaderHistory_Recent shh
	LEFT OUTER JOIN rHPB_Historical..SalesItemHistory_Recent sih
		ON shh.SalesXactionID = sih.SalesXactionId
		AND shh.LocationID = sih.LocationID
	INNER JOIN #AllCurrentEmployees ace
		ON shh.UserNo = ace.Employee_POSUserNo
WHERE
			shh.BusinessDate >= @StartDate
		AND shh.BusinessDate <= @EndDate
		AND shh.XactionType = 'S'
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, shh.BusinessDate), 0)
ORDER BY 
	ace.LocationNo,	
	ace.Employee_Login,
	BusinessMonth

DROP TABLE #AllCurrentEmployees
