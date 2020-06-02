USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[LossPrev_Questionable_MediaAssignment]    Script Date: 12/3/2019 6:24:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* =============================================
RTHOMAS - "Exception report" for incorrectly assigned DVD's and CD's

--TDennis - 12/2/2019 - #10273 Outlet / BookSmarter Transfer project - Changed All Location logic so BookSmarter  / Outlet would be included. or excluded for state, region, and district
--          Removed the RDC logic since no longer used.  
 =============================================*/
ALTER PROCEDURE [dbo].[LossPrev_Questionable_MediaAssignment] @startdate DATETIME --= '1/1/2011'
	,@enddate DATETIME --= '3/7/2011'
	,@FilterType VARCHAR(20) --= 'All Locations'
	,@DynFilter VARCHAR(20) --= 'All Locations'
AS
BEGIN
	SET NOCOUNT ON;

	--Location Filtering
	DECLARE @locs AS TABLE (
		locationno CHAR(5)
		,locationname CHAR(30)
		)

	IF @filtertype = 'all locations'
	BEGIN
		INSERT @locs
		SELECT locationno
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
		--	and retailstore = 'y'
		--and status = 'a'
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
	--	where-- locationtype = 'r'
	--		--and retailstore = 'n'
	--		locationno not in ('00451','00710','00999')
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
		--	and retailstore = 'y'
		WHERE statecode = @dynfilter
			AND RetailStore = 'Y'
			AND STATUS = 'A'
		ORDER BY locationno
	END

	--And the simple query
	SELECT spi.locationno
		,producttype
		,ss.Subject
		,count(producttype) [TotalCreated]
		,sum(CASE 
				WHEN spi.active = 'Y'
					THEN 1
				ELSE 0
				END) [TotalActive]
		,sum(CASE 
				WHEN spi.active = 'D'
					THEN 1
				ELSE 0
				END) [TotalDonated]
		,sum(CASE 
				WHEN spi.active = 'T'
					THEN 1
				ELSE 0
				END) [TotalTrashed]
		,sum(CASE 
				WHEN spi.active = 'B'
					THEN 1
				ELSE 0
				END) [TotalBookSmarter]
		,sum(CASE 
				WHEN spi.active = 'M'
					THEN 1
				ELSE 0
				END) [TotalMissing]
		,sum(isnull(ssh.quantity, 0)) [TotalSold]
		,sum(CASE 
				WHEN spi.active NOT IN (
						'Y'
						,'D'
						,'T'
						,'B'
						,'M'
						)
					THEN 1
				ELSE 0
				END) [TotalOther] --In case a new status code is created.
	FROM reportsdata..sipsproductinventory spi
	JOIN reportsdata..subjectsummary ss ON ss.subjectkey = spi.subjectkey
	JOIN @locs l ON l.locationno = spi.locationno
	LEFT JOIN reportsdata..sipssaleshistory ssh ON ssh.sipsitemcode = spi.ItemCode
		AND ssh.isreturn = 'N'
	WHERE dateinstock >= @startdate
		AND dateinstock <= @enddate
		AND ss.subject <> 'Clearance'
		AND (
			(
				producttype = 'CDU'
				AND left(ss.subject, 2) <> 'CD'
				AND ss.subject <> 'Audio'
				)
			OR (
				producttype = 'DVD'
				AND left(ss.subject, 3) <> 'DVD'
				AND ss.subject <> 'Video'
				)
			)
	GROUP BY spi.locationno
		,ss.subject
		,spi.producttype
	ORDER BY spi.locationno
		,spi.producttype
		,ss.subject
END
GO


