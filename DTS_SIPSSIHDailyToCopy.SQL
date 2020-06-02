--Steps for DTS_SIPSSIHDailyToCopy 



--*********************************EXEC dbo.BW_SipsReturnsControl

USE [SIPS]
GO

/****** Object:  StoredProcedure [dbo].[BW_SipsReturnsControl]    Script Date: 10/17/2018 2:04:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[BW_SipsReturnsControl]
as

set nocount on

declare @lastDataUpdateKey as bigint

select @lastDataUpdateKey = max(DataUpdateKey) from dbo.SipsSalesHistory with (nolock)

update dbo.SipsSalesReturnsControl
set LastDataUpdateKey = @lastDataUpdateKey,
	LastUpdateTime = getdate()

if @@rowcount = 0 begin
	insert SipsSalesReturnsControl (LastDataUpdateKey,LastUpdateTime)
	values (@lastDataUpdateKey,getdate())
end


GO


dtexec /DTS "\MSDB\SIPS\SIPSSIHDailyToCopy" /SERVER SILVERBELL /CONNECTION "ALMOND.HPB_HistoricalDaily";"\"Data Source=ORANGE;Initial Catalog=HPB_HistoricalDaily;Provider=SQLNCLI10;Integrated Security=SSPI;Auto Translate=False;\"" /CONNECTION "DOGWOOD.SIPS";"\"Data Source=WEIRWOOD;Initial Catalog=SIPS;Provider=SQLNCLI10;Integrated Security=SSPI;Auto Translate=False;\""  /CHECKPOINTING OFF  /REPORTING V


dtexec /SQL "\SIPS_SipsSalesHistoryDailyItemCodes" /SERVER ORANGE  /CONNECTION DestinationConnectionOLEDB;"\"Data Source=WEIRWOOD;Initial Catalog=SIPS;Provider=SQLNCLI10;Integrated Security=SSPI;Auto Translate=false;\"" /CONNECTION SourceConnectionOLEDB;"\"Data Source=orange;Initial Catalog=HPB_HistoricalDaily;Provider=SQLNCLI10;Integrated Security=SSPI;Auto Translate=false;\"" /CHECKPOINTING OFF /REPORTING V

--**************************************exec dbo.BW_SipsReturns

USE [SIPS]
GO

/****** Object:  StoredProcedure [dbo].[BW_SipsReturns]    Script Date: 10/17/2018 2:05:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[BW_SipsReturns]
	@debugflag tinyint = 0
as

declare @SipsItemCode int,
		@IsReturn char(1),
		@debug tinyint,
		@maxRetDataUpdateKey as bigint

set nocount on

set		@debug = @debugflag

--fill new returns
--select @maxRetDataUpdateKey = max(DataUpdateKey) from dbo.SipsSalesReturns

insert into dbo.SipsSalesReturns (
	LocationID, XactionType, SalesXactionId, 
	LineNumber, SipsItemCode, BusinessDate, DataUpdateKey)
select	
	h.LocationID, h.XactionType, h.SalesXactionId, 
	h.LineNumber, h.SipsItemCode, h.BusinessDate, h.DataUpdateKey
from dbo.SipsSalesHistory h with (nolock)
	left join SipsSalesReturns r with (nolock)
	on h.SipsItemcode = r.SipsItemcode
where	h.IsReturn = 'Y'
	and r.SipsItemCode is null
/*

insert into dbo.SipsSalesReturns (LocationID, XactionType, SalesXactionId, LineNumber, SipsItemCode, BusinessDate, DataUpdateKey)
select	LocationID, XactionType, SalesXactionId, LineNumber, SipsItemCode, BusinessDate, DataUpdateKey
from	dbo.SipsSalesHistory h
where	h.DataUpdateKey > @maxRetDataUpdateKey
		and h.IsReturn = 'Y'
*/

--remove sold items
/* 03/24/15
declare soldAgain cursor local forward_only for
	select SipsItemCode from dbo.SipsSalesHistory with (nolock) where IsReturn ='Y' 
	--and SipsItemCode > (select LastDataUpdateKey from dbo.SipsSalesReturnsControl) 03/20/15
	and DataUpdateKey > (select LastDataUpdateKey from dbo.SipsSalesReturnsControl)
	group by sipsItemCode --having (count(sipsItemCode) > 1) -- this will not remove sold,return then sold
*/	
declare soldAgain cursor local forward_only for
		select h.SipsItemCode from dbo.SipsSalesHistory h with (nolock) 
		inner join dbo.SipsSalesReturns r
		on  h.SipsItemCode = r.SipsItemCode
		and h.DataUpdateKey > (select LastDataUpdateKey from dbo.SipsSalesReturnsControl)
		group by h.sipsItemCode 


open soldAgain

fetch soldAgain into @SipsItemCode

while (@@fetch_status= 0) begin
	if @debug = 1 print @sipsItemCode

	select top 1 @IsReturn=IsReturn  from dbo.SipsSalesHistory with (nolock)
	where sipsItemCode = @sipsItemCode
	order by EndDate desc, DataUpdateKey desc	--same book can returned 
												--and sold in a transaction which will have same enddate!
	
	if @debug = 1 print @IsReturn

	if @IsReturn = 'N' begin --sold
		if @debug = 1 print 'delete request'
		--remove from returns
		delete from dbo.SipsSalesReturns where sipsItemCode = @sipsItemCode
	end --sold
	
	if @debug = 1 print '----------------'
	
	fetch soldAgain into @SipsItemCode
end --while

close soldAgain
deallocate soldAgain

GO






--*******************************EXEC dbo.BW_SipsResaleCleanup

USE [SIPS]
GO

/****** Object:  StoredProcedure [dbo].[BW_SipsResaleCleanup]    Script Date: 10/17/2018 2:06:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[BW_SipsResaleCleanup]
	@debugflag tinyint = 0
as

declare @SipsItemCode int,
		@IsReturn char(1),
		@debug tinyint,
		@maxRetDataUpdateKey as bigint,
		@lastActivityRow as bigint

set nocount on

set		@debug = @debugflag

--remove sold items or any duplicates in sipssaleshistory

declare soldAgain cursor local forward_only for
	select h.SipsItemCode from dbo.SipsSalesHistory h with (nolock) 
		left join dbo.SipsSalesReturns r with (nolock)
			on h.sipsItemCode = r.sipsItemCode
	where r.sipsItemCode is null
	group by h.sipsItemCode having (count(h.sipsItemCode) > 1)

open soldAgain

fetch soldAgain into @SipsItemCode

while (@@fetch_status= 0) begin
	if @debug = 1 print @sipsItemCode

	select top 1 
		@IsReturn=IsReturn, 
		@lastActivityRow = DataUpdateKey from dbo.SipsSalesHistory with (nolock)
	where sipsItemCode = @sipsItemCode
	order by EndDate desc, DataUpdateKey desc

	if @debug = 1 print @IsReturn

	if @IsReturn = 'N' begin --sold
		if @debug = 1 print 'delete request'
		--remove old record from sips sales
		insert into dbo.SipsSalesHistoryDeleted select * from dbo.SipsSalesHistory where sipsItemCode = @sipsItemCode and DataUpdateKey <> @lastActivityRow
		delete from dbo.SipsSalesHistory where sipsItemCode = @sipsItemCode and DataUpdateKey <> @lastActivityRow
	end --sold
	
	if @debug = 1 print '----------------'
	
	fetch soldAgain into @SipsItemCode
end --while

close soldAgain
deallocate soldAgain


GO

--******************************************EXEC dbo.PCMS_ProcessCustomerReturnAsTransfer

USE [SIPS]
GO

/****** Object:  StoredProcedure [dbo].[PCMS_ProcessCustomerReturnAsTransfer]    Script Date: 10/17/2018 2:07:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[PCMS_ProcessCustomerReturnAsTransfer]
as	--03/30/15

declare @now as datetime = getdate()

set nocount on 

declare 
	@InProgressUpdateDataUpdateKey bigint,
	@LastDataUpdateKey bigint,
	@InsertCount int

select @InProgressUpdateDataUpdateKey = max(DataUpdateKey) from dbo.SipsSalesHistory
select @LastDataUpdateKey = LastDataUpdateKey from dbo.SipsNonSalesReturnsControl

insert	dbo.SipsNonSalesReturnsControlHistory(LastDataUpdateKey, LastUpdateTime, PreviousDataUpdateKey, PreviousUpdateTime,
		InProgressUpdateDataUpdateKey, InProgressUpdateUpdateTime, InsertCount)
select	LastDataUpdateKey, LastUpdateTime, PreviousDataUpdateKey, PreviousUpdateTime,
		InProgressUpdateDataUpdateKey, InProgressUpdateUpdateTime, InsertCount
from	dbo.SipsNonSalesReturnsControl

if @LastDataUpdateKey is null begin 
	set @LastDataUpdateKey = @InProgressUpdateDataUpdateKey
	insert 	dbo.SipsNonSalesReturnsControl([LastDataUpdateKey],[LastUpdateTime],
			[InProgressUpdateDataUpdateKey],[InProgressUpdateUpdateTime], InsertCount)
	values (@LastDataUpdateKey,@now,@InProgressUpdateDataUpdateKey,@now, @InsertCount)
end

update dbo.SipsNonSalesReturnsControl
set InProgressUpdateDataUpdateKey = @InProgressUpdateDataUpdateKey,
	InProgressUpdateUpdateTime = @now

if @InProgressUpdateDataUpdateKey > @LastDataUpdateKey begin --check for new returns

	--using table varibale, the select was not returning results...
	--declare @AvgCost table (LocationNo char(5), ProductType char(4), Cost money) 
	--insert	@AvgCost (LocationNo, ProductType, Cost)
	--select	LocationNo, ProductType, Cost
	--from	AvgBookCost_v2 
	--where	FirstDayOfMonth = (select max(FirstDayOfMonth) from AvgBookCost_v2)
	if object_id('tempdb..#AvgCost') is not null begin 
		drop table #AvgCost
	end
	select	LocationNo, ProductType, Cost into #AvgCost
	from	AvgBookCost_v2 
	where	FirstDayOfMonth = (select max(FirstDayOfMonth) from AvgBookCost_v2)

	set xact_abort on

	begin tran

	insert into SIPS..InventoryItemTransfersAny (
		SipsItemCode, DipsItemCode, TransferType, TransferRequestSourceID, 
		FromLocationNo, ToLocationNo, 
		DipsCost, ProductType, 
		StatusCode, Quantity, 
		CreateUser, CreateMachine, 
		TransferRequestDateTime, InventoryCode, Processed, 
		InsertDateTime)
	select	
		h.SipsItemCode, null as DipsItemCode, 3 as TransferType, 1 as [TransferRequestSourceID],
		li.LocationNo as FromLocationNo, lh.LocationNo as ToLocationNo, 
		c.Cost, i.ProductType,
		1 as StatusCode, 1 as Quantity,
		'PCMS-NonSoldStoreReturn' [CreateUser], 'PCMS-AUTO-RETURN-PROC' as CreateMachine,
		h.EndDate as TransferRequestDateTime, null as [InventoryCode], 0 as Processed,  @now as InsertDateTime
	from sipsSalesHistory h
		inner join SipsProductInventory i
			on h.SipsItemCode = i.Itemcode
		inner join Locations lh
			on lh.LocationId = h.LocationId
		inner join Locations li
			on li.LocationNo = i.LocationNo
		inner join #AvgCost c
			on i.LocationNo = c.LocationNo
			and i.ProductType = c.ProductType
	where 
		h.dataupdatekey <= @InProgressUpdateDataUpdateKey
		and h.dataupdatekey > @LastDataUpdateKey
		and h.isreturn = 'Y'
		and lh.LocationID <> li.LocationID

	set @InsertCount = @@rowcount
	
	update dbo.SipsNonSalesReturnsControl
		set PreviousDataUpdateKey = LastDataUpdateKey,
			PreviousUpdateTime = LastUpdateTime,
			LastDataUpdateKey = @InProgressUpdateDataUpdateKey,
			LastUpdateTime = getdate(),
			InsertCount = @InsertCount
			
	commit tran

end --check for new returns


GO




--****************************************exec dbo.BW_ProcessSipsSalesHistoryDailyItemCodes

USE [SIPS]
GO

/****** Object:  StoredProcedure [dbo].[BW_ProcessSipsSalesHistoryDailyItemCodes]    Script Date: 10/17/2018 2:08:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[BW_ProcessSipsSalesHistoryDailyItemCodes]
as

set nocount on

declare @autokey int
declare @now datetime= getdate()
select	@autokey = max(autokey) from dbo.SipsSalesHistoryDailyItemCodes

--select @autokey
if @autokey is not null begin --autokey

	set xact_abort on

	begin tran
	
	update	SipsProductInventoryDailyItemStatus
	set		ItemStatus = 0,
			DataUpdateKey = s.DataUpdateKey,
			UpdateDateTime = @now
	from	dbo.SipsSalesHistoryDailyItemCodes s
			inner join dbo.SipsProductInventoryDailyItemStatus i
				on i.ItemCode = s.SipsItemCode
	where	s.autokey <= @autokey --this is based on clean table every time it process and only protects adding records while this SP executes..
	
	insert	dbo.SipsProductInventoryDailyItemStatus (ItemCode,ItemStatus,InsertDateTime,DataUpdateKey)
	select s.SipsItemCode,0,@now,s.DataUpdateKey from 
	(select	SipsItemCode, max(DataUpdateKey) DataUpdateKey
	from	dbo.SipsSalesHistoryDailyItemCodes
	where	autokey <= @autokey
	group by SipsItemCode)  s
	left join dbo.SipsProductInventoryDailyItemStatus d
		on s.SipsItemCode = d.ItemCode
	where d.ItemCode is null

	delete from dbo.SipsSalesHistoryDailyItemCodes where autokey <= @autokey

	commit tran

	update	dbo.SipsProductInventoryDailyItemStatus
	set		ItemStatus = null
	from	 dbo.SipsProductInventoryDailyItemStatus d
			inner join dbo.SipsSalesReturns r with (nolock)
				on d.ItemCode = r.SipsItemCode

	--SPIA 09/15/16
	update dbo.SipsProductInventory
	set ItemStatus = null
	from dbo.SipsProductInventory i with(nolock)
		inner join dbo.SipsProductInventoryDailyItemStatus d with (nolock)
			on i.ItemCode = d.ItemCode
	where i.ItemStatus is not null and d.ItemStatus is null

end --autokey
GO





