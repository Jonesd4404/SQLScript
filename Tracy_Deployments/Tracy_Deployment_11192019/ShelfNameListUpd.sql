USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[ShelfNameList]    Script Date: 11/11/2019 11:50:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--RTHOMAS - SW#42671 - Added subject. 
--A couple notes, this report doesn't match naming schemes and returns the locationno as locationid
--
--Tracy Dennis  11/11/19  #10273 Outlet / BookSmarter Transfer project Added Outlet and BookSmarter to the store section and all location section. Commented out   
--                       RDC section since no longer used. 
--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Alter PROCEDURE [dbo].[ShelfNameList]
--declare
@FilterType CHAR(20)-- ='All Locations'
--= 'District'
,@DynFilter CHAR(20) --='All Locations'
--= 'Dallas North'
as
BEGIN
CREATE TABLE #LOCS(LocationID CHAR(10),ShelfScanID int)
IF @FilterType = 'All Locations'
	BEGIN
		INSERT #LOCS
		/********************************************************************
		original code before ticket 46544 -dgreen 7.31.2012
		Brian says store shelves should show up before any have been scanned		
		
		SELECT DISTINCT ss.LocationID, count(ss.ShelfScanID)as CountShelfScans
		FROM ReportsData..ShelfScan ss inner join
		     ReportsData..Locations l
				on ss.LocationID = l.LocationID
		WHERE l.LocationType = 'S' AND
			  l.RetailStore = 'Y' AND
			  l.Status = 'A' 
		group by ss.LocationID
		order by ss.LocationID
		
		********************************************************************/
		
		SELECT DISTINCT ss.LocationID, count(ss.ShelfID)as CountShelfScans --counting shelfID instead of shelfscanID
		FROM ReportsData..Shelf ss inner join  --changed shelfscan table to shelf table
		     ReportsData..Locations l
				on ss.LocationID = l.LocationID
						JOIN reportsdata..LocationsDist ld ON l.LocationID = ld.LocationID

		WHERE 
		--l.LocationType = 'S' AND
		--	  l.RetailStore = 'Y' AND
		(
				RetailStore = 'Y'
				OR RptOutlet = 'Y'
				OR RptBookSmarter = 'Y'
				)
			and  l.Status = 'A' 
		group by ss.LocationID
		order by ss.LocationID
	END
IF @FilterType = 'Store'	
	BEGIN
		/********************************************************************
		original code before ticket 46544 -dgreen 7.31.2012
		Brian says store shelves should show up before any have been scanned		
		
		SELECT DISTINCT ss.LocationID, count(ss.ShelfScanID)as CountShelfScans
		FROM ReportsData..ShelfScan ss inner join
			 ReportsData..Locations l
				on ss.LocationID = l.LocationID
		where l.LocationNo = @DynFilter and
			  l.Status = 'A' 
		group by ss.LocationID
		order by ss.LocationID		
		
		********************************************************************/
		INSERT #LOCS
		SELECT DISTINCT ss.LocationID, count(ss.ShelfID)as CountShelfScans
		FROM ReportsData..Shelf ss inner join
			 ReportsData..Locations l
				on ss.LocationID = l.LocationID
		where l.LocationNo = @DynFilter and
			  l.Status = 'A' 
		group by ss.LocationID
		order by ss.LocationID		
	END

IF @FilterType = 'District'	
	BEGIN
		/********************************************************************
		original code before ticket 46544 -dgreen 7.31.2012
		Brian says store shelves should show up before any have been scanned		
		
		SELECT DISTINCT ss.LocationID, count(ss.ShelfScanID)as CountShelfScans
		FROM ReportsData..ShelfScan ss inner join
			 ReportsData..Locations l
				on ss.LocationID = l.LocationID
		WHERE l.DistrictCode = @DynFilter AND
			  l.RetailStore = 'Y' AND
			  l.Status = 'A'
		group by ss.LocationID
		order by ss.LocationID		
		
		********************************************************************/
		INSERT #LOCS
		SELECT DISTINCT ss.LocationID, count(ss.ShelfID)as CountShelfScans
		FROM ReportsData..Shelf ss inner join
			 ReportsData..Locations l
				on ss.LocationID = l.LocationID
		WHERE l.DistrictCode = @DynFilter AND
			  l.RetailStore = 'Y' AND
			  l.Status = 'A'
		group by ss.LocationID
		order by ss.LocationID		
	END
	
IF @FilterType = 'Region'
	BEGIN
		/********************************************************************
		original code before ticket 46544 -dgreen 7.31.2012
		Brian says store shelves should show up before any have been scanned		
		
		SELECT DISTINCT ss.LocationID, count(ss.ShelfScanID)as CountShelfScans
		FROM ReportsData..ShelfScan ss inner join
			 ReportsData..ReportLocations l
				on ss.LocationID = l.LocationID
		WHERE l.Region = @DynFilter AND
			  l.Status = 'A'
		group by ss.LocationID
		order by ss.LocationID		
		
		********************************************************************/
		INSERT  #LOCS
		SELECT DISTINCT ss.LocationID, count(ss.ShelfID)as CountShelfScans
		FROM ReportsData..Shelf ss inner join
			 ReportsData..ReportLocations l
				on ss.LocationID = l.LocationID
		WHERE l.Region = @DynFilter AND
			  l.Status = 'A'
		group by ss.LocationID
		order by ss.LocationID				  
	END	
	
--IF @FilterType = 'RDC'
--	BEGIN
--		/********************************************************************
--		original code before ticket 46544 -dgreen 7.31.2012
--		Brian says store shelves should show up before any have been scanned		
		
--		SELECT DISTINCT ss.LocationID, count(ss.ShelfScanID)as CountShelfScans
--		FROM ReportsData..ShelfScan ss inner join
--			 ReportsData..Locations l
--				on ss.LocationID = l.LocationID
--			WHERE-- LocationType = 'R'
--				--AND RetailStore = 'N'
--				 l.LocationNo NOT IN ('00451','00710','00999') and
--				 l.RDCLocationNo = @DynFilter and
--				 l.RetailStore = 'Y' and
--				 l.Status = 'A'
--			group by ss.LocationID
--			order by ss.LocationID		
		
--		********************************************************************/
--		INSERT  #LOCS
--		SELECT DISTINCT ss.LocationID, count(ss.ShelfID)as CountShelfScans
--		FROM ReportsData..Shelf ss inner join
--			 ReportsData..Locations l
--				on ss.LocationID = l.LocationID
--			WHERE-- LocationType = 'R'
--				--AND RetailStore = 'N'
--				 l.LocationNo NOT IN ('00451','00710','00999') and
--				 l.RDCLocationNo = @DynFilter and
--				 l.RetailStore = 'Y' and
--				 l.Status = 'A'
--			group by ss.LocationID
--			order by ss.LocationID					 
--	END
create table #SHELFIDS(ShelfProxyID varchar(10), LocationID char(10))
if @FilterType = 'Store'
	begin
		create table #SELECTLIST(ShelfProxyID varchar(10), ShelfDescription varchar(255), LocationID char(10), Subject varchar(255))
		insert #SELECTLIST
		select distinct sd.ShelfProxyID, sd.ShelfDescription, ll.LocationNo, ss.Subject
		from ReportsData..Shelf sd inner join
			#LOCS l
				ON sd.LocationID = l.LocationID left outer join
			ReportsData..Locations ll
				ON l.LocationID = ll.LocationID
			--RTHOMAS - SW#42671
			left join reportsdata..subjectsummary ss with(nolock)
				on ss.subjectkey = sd.subjectkey
		where sd.StatusCode = 1
				
		select * from #SELECTLIST
		order by dbo.RemoveNumbers(ShelfProxyID),dbo.RemoveChars(ShelfProxyID), ShelfDescription
		drop table #SELECTLIST		
	end
else
	begin
		insert #SHELFIDS
		select sf.ShelfProxyID as ShelfProxyID, sd.LocationID
		from ReportsData..Shelf sf inner join
			 ReportsData..Shelf sd
				on sf.ShelfProxyID = sd.ShelfProxyID inner join
			 #LOCS l
				on sf.LocationID = l.LocationID
		where sf.StatusCode = 1 and
		      sd.StatusCode = 1
		group by sf.ShelfProxyID, sd.LocationID
		having count(sf.ShelfProxyID) = 1

		union

		select distinct ShelfProxyID, '' as LocationID
		from ReportsData..Shelf
		where ShelfProxyID not in 
		(
			select sf.ShelfProxyID
			from ReportsData..Shelf sf inner join
				 ReportsData..Shelf sd
					on sf.ShelfProxyID = sd.ShelfProxyID  inner join
			 #LOCS l
				on sf.LocationID = l.LocationID
			where sf.StatusCode = 1 and
			      sd.StatusCode = 1
			group by sf.ShelfProxyID
			having count(sf.ShelfProxyID) = 1 

		)
		order by ShelfProxyID

		create table #SELECTEDLIST(ShelfProxyID varchar(10), ShelfDescription varchar(255), LocationID char(10), Subject varchar(255))
		insert #SELECTEDLIST
		select distinct sd.ShelfProxyID, sd.ShelfDescription, l.LocationNo, ss.Subject
		from ReportsData..Shelf sd left outer join
			 #SHELFIDS si
				ON sd.ShelfProxyID = si.ShelfProxyID and
				   sd.LocationID = si.LocationID left outer join
			 ReportsData..Locations l
				ON si.LocationID = l.LocationID  inner join
				 #LOCS ll
					on sd.LocationID = ll.LocationID
			--RTHOMAS - SW#42671
			left join reportsdata..subjectsummary ss with(nolock)
				on ss.subjectkey = sd.subjectkey
		
		select * from #SELECTEDLIST
		order by dbo.RemoveNumbers(ShelfProxyID),dbo.RemoveChars(ShelfProxyID), ShelfDescription
		DROP table #SELECTEDLIST
	END		
drop table #SHELFIDS
drop table #LOCS
END


GO


