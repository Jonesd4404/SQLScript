USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[SiPS_UsedInventoryBySection]    Script Date: 11/8/2019 2:51:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SiPS_UsedInventoryBySection]
/***************************
Mike T
SIPS Inventory By Section
10/9/2008

RThomas - 1/20/2009
Changed the location filtering and moved over to Almond
3/19/2009 - Added in a date range for date in stock.

RThomas - 4/24/2009
Removed the QOH for later dates due to a new report.

--RTHOMAS - 8/16/2010
SW#30749
Put in a having check for qtypriced for those rare cases that a section has no active items in it.
	
--RTHOMAS - 3/23/2011 
SW#43687
Divide by zero fix incase none were sold

****************************/

@FilterType CHAR(20) --= 'Store'--= 'District'
,@DynFilter CHAR(20) --= '00037'--= 'Dallas North        '
,@startdate datetime --=  '11/23/2011'
,@enddate datetime --= '3/13/2012' 

AS
BEGIN

--declare @filterType char(20), @DynFilter char(20)
--set @FilterType = 'District'
--set @DynFilter = 'Dallas North        '

--DECLARE @Location char(20)
--SET @Location = '00008'
--Location Filtering
/*
DECLARE @LOCS TABLE (LocationNo CHAR(5), LocationName CHAR(30))
IF @Location = 'All'
	BEGIN
	INSERT INTO @LOCS
	SELECT 
		LocationNo, [Name]
		FROM Locations 
		WHERE LocationType = 'S'
			AND RetailStore = 'Y'
			AND Status = 'A'
	ORDER BY LocationNo
	END

IF @Location <> 'All'
	BEGIN
	INSERT INTO @LOCS
	SELECT 
	LocationNo, [Name]
		FROM Locations WHERE LocationNo = @Location
			AND Status = 'A'
	END

IF @FilterType = 'District'
	BEGIN
	INSERT INTO @LOCS
	SELECT 
	LocationNo, [Name]
		FROM ReportsData..Locations WHERE DistrictCode = @Location
	END
*/

DECLARE @LOCS TABLE(LocationNo CHAR(5), LocationName CHAR(30))
IF @FilterType = 'All Locations'
	BEGIN
	INSERT  INTO @LOCS
	SELECT 
		LocationNo, [Name]
		FROM ReportsData..Locations 
		WHERE LocationType = 'S'
			AND RetailStore = 'Y'
			AND Status = 'A'
	ORDER BY LocationNo
	END
IF @FilterType = 'Store'
	BEGIN
	INSERT  INTO @LOCS
	SELECT 
	LocationNo, [Name]
		FROM ReportsData..Locations WHERE LocationNo = @DynFilter
	END
IF @FilterType = 'District'
	BEGIN
	INSERT  INTO @LOCS
	SELECT 
	LocationNo, [Name]
		FROM ReportsData..Locations 
		WHERE DistrictCode = @DynFilter 
		AND RetailStore = 'Y'
	END
IF @FilterType = 'Region'
	BEGIN
	INSERT  INTO @LOCS
	SELECT 
	LocationNo, [Name]
		FROM  ReportsData..ReportLocations --ReportLocations 
		WHERE Region = @DynFilter
	END
IF @FilterType = 'RDC'
BEGIN
	INSERT  INTO @LOCS
	SELECT 
	LocationNo, [Name]
	FROM ReportsData..Locations 
	WHERE-- LocationType = 'R'
		--AND RetailStore = 'N'
		 LocationNo NOT IN ('00451','00710','00999')
		AND RDCLocationNo = @DynFilter
		AND RetailStore = 'Y'
	END
IF @FilterType = 'State'
	BEGIN
	INSERT  INTO @LOCS
	SELECT 
		LocationNo, [Name]
		FROM ReportsData..Locations 
		WHERE LocationType = 'S'
			AND RetailStore = 'Y'
			AND StateCode = @DynFilter
	ORDER BY LocationNo
	END

/********************************/
/*SELECT spi.SipsID,
	spi.ItemCode,
	spi.DateInStock,
	spm.Author,
	spm.Title,
	ss.Subject,
	spi.Price,
	spi.LocationNo
FROM sipsProductinventory spi
	JOIN subjectsummary ss ON ss.SubjectKey = spi.SubjectKey
	JOIN SipsProductMaster spm	ON spm.SipsID = spi.SipsID
	LEFT JOIN sipssaleshistory ssh ON ssh.SipsItemCode = spi.ItemCode
		AND ssh.IsReturn = 'N'
	JOIN @LOCS locs
		ON spi.LocationNo = locs.LocationNo
WHERE --spi.LocationNo = '00043'
spi.Active = 'Y'
AND ssh.Itemcode IS NULL
ORDER BY ss.Subject, spm.Title*/

SELECT spi.LocationNo, ss.Subject,
	COUNT(*) AS QtyPriced,
	SUM(CASE WHEN ssh.Itemcode IS NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END) AS QtyOnHand,
		--days in section
--	SUM(CASE WHEN spi.Active NOT IN ('D','T') AND DATEDIFF(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE())) >= 30 THEN 1 ELSE 0 END) AS QtyOnHand30days,
--	SUM(CASE WHEN spi.Active NOT IN ('D','T') AND DATEDIFF(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE())) >= 60 THEN 1 ELSE 0 END) AS QtyOnHand60days,
--	SUM(CASE WHEN spi.Active NOT IN ('D','T') AND DATEDIFF(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE())) >= 90 THEN 1 ELSE 0 END) AS QtyOnHand90days,
--	SUM(CASE WHEN spi.Active NOT IN ('D','T') AND DATEDIFF(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE())) >= 120 THEN 1 ELSE 0 END) AS QtyOnHand120days,
	SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END) AS SoldCount,
	SUM(CASE WHEN spi.Active = 'D' THEN 1 ELSE 0 END) AS Donates,
	SUM(CASE WHEN spi.Active = 'T' THEN 1 ELSE 0 END) AS Trash,
	--pct sold
	CASE WHEN SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END)>0 THEN	
		SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END)/CAST(count(*) AS MONEY)*100 ELSE 0 END  AS SoldPct,
	--AvgDaysToSell
	SUM(datediff(day, spi.DateInStock, ssh.BusinessDate)) /CAST(count(*) AS MONEY) AS AvgDaysToSell,--only for items that have sold!
	--shelf life
	--For all priced items that have not been trashed or donated
	--days on shelf/divided by number priced
	CASE WHEN SUM(CASE WHEN spi.Active NOT IN ('D','T') THEN 1 ELSE 0 END) > 0 THEN	
	SUM(datediff(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE()))) /CAST(SUM(CASE WHEN spi.Active NOT IN ('D','T') THEN 1 ELSE 0 END)  AS MONEY) ELSE 0 END AS AvgShelfLife,
	SUM(ssh.RegisterPrice) AS TotalSales,
	SUM(CASE WHEN ssh.RegisterPrice < spi.Price THEN 1 ELSE 0 END) AS SoldMarkedDown,
	--PctSoldMarkedDown
	CASE WHEN SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END)>0 THEN	
	SUM(CASE WHEN ssh.RegisterPrice < spi.Price THEN 1 ELSE 0 END)/CAST(SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END) AS MONEY)*100 ELSE 0 END AS PctSoldMarkedDown,
	--RTHOMAS - Divide by zero fix incase none were sold
	case when SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END) > 0 then
		SUM(ssh.RegisterPrice)/ SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END) else 0 end AS AvgSalesAmt,
	--# sold at half
	SUM(CASE WHEN ssh.RegisterPrice >= ((MfgSuggestedPrice/2)-.02) THEN 1 ELSE 0 END) AS SoldAtHalf,
	--PctSoldAtHalf
	CASE WHEN SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END)>0 THEN	
	SUM(CASE WHEN ssh.RegisterPrice >= ((MfgSuggestedPrice/2)-.02) THEN 1 ELSE 0 END)/CAST(SUM(CASE WHEN ssh.Itemcode IS NOT NULL AND spi.Active = 'Y' THEN 1 ELSE 0 END) AS MONEY)*100 ELSE 0 END AS PctSoldAtHalf

FROM ReportsData..SipsProductMaster spm 	
	JOIN ReportsData..SipsProductInventory spi 
		on spm.sipsid = spi.sipsid
	LEFT JOIN ReportsData..sipssaleshistory ssh ON ssh.SipsItemCode = spi.ItemCode
		AND ssh.IsReturn = 'N'
	JOIN ReportsData..subjectsummary ss ON ss.SubjectKey = spi.SubjectKey
	JOIN @LOCS locs
		ON spi.LocationNo = locs.LocationNo
WHERE --spi.LocationNo = '00043' 
spi.dateinstock >= @startdate
and dateinstock <= @enddate
GROUP BY spi.LocationNo, ss.Subject
--RTHOMAS - Put in for those rare cases that there is one item in a section that is not active.
having COUNT(*) > 0
END



GO


