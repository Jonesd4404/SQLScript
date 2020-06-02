DECLARE @StartDate DATE = '1/1/2019'
DECLARE @EndDate DATE = '5/31/2019'
DECLARE @LocationNo CHAR(5) = '00005'
DECLARE @ReportBy VARCHAR(10) = 'Section'

IF @ReportBy = 'Section'
BEGIN
SELECT 
	loc.LocationNo,
	sub.Subject,
	COUNT(DISTINCT s.ShelfID) [ActiveShelves],
	COUNT(DISTINCT
		CASE
		WHEN ss.ScannedOn >= @StartDate
		AND ss.ScannedOn < DATEADD(DAY, 1, @EndDate)
		AND sis.ScanMode = 1
		THEN s.ShelfID
		END) [FullScannedShelves],
	CAST(COUNT(DISTINCT
		CASE
		WHEN sis.ScannedOn >= @StartDate
		AND sis.ScannedOn < DATEADD(DAY, 1, @EndDate)
		AND sis.ScanMode = 1
		THEN s.ShelfID
		END) AS FLOAT)/
		CAST(COUNT(DISTINCT s.ShelfID) AS FLOAT) [pct_FullScanned],
	COUNT(sis.ShelfItemScanID) [count_CurrentItems],
	MAX(CASE WHEN sis.ScanMode = 2
		THEN sis.ScannedOn END) [LastSingleScan],
	MAX(ss.ScannedOn) [LastFullScan]
FROM ReportsData..Shelf s
	INNER JOIN ReportsData..ShelfScan ss
		ON s.ShelfID = ss.ShelfID
		AND s.StatusCode = 1
	INNER JOIN ReportsData..SubjectSummary sub
		ON s.SubjectKey = sub.SubjectKey
	INNER JOIN ReportsData..ShelfItemScan sis
		ON ss.ShelfScanID = sis.ShelfScanID
	INNER JOIN Reports..[Location] loc
		ON s.LocationID = loc.LocationID
WHERE loc.LocationNo = @LocationNo
GROUP BY loc.LocationNo, sub.Subject
ORDER BY Subject;
END

IF @ReportBy = 'Shelf'
BEGIN
SELECT 
	loc.LocationNo,
	sub.Subject,
	s.ShelfProxyID,
	MAX(CASE WHEN sis.ScanMode = 2
			THEN sis.ScannedOn END) [last_SingleScan],
	ss.ScannedOn [last_FullScan],
	COUNT(sis.ShelfItemScanID) [count_ItemsScanned]
FROM ReportsData..Shelf s
	INNER JOIN ReportsData..ShelfScan ss
		ON s.ShelfID = ss.ShelfID
		AND s.StatusCode = 1
	INNER JOIN ReportsData..SubjectSummary sub
		ON s.SubjectKey = sub.SubjectKey
	INNER JOIN ReportsData..ShelfItemScan sis
		ON ss.ShelfScanID = sis.ShelfScanID
	INNER JOIN Reports..[Location] loc
		ON s.LocationID = loc.LocationID
WHERE loc.LocationNo = @LocationNo
GROUP BY
	loc.LocationNo,
	sub.Subject,
	s.ShelfID,
	s.ShelfProxyID,
	ss.ShelfScanID,
	ss.ScanMode,
	ss.ScannedOn 
ORDER BY Subject, ShelfProxyID
END