USE [Sandbox]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 6/4/2019
-- Description:	Inventory progress report working prototype. 
--				Full report described in requirements document "Shelf Scan Inventory Progress Report 1_0.docx" written by Brian Carusella.
-- =============================================
CREATE PROCEDURE [dbo].[INV_ShelfScanProgress_Shelf_V1]
	-- Add the parameters for the stored procedure here
	@StartDate DATE, 
	@EndDate DATE, 
	@LocationNo CHAR(5),
	@Section VARCHAR(30),
	@ScanStatus VARCHAR(10),
	@InactiveFlag BIT
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
	EXEC Sandbox..PARAMS_GetLocationActiveSections @LocationNo

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
--Set up dynamic SQL statement to deal with other flags

DECLARE @query NVARCHAR(4000), @filter NVARCHAR(200)

IF @ScanStatus = '0' --A value of 0 returns all results "All"
	SET @filter = ''

IF @ScanStatus = '1' --A value of 1 returns current full scanned shelves only "Full"
	SET @filter = 'AND ss.ScannedOn >= @StartDate'

IF @ScanStatus = '2' --A value of 2 returns current full scanned shelves only "Not full"
	SET @filter = 'AND ss.ScannedOn < @StartDate'


SET @query = '
SELECT 
	loc.LocationNo,
	sub.Subject,
	s.ShelfProxyID,
	MAX(CASE WHEN sis.ScanMode = 2
			THEN sis.ScannedOn END) [last_SingleScan],
	ss.ScannedOn [last_FullScan],
	COUNT(CASE WHEN sis.ScannedOn >= @StartDate
			THEN sis.ShelfItemScanID END) [count_ItemsScanned]
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
	INNER JOIN #SelectedSubjects ssub
		ON sub.SubjectKey = ssub.SubjectKey
WHERE 
	loc.LocationNo = @LocationNo' + @filter + '
GROUP BY
	loc.LocationNo,
	sub.Subject,
	s.ShelfID,
	s.ShelfProxyID,
	ss.ShelfScanID,
	ss.ScanMode,
	ss.ScannedOn 
ORDER BY Subject, ShelfProxyID'

EXECUTE sp_executesql @query

END
