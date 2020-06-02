DECLARE @StartDate DATE = '1/1/2017'
DECLARE @EndDate DATE = '1/31/2019'

--Get full and single scan counts from current scan tables
SELECT 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sis.ScannedOn), 0) [BusinessMonth],
	COUNT(CASE 
			WHEN sis.ScanMode = 1
			THEN 1
			END) [count_FullScans], 
	COUNT(CASE 
			WHEN sis.ScanMode = 2
			THEN 1
			END) [count_SingleScans]
INTO #CurrItemScans
FROM ReportsData..ShelfItemScan sis
	--Join with ShelfScan table is necessary to get LocationID.
	INNER JOIN ReportsData..ShelfScan ss
		ON sis.ShelfScanID = ss.ShelfScanID
	--Join with StoreLocationMaster to get location number and location selection criteria control.
	INNER JOIN ReportsView..StoreLocationMaster slm
		ON ss.LocationID = slm.LocationId
		AND slm.StoreStatus = 'O'
GROUP BY 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sis.ScannedOn), 0)

--Get full and single scan counts from historical scan tables
SELECT 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sish.ScannedOn), 0) [BusinessMonth],
	COUNT(CASE 
			WHEN sish.ScanMode = 1
			THEN 1
			END) [count_FullScans], 
	COUNT(CASE 
			WHEN sish.ScanMode = 2
			THEN 1
			END) [count_SingleScans]
INTO #HistItemScans
FROM ReportsData..ShelfItemScanHistory sish
	INNER JOIN ReportsData..ShelfScanHistory ssh
		ON sish.ShelfScanID = ssh.ShelfScanID
	INNER JOIN ReportsView..StoreLocationMaster slm
		ON ssh.LocationID = slm.LocationId
		AND slm.StoreStatus = 'O'
GROUP BY 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sish.ScannedOn), 0)

--Get full and single scan counts from archival scan tables
SELECT 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sish.ScannedOn), 0) [BusinessMonth],
	COUNT(CASE 
			WHEN sish.ScanMode = 1
			THEN 1
			END) [count_FullScans], 
	COUNT(CASE 
			WHEN sish.ScanMode = 2
			THEN 1
			END) [count_SingleScans]
INTO #Arch17ItemScans
FROM archShelfScan..ShelfItemScanHistory_2017 sish
	INNER JOIN ReportsData..ShelfScanHistory ssh
		ON sish.ShelfScanID = ssh.ShelfScanID
	INNER JOIN ReportsView..StoreLocationMaster slm
		ON ssh.LocationID = slm.LocationId
		AND slm.StoreStatus = 'O'
GROUP BY 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sish.ScannedOn), 0)

--Add the current scan tables and historical, as there is some overlap between the two - especially for recent months.
SELECT 
	his.LocationNo,
	his.BusinessMonth,
	--For many months, the count of current scans not moved to historical will be zero, resulting in NULL on left join of "his" table to "cis" table
	ISNULL(cis.count_FullScans, 0) + his.count_FullScans [count_FullScans],
	ISNULL(cis.count_SingleScans, 0) + his.count_SingleScans [count_SingleScans]
FROM #HistItemScans his
	LEFT JOIN #CurrItemScans cis
		ON cis.LocationNo = his.LocationNo
		AND cis.BusinessMonth = his.BusinessMonth
UNION ALL
--Combine with the archival scans, with which their should be no overlap
SELECT 
	ais17.LocationNo,
	ais17.BusinessMonth,
	ais17.count_FullScans,
	ais17.count_SingleScans
FROM #Arch17ItemScans ais17
ORDER BY LocationNo, BusinessMonth

DROP TABLE #Arch17ItemScans
DROP TABLE #HistItemScans
DROP TABLE #CurrItemScans
