USE [Reports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--11/30/2018  RThomas and TDennis -- Process to monitor Bookworm Cart unprocessed orders
Create procedure dbo.rpt_SearchAndShip_UprocessedOrders
(
--report parameters
--declare 
 @StartDate datetime-- ='11/26/18'
 --dateadd(day,-7,current_timestamp)
,@EndDate datetime --='12/3/18'
)
as


--formatting date with no time, SQL2008 and up only. change to painful datepart parsing for older SQL servers.
set @StartDate = convert(date, @StartDate)
set @EndDate = convert(date, @EndDate)

select o.marketOrderId, o.sku, o.registersku, o.checkOutDate, o.locationNo, isnull(u.name,o.checkOutUser)[checkOutUser], oc.name[CustomerName],os.name[Status] 
from ReportsData..BookWormOrders o
       join ReportsData..BookWormOrderCustomer oc
              on oc.custId = o.custid
       join  ReportsData..BookwormOrderStatus os
              on os.statusId = o.statusId
       left join ReportsData..ASUsers u
	          on u.UserChar30=o.checkOutUser
where o.checkoutdate between @StartDate and @EndDate 
and o.statusId in (2, 5, 4) --pending, unpaid, cancelled
order by o.cartId
