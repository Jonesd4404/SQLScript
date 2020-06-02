USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[SIPS_PricedByAmount]    Script Date: 12/3/2019 2:27:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SIPS_PricedByAmount] @startdate DATETIME --= '6/1/2011'
	,@enddate DATETIME --= '6/20/2011'
	,@minprice MONEY = 100.00
	,@FilterType CHAR(20) --= 'District'
	,@DynFilter CHAR(20) --= 'Dallas North'
AS --RTHOMAS - 6/20/2011 - SW#36572
--TDennis - 12/2/2019 - #10273 Outlet / BookSmarter Transfer project - Changed All Location logic so BookSmarter  / Outlet would be included. or excluded for state, region, and district
--          Removed the RDC logic since no longer used.   
SET NOCOUNT ON

IF @minprice >= 100.00
BEGIN
	DECLARE @locs AS TABLE (
		locationno CHAR(5)
		,locationname CHAR(30)
		)

	IF @filtertype = 'all locations'
	BEGIN
		INSERT @locs
		SELECT l.locationno
			,[name]
		FROM reportsdata..locations l
		JOIN reportsdata..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE (
				RetailStore = 'Y'
				OR RptOutlet = 'Y'
				OR RptBookSmarter = 'Y'
				)
			AND STATUS = 'A'
		--where locationtype = 's'
		--and retailstore = 'y'
		ORDER BY locationno
	END

	IF @filtertype = 'store'
	BEGIN
		INSERT @locs
		SELECT locationno
			,[name]
		FROM reportsdata..locations
		WHERE locationno = @dynfilter
	END

	IF @filtertype = 'district'
	BEGIN
		INSERT @locs
		SELECT locationno
			,[name]
		FROM reportsdata..locations
		WHERE districtcode = @dynfilter
			AND retailstore = 'y'
			AND STATUS = 'A'
	END

	IF @filtertype = 'region'
	BEGIN
		INSERT @locs
		SELECT locationno
			,[name]
		--from reportsdata..reportlocations 
		FROM reportsdata..Locations l
		JOIN reportsdata..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE region = @dynfilter
			AND RetailStore = 'Y'
			AND STATUS = 'A'
	END

	--if @filtertype = 'rdc'
	--begin
	--insert @locs
	--	select 
	--		locationno, [name]
	--	from reportsdata..locations 
	--	where locationno not in ('00451','00710','00999')
	--		and rdclocationno = @dynfilter
	--		and retailstore = 'y'
	--end
	IF @filtertype = 'state'
	BEGIN
		INSERT @locs
		SELECT locationno
			,[name]
		FROM reportsdata..locations
		--where locationtype = 's'
		WHERE RetailStore = 'Y'
			AND STATUS = 'A'
			AND statecode = @dynfilter
		ORDER BY locationno
	END

	SELECT l.LocationNo
		,spi.ItemCode
		,spm.Title
		,spi.DateInStock
		,spi.Price
		,isnull(asu.name, spi.CreateUser) [CreateUser]
		,spi.ProductType
		,ss.Subject
	FROM reportsdata..sipsproductinventory spi
	JOIN reportsdata..sipsproductmaster spm ON spi.sipsid = spm.sipsid
	JOIN reportsdata..subjectsummary ss ON ss.subjectkey = spi.subjectkey
	JOIN reportsdata..locations l ON l.locationid = spi.locationid
	LEFT JOIN reportsdata..asusers asu ON ltrim(rtrim(asu.userchar30)) = replace(ltrim(rtrim(spi.createuser)), 'HPB\', '')
	JOIN @locs locs ON locs.locationno = l.locationno
	LEFT JOIN reportsdata..sipssaleshistory shh ON shh.sipsitemcode = spi.itemcode
	WHERE spi.dateinstock >= @startdate
		AND spi.dateinstock <= @enddate
		AND spi.price >= @minprice
		AND spi.active = 'Y'
		AND shh.sipsitemcode IS NULL
	ORDER BY l.locationno
		,spi.dateinstock
END
GO


