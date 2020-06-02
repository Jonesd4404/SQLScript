USE [OFS]
GO

/****** Object:  StoredProcedure [dbo].[RPT_SAS_OrderStatus_v2]    Script Date: 09/09/2018 16:30:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--Tracy Dennis 9/9/2018  Added a temporary work around that verifies if SAS MarketOrderId is numeric which is 
--   traditional search and ship. Alpha numberic MarketOrderId is search and ship cart which does not work with
--   the cosmos tables.
--Tracy Dennis 9/10/2018 Changed to a perminate fix.  MarketOrderId was added to cosmos..web_OrderInfo.  Added a union all to get the Search and Ship / Transfer orders part 
--   one Traditional and part two Cart. The Cosmos tables will eventually be going away at that time the report will be rewritten.  Removed the join to Cosmos..web_iteminfo since 
--   no data was used from this table. Added with(nolock) on Cosmos tables.

Alter proc [dbo].[RPT_SAS_OrderStatus_v2]
--declare
@LocationNo varchar(5) --= '00001'
,@StartDate datetime --= '9/1/2018'
,@EndDate datetime --= '9/9/2018'
,@Status int --= null
--,@OrderSystem varchar(3) = 'SAS' --change to SAS for production
,@OrderID bigint --= null
,@CustomerName varchar(100) --= null
as

select --*,
	h.OrderId[OFSOrderId]
	,h.OrderSystem
	,h.OrderDate
	,osc.OrderStatus
	,osc.Description
	,isc.OrderItemStatus
	,isc.Description
	,h.MarketName
	,h.ShipDate
	,h.OrderLocationNo
	,h.LastDateModified
	,d.ItemID
	,d.Price
	,d.LocationNo
	,d.ISBN
	,d.UPC
	,d.ItemCode[SKU]
	,d.SKUExtension
	,d.Title
	,d.Author
	,d.Artist
	,d.Subject
	,d.ShelfProxyID
	,d.LastDateModified
	,case when isnull(ltrim(rtrim(c.Email)),'support@hpb.com') = '' then 'support@hpb.com' else isnull(ltrim(rtrim(c.Email)),'support@hpb.com') end [Email]
	,c.Name[CustomerName]
	,c.Address1
	,c.Address2
	,c.City
	,c.State
	,c.PostalCode
	,wd.Phone
	,sl.TrackingNo
	,oi.OriginLocationNo[RequestLocationno]
	,oi.OriginUserName[Requestuser]
	,d.Price
	,oi.SalesTransaction
	,d.LastUserModified
	,d.ShippingFee
	,case when h.OrderLocationNo = @LocationNo then 'FROM' else 'TO' end[ReportGroup]
from ofs..Order_Header h with(nolock)
	join ofs..Order_Detail d with(nolock)
		on d.OrderID = h.OrderID
	join ofs..Order_Customer c with(nolock)
		on c.CustomerID = h.OrderCustomerID
		and Active = 1
	join ofs..Order_StatusCodes osc with(nolock)
		on osc.OrderStatusID = h.Status
	join ofs..Order_Item_StatusCodes isc with(nolock)
		on isc.OrderItemStatusID = d.Status
	left join ofs..Order_PostageMapping pm with(nolock)
		on pm.OrderID = d.OrderID
		and pm.LocationNo = d.LocationNo
		and pm.Active = 1
	left join PostageService..Shipping_Labels sl with(nolock)
		on sl.LabelID = pm.LabelID
	left join cosmos..web_Customers wd with(nolock)
		on wd.RequestID = h.MarketOrderID
	join cosmos..web_OrderInfo oi with(nolock)
		on oi.RequestID = h.MarketOrderID
		and oi.marketorderid is null  --only Traditional Search and Ship / Transfers orders
	--left join Cosmos..web_iteminfo ii 
	--	on ii.RequestID = oi.RequestID
where --OrderSystem = @OrderSystem
	(h.OrderLocationNo = @LocationNo
		or d.LocationNo = @LocationNo)
	and h.OrderDate >= @StartDate
	and h.OrderDate < dateadd(day,1,@EndDate)
	and ((@Status is null) or (h.Status = @Status))
	and ((@OrderID is null) or (h.OrderID = @OrderID))
		--and h.OrderSystem in ('XFR','SAS')
	and isnumeric(h.MarketOrderID) = 1 --only Traditional Search and Ship / Transfers orders
	and h.OrderSystem in ('XFR', 'SAS')
	--and (h.OrderSystem ='XFR'
		--or h.OrderSystem ='SAS') --and isnumeric(h.MarketOrderID)=1))--traditional Search and Ship orders --this is required for SAS and XFR
	and ((@CustomerName is null) or (c.Name like '%' + @CustomerName + '%'))

union all
select --*,
	h.OrderId[OFSOrderId]
	,h.OrderSystem
	,h.OrderDate
	,osc.OrderStatus
	,osc.Description
	,isc.OrderItemStatus
	,isc.Description
	,h.MarketName
	,h.ShipDate
	,h.OrderLocationNo
	,h.LastDateModified
	,d.ItemID
	,d.Price
	,d.LocationNo
	,d.ISBN
	,d.UPC
	,d.ItemCode[SKU]
	,d.SKUExtension
	,d.Title
	,d.Author
	,d.Artist
	,d.Subject
	,d.ShelfProxyID
	,d.LastDateModified
	,case when isnull(ltrim(rtrim(c.Email)),'support@hpb.com') = '' then 'support@hpb.com' else isnull(ltrim(rtrim(c.Email)),'support@hpb.com') end [Email]
	,c.Name[CustomerName]
	,c.Address1
	,c.Address2
	,c.City
	,c.State
	,c.PostalCode
	,wd.Phone
	,sl.TrackingNo
	,oi.OriginLocationNo[RequestLocationno]
	,oi.OriginUserName[Requestuser]
	,d.Price
	,oi.SalesTransaction
	,d.LastUserModified
	,d.ShippingFee
	,case when h.OrderLocationNo = @LocationNo then 'FROM' else 'TO' end[ReportGroup]
from ofs..Order_Header h with(nolock)
	join ofs..Order_Detail d with(nolock)
		on d.OrderID = h.OrderID
	join ofs..Order_Customer c with(nolock)
		on c.CustomerID = h.OrderCustomerID
		and Active = 1
	join ofs..Order_StatusCodes osc with(nolock)
		on osc.OrderStatusID = h.Status
	join ofs..Order_Item_StatusCodes isc with(nolock)
		on isc.OrderItemStatusID = d.Status
	left join ofs..Order_PostageMapping pm with(nolock)
		on pm.OrderID = d.OrderID
		and pm.LocationNo = d.LocationNo
		and pm.Active = 1
	left join PostageService..Shipping_Labels sl with(nolock)
		on sl.LabelID = pm.LabelID
	join cosmos..web_OrderInfo oi with(nolock)
		on oi.MarketOrderID = h.MarketOrderID
		and oi.marketorderid is not null  --Cart Search and Ship  / Transfers orders
	left join cosmos..web_Customers wd with(nolock)
		on wd.RequestID = oi.RequestID	
	--left join Cosmos..web_iteminfo ii 
	--	on ii.RequestID = oi.RequestID
where --OrderSystem = @OrderSystem
	(h.OrderLocationNo = @LocationNo
		or d.LocationNo = @LocationNo)
	and h.OrderDate >= @StartDate
	and h.OrderDate < dateadd(day,1,@EndDate)
	and ((@Status is null) or (h.Status = @Status))
	and ((@OrderID is null) or (h.OrderID = @OrderID))
		--and h.OrderSystem in ('XFR','SAS')
	and isnumeric(h.MarketOrderID) = 0 --Cart Search and Ship  / Transfers orders
	and h.OrderSystem in ('XFR', 'SAS')
	--and (h.OrderSystem ='XFR'
		--or h.OrderSystem ='SAS') --and isnumeric(h.MarketOrderID)=1))--traditional Search and Ship orders --this is required for SAS and XFR
	and ((@CustomerName is null) or (c.Name like '%' + @CustomerName + '%'))

	order by h.OrderDate desc

GO


