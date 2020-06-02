DECLARE @StartDate DATE = '2/1/2019'
DECLARE @EndDate DATE = '7/1/2019'

SELECT 
	BusinessMonth,
	Employee_Login,
	scans_count_SingleScans,
	scans_count_FullScans
INTO #ReportData
FROM Report_Analytics..RDA_RU_EmployeeMetrics em
WHERE 
	LocationNo = '00081' AND
	BusinessMonth >= @StartDate AND
	BusinessMonth < @EndDate
ORDER BY Employee_Login

SELECT DISTINCT
	'00081' [LocationNo],
	Employee_Login
INTO #AllCurrentEmployees
FROM #ReportData
WHERE Employee_Login <> '00081'

SELECT	
	slm.LocationNo,
	ace.Employee_Login,
	sis.ShelfItemScanID,
	sis.ScannedOn,
	sis.ScanMode
INTO #AllScans
FROM ReportsData..ShelfItemScan sis
	--Join with ShelfScan table is necessary to get LocationID.
	INNER JOIN ReportsData..ShelfScan ss
		ON sis.ShelfScanID = ss.ShelfScanID
	--Join with StoreLocationMaster to get location number and location selection criteria control.
	INNER JOIN ReportsData..Locations slm
		ON ss.LocationID = slm.LocationID
		AND slm.[Status] = 'A'
		AND slm.RetailStore = 'Y'	
	INNER JOIN #AllCurrentEmployees ace
		ON sis.ScannedBy = ace.Employee_Login
WHERE 
		sis.ScannedOn >= @StartDate
	AND sis.ScannedOn < @EndDate
UNION ALL
SELECT 
	slm.LocationNo,
	ace.Employee_Login,
	sish.ShelfItemScanID,
	sish.ScannedOn,
	sish.ScanMode
FROM ReportsData..ShelfItemScanHistory sish
	INNER JOIN ReportsData..ShelfScan ssh
		ON sish.ShelfScanID = ssh.ShelfScanID
	INNER JOIN ReportsData..Locations slm
		ON ssh.LocationID = slm.LocationID
		AND slm.[Status] = 'A'
		AND slm.RetailStore = 'Y'	
	INNER JOIN #AllCurrentEmployees ace
		ON sish.ScannedBy = ace.Employee_Login
WHERE
		sish.ScannedOn >= @StartDate
	AND sish.ScannedOn < @EndDate
UNION ALL
SELECT 
	slm.LocationNo,
	ace.Employee_Login,
	sish.ShelfItemScanID,
	sish.ScannedOn,
	sish.ScanMode
FROM ReportsData..ShelfItemScanHistory sish
	INNER JOIN ReportsData..ShelfScanHistory ssh
		ON sish.ShelfScanID = ssh.ShelfScanID
	INNER JOIN ReportsData..Locations slm
		ON ssh.LocationID = slm.LocationID
		AND slm.[Status] = 'A'
		AND slm.RetailStore = 'Y'	
	INNER JOIN #AllCurrentEmployees ace
		ON sish.ScannedBy = ace.Employee_Login
WHERE
		sish.ScannedOn >= @StartDate
	AND sish.ScannedOn < @EndDate

SELECT 
	sis.LocationNo,
	sis.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sis.ScannedOn), 0) [BusinessMonth],
	COUNT(CASE 
			WHEN sis.ScanMode = 1
			THEN 1
			END) [count_FullScans], 
	COUNT(CASE 
			WHEN sis.ScanMode = 2
			THEN 1
			END) [count_SingleScans]

INTO #RU_Scans
FROM #AllScans sis
GROUP BY 
	sis.LocationNo,
	sis.Employee_Login,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sis.ScannedOn), 0)



SELECT * FROM #RU_Scans
ORDER BY Employee_Login, BusinessMonth

SELECT LocationNo, BusinessMonth, SUM(count_FullScans), SUM(count_SingleScans)
FROM #RU_Scans
GROUP BY LocationNo, BusinessMonth

DROP TABLE #ReportData
DROP TABLE #AllCurrentEmployees
DROP TABLE #AllScans
DROP TABLE #RU_Scans