USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[PARAMS_DynFilter_Locations]    Script Date: 10/7/2019 2:20:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PARAMS_DynFilter_Locations]
	--declare
	@FilterType CHAR(20) = ''
	--= 'Store'
AS
/**************************************************************************************************************************************************************************
Tracy Dennis  7/17/19  #10273 Outlet / BookSmarter Transfer project Added Outlet and BookSmarter to the store section while excluding from the district and state sections. 
                       Added the STATUS = 'A' and and RetailStore = 'Y' to region and districts so it doesn't pull closed locations and only retail locations, but additional 
					   logic will be needed in the programs.
****************************************************************************************************************************************************************************/
--========================================================================================
IF @FilterType = ''
BEGIN
	SELECT 'ALL' AS DynFilter
		,'All Locations' AS DynFilterLabel
END

--========================================================================================
IF @FilterType = 'All Locations'
BEGIN
	SELECT 'ALL' AS DynFilter
		,'All Locations' AS DynFilterLabel
		,1 AS Sort
END

--========================================================================================
IF @FilterType = 'Store'
BEGIN
	SELECT '' AS DynFilter
		,'None Selected' AS DynFilterLabel
		,1 AS Sort
	
	UNION ALL
	
	SELECT LocationNo AS DynFilter
		,LocationNo + '   ' + Name AS DynFilterLabel
		,2 AS Sort
	FROM reportsdata..Locations l
	JOIN reportsdata..LocationsDist ld ON l.LocationID = ld.LocationID
	WHERE --CAST(LocationNo as INT)< 210  
		(
			RetailStore = 'Y'
			OR RptOutlet = 'Y'
			OR RptBookSmarter = 'Y'
			)
		AND STATUS = 'A'
	ORDER BY Sort
		,DynFilterLabel
END

--========================================================================================
--District
IF @FilterType = 'District'
BEGIN
	SELECT '' AS DynFilter
		,'None Selected' AS DynFilterLabel
		,1 AS Sort
	
	UNION ALL
	
	SELECT DISTINCT RTRIM(DistrictCode) AS DynFilter
		,DistrictCode AS DynFilterLabel
		,2 AS Sort
	FROM ReportsData..Locations
	WHERE DistrictCode <> ''
		AND DistrictCode <> 'Dallas Area'
		AND RetailStore = 'Y'
		AND STATUS = 'A'
	ORDER BY Sort
		,DynFilterLabel
END

--========================================================================================
--Region
IF @FilterType = 'Region'
BEGIN
	SELECT '' AS DynFilter
		,'None Selected' AS DynFilterLabel
		,1 AS Sort
	
	UNION ALL
	
	SELECT DISTINCT LTRIM(RTRIM(Region)) AS DynFilter
		,LTRIM(RTRIM(Region)) AS DynFilterLabel
		,2 AS Sort
	FROM reportsdata..Locations l
	JOIN reportsdata..LocationsDist ld ON l.LocationID = ld.LocationID
	WHERE Region <> ''
		AND RetailStore = 'Y'
		AND STATUS = 'A'
	ORDER BY Sort
		,DynFilterLabel
END

--========================================================================================
--RDC
IF @FilterType = 'RDC'
BEGIN
	SELECT LocationNo AS DynFilter
		,LocationNo + '   ' + Name AS DynFilterLabel
		,2 AS Sort
	FROM reportsdata..Locations
	WHERE LocationType = 'R'
		AND RetailStore = 'N'
		AND LocationNo NOT IN (
			'00451'
			,'00710'
			,'00999'
			)
		AND STATUS = 'A'
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
	SELECT DISTINCT StateCode AS DynFilter
		,StateCode AS DynFilterLabel
	FROM ReportsData..Locations
	WHERE RetailStore = 'Y'
		AND STATUS = 'A'
	ORDER BY StateCode
END

GO

