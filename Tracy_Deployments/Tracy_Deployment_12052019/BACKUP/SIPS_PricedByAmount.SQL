USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[SIPS_PricedByAmount]    Script Date: 12/5/2019 2:13:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SIPS_PricedByAmount]
	@startdate datetime = '6/1/2011'
	,@enddate datetime = '6/20/2011'
	,@minprice money = 100.00
	,@FilterType CHAR(20) = 'District'
	,@DynFilter CHAR(20) = 'Dallas North'
as	--RTHOMAS - 6/20/2011 - SW#36572

set nocount on

if @minprice >= 100.00
begin
declare @locs as table (locationno char(5), locationname char(30))
if @filtertype = 'all locations'
begin
insert @locs
	select 
		locationno, [name]
	from reportsdata..locations 
	where locationtype = 's'
		and retailstore = 'y'
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
	where locationno not in ('00451','00710','00999')
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

select 
	l.LocationNo
	,spi.ItemCode
	,spm.Title
	,spi.DateInStock
	,spi.Price
	,isnull(asu.name,spi.CreateUser)[CreateUser]
	,spi.ProductType
	,ss.Subject
from reportsdata..sipsproductinventory spi
	join reportsdata..sipsproductmaster spm on spi.sipsid = spm.sipsid
	join reportsdata..subjectsummary ss on ss.subjectkey = spi.subjectkey
	join reportsdata..locations l on l.locationid = spi.locationid
	left join reportsdata..asusers asu on ltrim(rtrim(asu.userchar30)) = replace(ltrim(rtrim(spi.createuser)),'HPB\','')
	join @locs locs on locs.locationno = l.locationno
	left join reportsdata..sipssaleshistory shh
		on shh.sipsitemcode = spi.itemcode
where spi.dateinstock >= @startdate and spi.dateinstock <= @enddate
	and spi.price >= @minprice
	and spi.active = 'Y'
	and shh.sipsitemcode is null
order by l.locationno, spi.dateinstock
end	

GO

