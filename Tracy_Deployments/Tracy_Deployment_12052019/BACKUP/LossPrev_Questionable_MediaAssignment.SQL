USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[LossPrev_Questionable_MediaAssignment]    Script Date: 12/5/2019 2:18:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* =============================================
RTHOMAS - "Exception report" for incorrectly assigned DVD's and CD's
 =============================================*/
CREATE PROCEDURE [dbo].[LossPrev_Questionable_MediaAssignment]
@startdate datetime = '1/1/2011'
,@enddate datetime = '3/7/2011'
,@FilterType varchar(20) = 'All Locations'
,@DynFilter varchar(20) = 'All Locations'
AS
BEGIN
	SET NOCOUNT ON;
--Location Filtering
declare @locs as table (locationno char(5), locationname char(30))
if @filtertype = 'all locations'
begin
insert @locs
	select 
		locationno, [name]
	from reportsdata..locations 
	where locationtype = 's'
		and retailstore = 'y'
		--and status = 'a'
	order by locationno
end
if @filtertype = 'store'
begin
insert @locs
	select 
		locationno, [name]
	from reportsdata..locations where locationno = @dynfilter
end
if @filtertype = 'district'
begin
insert @locs
	select 
		locationno, [name]
	from reportsdata..locations 
	where districtcode = @dynfilter 
		and retailstore = 'y'
end
if @filtertype = 'region'
begin
insert @locs
	select 
		locationno, [name]
		from reportsdata..reportlocations 
		where region = @dynfilter
end
if @filtertype = 'rdc'
begin
insert @locs
	select 
		locationno, [name]
	from reportsdata..locations 
	where-- locationtype = 'r'
		--and retailstore = 'n'
		locationno not in ('00451','00710','00999')
		and rdclocationno = @dynfilter
		and retailstore = 'y'
end
if @filtertype = 'state'
begin
insert @locs
	select 
		locationno, [name]
	from reportsdata..locations 
	where locationtype = 's'
		and retailstore = 'y'
		and statecode = @dynfilter
	order by locationno
end

--And the simple query
select 
	spi.locationno
	,producttype
	,ss.Subject
	,count(producttype)[TotalCreated]
	,sum(case when spi.active = 'Y' then 1 else 0 end)[TotalActive]
	,sum(case when spi.active = 'D' then 1 else 0 end)[TotalDonated]
	,sum(case when spi.active = 'T' then 1 else 0 end)[TotalTrashed]
	,sum(case when spi.active = 'B' then 1 else 0 end)[TotalBookSmarter]
	,sum(case when spi.active = 'M' then 1 else 0 end)[TotalMissing]
	,sum(isnull(ssh.quantity,0))[TotalSold]
	,sum(case when spi.active not in ('Y','D','T','B','M') then 1 else 0 end)[TotalOther] --In case a new status code is created.
from reportsdata..sipsproductinventory spi
	join reportsdata..subjectsummary ss on ss.subjectkey = spi.subjectkey
	join @locs l on l.locationno = spi.locationno
	left join reportsdata..sipssaleshistory ssh on ssh.sipsitemcode = spi.ItemCode
		and ssh.isreturn = 'N'
where dateinstock >= @startdate
	and dateinstock <= @enddate
	and ss.subject <> 'Clearance'
	and (
		(producttype = 'CDU' and left(ss.subject, 2) <> 'CD' and ss.subject <> 'Audio')
		or (producttype = 'DVD' and left(ss.subject, 3) <> 'DVD' and ss.subject <> 'Video')
		)
group by spi.locationno,ss.subject,spi.producttype
order by spi.locationno,spi.producttype,ss.subject

END

GO

