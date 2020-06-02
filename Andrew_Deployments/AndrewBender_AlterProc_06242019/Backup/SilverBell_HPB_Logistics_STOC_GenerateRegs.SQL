USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[STOC_GenerateReqs]    Script Date: 6/24/2019 8:35:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B.>
-- Create date: <6/29/12>
-- Description:	<Generates new requisitions for active locations once reqs are consolidated to POs.....>
-- =============================================
CREATE PROCEDURE [dbo].[STOC_GenerateReqs]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -----------**Release all locks...............................................................................................
	update HPB_Logistics..STOC_Reorder_Control
	set Locked = 'N', LockedBy = null, LockedDate = null
	where Locked = 'Y' and VendorID<>'WHPBSUPPLY'
-----------**Get all store locations...............................................................................................
	create table #locs(locationno char(5), locationname char(30), locationID char(10))
	begin
		insert #locs
		select locationno, DistrictCode, locationid 
		from HPB_Prime..Locations
		where retailstore = 'y' and isnumeric(locationno) = 1 and status = 'A' and CAST(locationno as int) between 1 and 200
				or Status='A' and UserInt1=1 and locationno!='00888'
		order by LocationNo
	end
-----------**Get reorderable vendors...................................................................................
	create table #rVendors(vendorID varchar(20), NextOrderDate datetime)
	begin
		insert HPB_Logistics..STOC_Vendors
		select distinct vendorid, Name, null, null, null, null, null, null, null
		from HPB_Prime..vendormaster with(nolock)
		where isnull(ltrim(rtrim(userchar30)),'') <> '' and UserChar15 in ('STOC') and vendorid not in (select distinct VendorID from HPB_Logistics..STOC_Vendors)

		insert #rVendors
		select distinct v.vendorid,(select distinct top 1 RequisitionDueDate from HPB_Logistics..STOC_Reorder_Control where VendorID=v.VendorID)[NextOrderDate]
		from HPB_Logistics..STOC_Vendors v with(nolock) 
	end
	
-----------**Put all vendors into a cross join with locations..............................................................
	create table #reorderReqs(locationno char(5), vendorid varchar(30))
	CREATE  CLUSTERED  INDEX [IDX_ROITEMS_RU] ON #reorderReqs ([locationno], [vendorid])

	insert into #reorderReqs
	select lc.locationno,v.vendorID
	from #locs lc cross join #rVendors v
	
----delete out non-supply reorder locations.....
	delete from #reorderReqs where VendorID!='WHPBSUPPLY' and LocationNo in (select LocationNo from HPB_Prime..Locations where UserInt1=1) 

-----------**Insert any missing Locations into locations table.....................................................................
	insert into HPB_Logistics..STOC_Locations
	select locationno,locationID,'N',GETDATE()
	from #locs
	where locationno not in (select locationno from HPB_Logistics..STOC_Locations)
		and locationID not in (select locationID from HPB_Logistics..STOC_Locations)

	----turn off any stores that have been set to inactive...............................................
	update sl
	set sl.Active='N'
	from HPB_Logistics..STOC_Locations sl inner join HPB_Prime..Locations l on sl.LocationID=l.LocationID
	where l.Status='I'

-----------**Insert any missing Store/Vendor records.....................................................................
	insert into HPB_Logistics..STOC_Reorder_Control(StoreNo,VendorID)
	select rr.locationno,rr.vendorid  
	from #reorderReqs rr inner join HPB_Logistics..STOC_Locations sl on rr.locationno = sl.locationno
		left join HPB_Logistics..STOC_Reorder_Control src on rr.locationno = src.storeno
	where (isnull(src.storeno,'') = '' and isnull(src.vendorid,'') = '' and sl.Active='Y')
		or (not exists(select distinct vendorid from HPB_Logistics..STOC_Reorder_Control where vendorid = rr.vendorid and StoreNo = rr.locationno) and sl.Active='Y')
	group by rr.locationno,rr.vendorid  
	order by rr.vendorid, rr.locationno
	
-----------**Join with SEQ requisitionheader to delete consolidated orders..............................................................
	update src
	set src.requisitionno = null,src.status = null, src.requisitiondate = null, src.requisitionduedate = null
	from HPB_Logistics..STOC_Reorder_Control src
	where  Status in ('99') or src.requisitionno in (select requisitionno FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader
							where ((ponumber is not null and requestby <> 'VOID') or (ponumber is null and requestby = 'VOID')) and requisitionno = src.requisitionno)
-----------**Put Store/Vendor records that need a new req into temp table................................................
	create table #NewReqs(ID int identity(1,1), locationno char(5), vendorid varchar(30))
	CREATE  CLUSTERED  INDEX [IDX_ROITEMS_RU] ON #NewReqs ([locationno], [vendorid])
	
	insert into #NewReqs
	select src.StoreNo,src.VendorID
	from HPB_Logistics..STOC_Reorder_Control src inner join HPB_Logistics..STOC_Locations sl on src.storeno = sl.locationno
		inner join #rVendors v on src.VendorID = v.VendorID
	where sl.active = 'Y' and src.requisitionno is null

	-----------**loop thru temp table and get new values...................................................................
	declare @loop int
	set @loop = (select MAX(ID) from #NewReqs)
	
	while isnull(@loop,0) > 0
		begin
			declare @sRet char(6)
			declare @newReqNo char(6)
			exec OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.STOC_GetNextRequisitionNo @sRet = @newReqNo output

			update src
			set src.requisitionno = @newReqNo
			,src.status = 10
			,src.requisitiondate = GETDATE()
			,src.requisitionduedate = (select dbo.FN_STOC_GetNextOrderDate(src.vendorid))
			from HPB_Logistics..STOC_Reorder_Control src 
			where src.vendorid = (select vendorid from #NewReqs where ID = @loop)
				and src.storeno = (select locationno from #NewReqs where ID = @loop)
			
			set @loop = @loop - 1 
		end	
	----------**end of loop................................................................................................

drop table #locs
drop table #rVendors
drop table #reorderReqs
drop table #NewReqs

END

GO

