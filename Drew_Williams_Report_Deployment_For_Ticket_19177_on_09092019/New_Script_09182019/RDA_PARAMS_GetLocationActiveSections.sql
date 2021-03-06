USE [Reports]
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
CREATE PROCEDURE [dbo].[RDA_PARAMS_GetLocationActiveSections]
	-- Add the parameters for the stored procedure here
	@LocationNo CHAR(5)
AS
BEGIN

	SET NOCOUNT ON;

CREATE TABLE #LocSections ([Subject] VARCHAR(30), SubjectKey INT)
    
INSERT INTO #LocSections VALUES ('All', NULL)
	-- Insert statements for procedure here

INSERT INTO #LocSections
SELECT DISTINCT
	sub.Subject,
	sub.SubjectKey
FROM ReportsData..Shelf s
	INNER JOIN ReportsData..ShelfScan ss
		ON s.ShelfID = ss.ShelfID
		AND s.StatusCode = 1
	INNER JOIN ReportsData..SubjectSummary sub
		ON s.SubjectKey = sub.SubjectKey
	INNER JOIN Reports..[Location] loc
		ON s.LocationID = loc.LocationID
WHERE 
	loc.LocationNo = @LocationNo


SELECT 
	[Subject],
	SubjectKey
FROM #LocSections
ORDER BY CASE WHEN [Subject] = 'All' THEN NULL ELSE [Subject] END

DROP TABLE #LocSections
END
