USE [Reports]
GO
/****** Object:  StoredProcedure [dbo].[RDA_PARAMS_DynFilter_LocationsMaster]    Script Date: 12/18/2019 10:56:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RDA_PARAMS_DynFilter_LocationsMaster]
@FilterType CHAR(20) 
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
		LocationNo + '   ' + StoreName AS DynFilterLabel,
		2 AS Sort
	FROM ReportsData..StoreLocationMaster
	WHERE   
		StoreType  IN ('S', 'O')
		AND ClosedDate IS NULL
		ORDER BY Sort, DynFilterLabel
END
--========================================================================================
--District
IF @FilterType = 'District'
BEGIN
	SELECT 
		'' AS DynFilter, 
		'None Selected' AS DynFilterLabel,
		1 AS Sort
	UNION ALL
	SELECT DISTINCT RTRIM(DistrictName) AS DynFilter, 
		DistrictName AS DynFilterLabel,
		2 AS Sort
	FROM ReportsData..StoreLocationMaster
	WHERE   
			StoreType IN ('S', 'O')
		AND ClosedDate IS NULL
	ORDER BY Sort, DynFilterLabel
END
--========================================================================================
--Region
IF @FilterType = 'Region'
BEGIN
	SELECT 
		'' AS DynFilter, 
		'None Selected' AS DynFilterLabel,
		1 AS Sort
	UNION ALL
	SELECT DISTINCT 
		RegionName AS DynFilter, 
		RegionName AS DynFilterLabel ,
		2 AS Sort
	FROM ReportsData..StoreLocationMaster
	WHERE   
			StoreType IN ('S', 'O')
		AND ClosedDate IS NULL
	ORDER BY Sort, DynFilterLabel
END
--========================================================================================
--RDC
IF @FilterType = 'RDC'
BEGIN
	SELECT 
		LocationNo AS DynFilter, 
		LocationNo + '   ' + Name As DynFilterLabel, 
		2 AS Sort
	FROM ReportsData..Locations 
	WHERE LocationType = 'R'
		AND RetailStore = 'N'
		AND LocationNo NOT IN ('00451','00710','00999')
		AND Status = 'A'

END
--========================================================================================
--State
IF @FilterType = 'State'
BEGIN
	SELECT DISTINCT StateCode AS DynFilter, StateCode AS DynFilterLabel
	FROM ReportsData..Locations
	ORDER BY StateCode
END
