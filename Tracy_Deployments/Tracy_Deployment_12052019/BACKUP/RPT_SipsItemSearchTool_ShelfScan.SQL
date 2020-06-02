USE [iSales]
GO

/****** Object:  StoredProcedure [dbo].[RPT_SipsItemSearchTool_ShelfScan]    Script Date: 12/5/2019 2:22:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[RPT_SipsItemSearchTool_ShelfScan]



@ItemCode bigint,
@LocationNo char(5)


as


/********************************************
SIPS Item Search Tool

Created For: 
Users to find information about
sales history, shelf scan history, listing
and delisting patterns of SIPS items...

Created By:
dgreen - 9.7.2010

updated 2.19.2014 changed shelfitemscanhistory
to shelfitemscanhistoryactive to reflect a
change in how we store historical item scans
********************************************/


Declare @Sku nvarchar(63),
		@InventoryItemID int;


set @Sku = 'U' + cast(@ItemCode as nvarchar(62));



/*******************************************
Shelf Scan and Shelf Scan Historical Data
********************************************/
	
/*
declare @Scans table (ScanStatus nvarchar(20), ItemCode bigint, ItemScanDate datetime, 
						ShelfScanDate datetime, ShelfID varchar(10), ShelfDescription varchar(255))
	
insert into @Scans
*/

select 'Current' [ScanStatus]
		,loc.LocationNo
		,ISNULL(sis.ItemCodeSips, sis.ItemCodeDips) [ItemCode]
		,sis.ScannedOn [ItemScanDate]
		,ss.ScannedOn [ShelfScanDate]
		,s.ShelfProxyID [ShelfID]
		,s.ShelfDescription
		
from SIPS..ShelfItemScan sis with (nolock)
join SIPS..ShelfScan ss with (nolock)
	on ss.ShelfScanID = sis.ShelfScanID
join SIPS..Shelf s with (nolock)
	on s.ShelfID = ss.ShelfID
join SIPS..Locations loc
	on loc.LocationID = ss.LocationID
where ItemCodeSips = @ItemCode

union all

select 'Historical' [ScanStatus]
		,loc.LocationNo
		,ISNULL(sis.ItemCodeSips, sis.ItemCodeDips) [ItemCode]
		,sis.ScannedOn [ItemScanDate]
		,ss.ScannedOn [ShelfScanDate]
		,s.ShelfProxyID [ShelfID]
		,s.ShelfDescription
		 
from SIPS..ShelfItemScanHistoryActive sis with (nolock)
join SIPS..ShelfScan ss with (nolock)
	on ss.ShelfScanID = sis.ShelfScanID
join SIPS..Shelf s with (nolock)
	on s.ShelfID = ss.ShelfID
join SIPS..Locations loc with (nolock)
	on loc.LocationID = ss.LocationID	
where ItemCodeSips = @ItemCode

union all

select 'Historical' [ScanStatus]
		,loc.LocationNo
		,ISNULL(sis.ItemCodeSips, sis.ItemCodeDips) [ItemCode]
		,sis.ScannedOn [ItemScanDate]
		,ss.ScannedOn [ShelfScanDate]
		,s.ShelfProxyID [ShelfID]
		,s.ShelfDescription
		 
from SIPS..ShelfItemScanHistoryActive sis with (nolock)
join SIPS..ShelfScanHistory ss with (nolock)
	on ss.ShelfScanID = sis.ShelfScanID
join SIPS..Shelf s with (nolock)
	on s.ShelfID = ss.ShelfID
join SIPS..Locations loc with (nolock)
	on loc.LocationID = ss.LocationID	
where ItemCodeSips = @ItemCode;
GO

