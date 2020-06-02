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
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sis.ScannedOn), 0) [BusinessMonth],
	COUNT(CASE	
			WHEN ScanMode = 1
			THEN sis.ShelfItemScanID
			END) [count_FullScans],
	COUNT(CASE	
			WHEN ScanMode = 2
			THEN sis.ShelfItemScanID
			END) [count_SingleScans]
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
			AND sish.ScannedOn <= @EndDate) sis
		 ON ace.Employee_Login = sis.ScannedBy
GROUP BY 
	ace.LocationNo,
	ace.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sis.ScannedOn), 0)
ORDER BY
	ace.LocationNo,
	ace.Employee_Login,
	BusinessMonth

DROP TABLE #AllCurrentEmployees
