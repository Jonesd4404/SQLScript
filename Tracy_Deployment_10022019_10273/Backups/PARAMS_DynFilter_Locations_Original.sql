USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[PARAMS_DynFilter_Locations]    Script Date: 10/2/2019 2:12:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE 
[dbo].[PARAMS_DynFilter_Locations]
@FilterType CHAR(20) = ''
AS
--========================================================================================
IF @FilterType = ''
BEGIN
SELECT
	'ALL' AS DynFilter,
	'All Locations' AS DynFilterLabel
END
--========================================================================================
IF @FilterType = 'All Locations'
BEGIN
SELECT
	'ALL' AS DynFilter,
	'All Locations' AS DynFilterLabel,
	1 AS Sort
END
--========================================================================================
IF @FilterType = 'Store'
BEGIN
	SELECT '' AS DynFilter, 
	'None Selected' AS DynFilterLabel,
	1 AS Sort
	UNION ALL
SELECT
	LocationNo AS DynFilter,
	LocationNo + '   ' + Name AS DynFilterLabel,
	2 AS Sort
FROM reportsdata..Locations 
WHERE  --CAST(LocationNo as INT)< 210  
	RetailStore  = 'Y'
	AND Status = 'A'
	ORDER BY Sort, DynFilterLabel
END
--========================================================================================
--District
IF @FilterType = 'District'
BEGIN
	SELECT '' AS DynFilter, 
	'None Selected' AS DynFilterLabel,
	1 AS Sort
	UNION ALL
	SELECT DISTINCT RTRIM(DistrictCode) AS DynFilter, 
		DistrictCode AS DynFilterLabel,
		2 AS Sort
	FROM ReportsData..Locations WHERE DistrictCode <> '' 
		AND DistrictCode <> 'Dallas Area'
	ORDER BY Sort, DynFilterLabel
END
--========================================================================================
--Region
IF @FilterType = 'Region'
BEGIN
	SELECT '' AS DynFilter, 
	'None Selected' AS DynFilterLabel,
	1 AS Sort
	UNION ALL
	SELECT DISTINCT LTRIM(RTRIM(Region)) AS DynFilter, 
		LTRIM(RTRIM(Region)) AS DynFilterLabel ,
		2 AS Sort
	FROM ReportsData..ReportLocations 
	WHERE Region <> '' 
	ORDER BY Sort, DynFilterLabel
END
--========================================================================================
--RDC
IF @FilterType = 'RDC'
BEGIN
	SELECT LocationNo AS DynFilter, 
		LocationNo + '   ' + Name As DynFilterLabel, 
		2 AS Sort
	FROM reportsdata..Locations 
	WHERE LocationType = 'R'
		AND RetailStore = 'N'
		AND LocationNo NOT IN ('00451','00710','00999')
		AND Status = 'A'
	
	/*UNION
	SELECT 'All' LocationNo AS DynFilter, 
		 'All Locations' AS DynFilterLabel, 
		1 AS Sort
	ORDER BY Sort, LocationNo*/
END
--========================================================================================
--State
IF @FilterType = 'State'
BEGIN
	SELECT DISTINCT StateCode AS DynFilter, StateCode AS DynFilterLabel
	FROM ReportsData..Locations
	ORDER BY StateCode
END

GO

