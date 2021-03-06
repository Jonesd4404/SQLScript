USE [Reports]
GO
/****** Object:  StoredProcedure [dbo].[INV_ShelfScanProgress_Section]    Script Date: 9/5/2019 10:20:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 6/4/2019
-- Description:	Inventory progress report: stored procedure to return scanning progress on a per-section level. 
--				Full report described in requirements document "Shelf Scan Inventory Progress Report 1_0.docx" written by Brian Carusella.
-- =============================================
CREATE PROCEDURE [dbo].[RDA_INV_ShelfScanProgress_Section]
	-- Add the parameters for the stored procedure here
	@StartDate DATE, 
	@EndDate DATE, 
	@LocationNo CHAR(5),
	@Section VARCHAR(30),
	@ScanStatus INT
AS
BEGIN

	SET NOCOUNT ON;


--Create table to temporarily store all active subjects at a location
CREATE TABLE #SubjectList (
	Subject VARCHAR(30),
	SubjectKey INT
	)

--Create table to store final select subject at that location
CREATE TABLE #SelectedSubjects (
	Subject VARCHAR(30),
	SubjectKey INT
	)

--Fetch all active subjects into temp table
INSERT INTO #SubjectList
	EXEC RDA_PARAMS_GetLocationActiveSections @LocationNo

--Select subjects into #SelectedSubjects based on user selection
IF @Section <> 'All'
	INSERT INTO #SelectedSubjects
	SELECT 
		[Subject],
		SubjectKey
		FROM #SubjectList
	WHERE [Subject] = @Section
ELSE
	INSERT INTO #SelectedSubjects
	SELECT 
		[Subject],
		SubjectKey
		FROM #SubjectList

DROP TABLE #SubjectList


--If statements governing scan status ("All", "Full", or "Not full")

IF @ScanStatus = 2 --A value of 2 returns current full scanned shelves only "Not full"
SELECT 
	loc.LocationNo,
	sub.Subject,
	MAX(ss.ScannedOn) [last_FullScan],
	MAX(CASE WHEN sis.ScanMode = 2
			THEN sis.ScannedOn END) [last_SingleScan],
	COUNT(DISTINCT s.ShelfID) [count_ActiveShelves],
	CAST(COUNT(CASE WHEN ss.ScannedOn >= @StartDate
			THEN ss.ShelfScanID END) AS FLOAT)/
			NULLIF(CAST(COUNT(ss.ShelfScanID) AS FLOAT), 0) [pct_ShelvesFullScanned],
	COUNT(CASE WHEN sis.ScannedOn >= @StartDate
			THEN sis.ShelfItemScanID END) [count_ItemsScanned]
FROM ReportsData..Shelf s
	LEFT OUTER JOIN ReportsData..ShelfScan ss
		ON s.ShelfID = ss.ShelfID
	INNER JOIN ReportsData..SubjectSummary sub
		ON s.SubjectKey = sub.SubjectKey
	LEFT OUTER JOIN ReportsData..ShelfItemScan sis
		ON ss.ShelfScanID = sis.ShelfScanID
	INNER JOIN Reports..[Location] loc
		ON s.LocationID = loc.LocationID
	INNER JOIN #SelectedSubjects ssub
		ON sub.SubjectKey = ssub.SubjectKey
WHERE 
	loc.LocationNo = @LocationNo 
	AND s.StatusCode = 1
	AND ss.ScannedOn < @StartDate
GROUP BY
	loc.LocationNo,
	sub.Subject
ORDER BY [Subject]


ELSE IF @ScanStatus = 1 --A value of 1 returns current full scanned shelves only "Full"
SELECT 
	loc.LocationNo,
	sub.Subject,
	MAX(ss.ScannedOn) [last_FullScan],
	MAX(CASE WHEN sis.ScanMode = 2
			THEN sis.ScannedOn END) [last_SingleScan],
	COUNT(DISTINCT s.ShelfID) [count_ActiveShelves],
	CAST(COUNT(CASE WHEN ss.ScannedOn >= @StartDate
			THEN ss.ShelfScanID END) AS FLOAT)/
			NULLIF(CAST(COUNT(ss.ShelfScanID) AS FLOAT), 0) [pct_ShelvesFullScanned],
	COUNT(CASE WHEN sis.ScannedOn >= @StartDate
			THEN sis.ShelfItemScanID END) [count_ItemsScanned]
FROM ReportsData..Shelf s
	LEFT OUTER JOIN ReportsData..ShelfScan ss
		ON s.ShelfID = ss.ShelfID
	INNER JOIN ReportsData..SubjectSummary sub
		ON s.SubjectKey = sub.SubjectKey
	LEFT OUTER JOIN ReportsData..ShelfItemScan sis
		ON ss.ShelfScanID = sis.ShelfScanID
	INNER JOIN Reports..[Location] loc
		ON s.LocationID = loc.LocationID
	INNER JOIN #SelectedSubjects ssub
		ON sub.SubjectKey = ssub.SubjectKey
WHERE 
	loc.LocationNo = @LocationNo
	AND s.StatusCode = 1
	AND ss.ScannedOn >= @StartDate 
	AND ss.ScannedOn < DATEADD(DAY, 1, @EndDate)
GROUP BY
	loc.LocationNo,
	sub.Subject
ORDER BY [Subject]

ELSE  --A value of 0 returns all results "All"
SELECT 
	loc.LocationNo,
	sub.Subject,
	MAX(ss.ScannedOn) [last_FullScan],
	MAX(CASE WHEN sis.ScanMode = 2
			THEN sis.ScannedOn END) [last_SingleScan],
	COUNT(DISTINCT s.ShelfID) [count_ActiveShelves],
	CAST(COUNT(CASE WHEN ss.ScannedOn >= @StartDate
			THEN ss.ShelfScanID END) AS FLOAT)/
			NULLIF(CAST(COUNT(ss.ShelfScanID) AS FLOAT), 0) [pct_ShelvesFullScanned],
	COUNT(CASE WHEN sis.ScannedOn >= @StartDate
			THEN sis.ShelfItemScanID END) [count_ItemsScanned]
FROM ReportsData..Shelf s
	LEFT OUTER JOIN ReportsData..ShelfScan ss
		ON s.ShelfID = ss.ShelfID
	INNER JOIN ReportsData..SubjectSummary sub
		ON s.SubjectKey = sub.SubjectKey
	LEFT OUTER JOIN ReportsData..ShelfItemScan sis
		ON ss.ShelfScanID = sis.ShelfScanID
	INNER JOIN Reports..[Location] loc
		ON s.LocationID = loc.LocationID
	INNER JOIN #SelectedSubjects ssub
		ON sub.SubjectKey = ssub.SubjectKey
WHERE 
	loc.LocationNo = @LocationNo AND
	s.StatusCode = 1
GROUP BY
	loc.LocationNo,
	sub.Subject
ORDER BY [Subject]


DROP TABLE #SelectedSubjects

END
