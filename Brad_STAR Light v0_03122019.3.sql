-- get sections to work now, fix it using integers for averages

declare 
	@date date
	,@fiscal date
	,@loc varchar(5)

set @date = '3/1/2019' -- not included
set @fiscal = cast('07-01-' + cast((datepart(yyyy,@date) - case when datepart(mm,@date) < 7 then 1 else 0 end) as varchar(4)) as date)
set @loc = '00049'

/*** Store Counts ***/

/* 
declare 
	@date date
	,@fiscal date

set @date = '12/1/2015'
set @fiscal = cast('07-01-' + cast((datepart(yyyy,@date) - case when datepart(mm,@date) < 7 then 1 else 0 end) as varchar(4)) as date)

-- drop table #stores
*/
declare @i int

set @i = 0

create table #stores ([Date] date, [StoreCount] numeric(8,3))

while @i < 24
begin
	insert into #stores
	select
		dateadd(mm,@i,dateadd(yy,-2,@date))
		,count(*)
	from
		ReportsView..StoreLocationMaster slm
	where
		slm.StoreType = 'S'
		and slm.OpenDate < dateadd(mm,@i,dateadd(yy,-2,@date))
		and (slm.ClosedDate is null or slm.ClosedDate >= dateadd(mm,@i,dateadd(yy,-2,@date)))
	set @i = @i + 1
end

/*** Costs ***/

/*
declare 
	@date date
	,@fiscal date
	,@loc varchar(5)

set @date = '12/1/2015'
set @fiscal = cast('07-01-' + cast((datepart(yyyy,@date) - case when datepart(mm,@date) < 7 then 1 else 0 end) as varchar(4)) as date)
set @loc = '00049'

-- drop table #costs
*/

select
	sr.LocationNo [LocationNo]
	,cast(cast(datepart(mm,sr.ProcessDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,sr.ProcessDate) as varchar(4)) as date) [DatePurchased]
	,cast('New' as varchar(5)) [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,isnull(ltrim(rtrim(pm.ProductType)),'Other') [ProductType]
	,isnull(dss.StandardSection,'Other') [Section]
	,sum(pm.Cost * sr.Qty) [Costs]
	,sum(sr.Qty) [QtyPurchased]
into #costs
from
	ReportsView..vw_StoreReceiving sr
	inner join ReportsView..StoreLocationMaster slm on
		sr.LocationNo = slm.LocationNo
		and slm.StoreType = 'S'
	inner join ReportsData..ProductMaster pm with (nolock) on
		sr.ItemCode = pm.ItemCode
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(pm.ProductType)) = ptg.ProdType
	left outer join ReportsView..vw_DistributionStandardSections dss on
		pm.SectionCode = dss.DistributionSection
where
	sr.ProcessDate >= dateadd(yy,-2,@date)
	and sr.ProcessDate < @date
	and sr.ShipmentType in ('W', 'R')
--	and sr.LocationNo = @loc
group by
	sr.LocationNo
	,cast(cast(datepart(mm,sr.ProcessDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,sr.ProcessDate) as varchar(4)) as date) 
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(pm.ProductType)),'Other')
	,isnull(dss.StandardSection,'Other') 
order by
	sr.LocationNo
	,cast(cast(datepart(mm,sr.ProcessDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,sr.ProcessDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(pm.ProductType)),'Other')
	,isnull(dss.StandardSection,'Other') 

/*
declare 
	@date date
	,@fiscal date
	,@loc varchar(5)

set @date = '1/1/2016'
set @fiscal = cast('07-01-' + cast((datepart(yyyy,@date) - case when datepart(mm,@date) < 7 then 1 else 0 end) as varchar(4)) as date)
set @loc = '00049'

-- drop table #usedcosts
*/

select
	bd.LocationNo [LocationNo]
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date) [DatePurchased]
	,'Used' [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,isnull(ltrim(rtrim(bd.BuyType)),'Other') [ProductType]
	,'All' [Section]
	,sum(bd.LineOffer) [Costs]
	,sum(bd.Quantity) [QtyPurchased]
into #usedcosts
from
	ReportsView..vw_BuyDetail bd
	left outer join ReportsView.dbo.vw_NewBuySystemData nbs on 
		bd.LocatioNno = nbs.Locationno
		and bd.BuyXactionID = nbs.BuyBinNo
		and bd.LineNumber = nbs.ItemLineNo
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(bd.BuyType)) = ptg.ProdType
where 
	bd.EndDate >= dateadd(yy,-2,@date)
	and bd.EndDate < @date
	and bd.Status = 'A' 
	and (nbs.StatusCode is null or nbs.StatusCode = 1)
--	and bd.LocationNo = @loc
group by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(bd.BuyType)),'Other')
order by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(bd.BuyType)),'Other')

insert into #usedcosts
select
	bd.LocationNo [LocationNo]
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date) [DatePurchased]
	,'Used' [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,sum(bd.LineOffer) [Costs]
	,sum(bd.Quantity) [QtyPurchased]
from
	ReportsView..vw_BuyDetail bd
	left outer join ReportsView.dbo.vw_NewBuySystemData nbs on 
		bd.LocatioNno = nbs.Locationno
		and bd.BuyXactionID = nbs.BuyBinNo
		and bd.LineNumber = nbs.ItemLineNo
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(bd.BuyType)) = ptg.ProdType
where 
	bd.EndDate >= dateadd(yy,-2,@date)
	and bd.EndDate < @date
	and bd.Status = 'A' 
	and (nbs.StatusCode is null or nbs.StatusCode = 1)
--	and bd.LocationNo = @loc
group by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
order by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')

insert into #usedcosts
select
	bd.LocationNo [LocationNo]
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date) [DatePurchased]
	,'Used' [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,sum(bd.LineOffer) [Costs]
	,sum(bd.Quantity) [QtyPurchased]
from
	ReportsView..vw_BuyDetail bd
	left outer join ReportsView.dbo.vw_NewBuySystemData nbs on 
		bd.LocatioNno = nbs.Locationno
		and bd.BuyXactionID = nbs.BuyBinNo
		and bd.LineNumber = nbs.ItemLineNo
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(bd.BuyType)) = ptg.ProdType
where 
	bd.EndDate >= dateadd(yy,-2,@date)
	and bd.EndDate < @date
	and bd.Status = 'A' 
	and (nbs.StatusCode is null or nbs.StatusCode = 1)
--	and bd.LocationNo = @loc
group by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
order by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)

insert into #usedcosts
select
	bd.LocationNo [LocationNo]
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date) [DatePurchased]
	,'All' [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,sum(bd.LineOffer) [Costs]
	,sum(bd.Quantity) [QtyPurchased]
from
	ReportsView..vw_BuyDetail bd
	left outer join ReportsView.dbo.vw_NewBuySystemData nbs on 
		bd.LocatioNno = nbs.Locationno
		and bd.BuyXactionID = nbs.BuyBinNo
		and bd.LineNumber = nbs.ItemLineNo
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(bd.BuyType)) = ptg.ProdType
where 
	bd.EndDate >= dateadd(yy,-2,@date)
	and bd.EndDate < @date
	and bd.Status = 'A' 
	and (nbs.StatusCode is null or nbs.StatusCode = 1)
--	and bd.LocationNo = @loc
group by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
order by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)


-- Buys by Type
select
	bd.LocationNo [LocationNo]
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date) [DatePurchased]
	,'Used' [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,isnull(ltrim(rtrim(bd.BuyType)),'Other') [ProductType]
	,'All' [Section]
	,count(distinct bd.BuyXactionID) [Buys]
into #buys
from
	ReportsView..vw_BuyDetail bd
	left outer join ReportsView.dbo.vw_NewBuySystemData nbs on 
		bd.LocatioNno = nbs.Locationno
		and bd.BuyXactionID = nbs.BuyBinNo
		and bd.LineNumber = nbs.ItemLineNo
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(bd.BuyType)) = ptg.ProdType
where 
	bd.EndDate >= dateadd(yy,-2,@date)
	and bd.EndDate < @date
	and bd.Status = 'A' 
	and (nbs.StatusCode is null or nbs.StatusCode = 1)
--	and bd.LocationNo = @loc
group by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(bd.BuyType)),'Other')
order by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(bd.BuyType)),'Other')

-- Buys by Group
insert into #buys
select
	bd.LocationNo [LocationNo]
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date) [DatePurchased]
	,'Used' [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,count(distinct bd.BuyXactionID) [Buys]
from
	ReportsView..vw_BuyDetail bd
	left outer join ReportsView.dbo.vw_NewBuySystemData nbs on 
		bd.LocatioNno = nbs.Locationno
		and bd.BuyXactionID = nbs.BuyBinNo
		and bd.LineNumber = nbs.ItemLineNo
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(bd.BuyType)) = ptg.ProdType
where 
	bd.EndDate >= dateadd(yy,-2,@date)
	and bd.EndDate < @date
	and bd.Status = 'A' 
	and (nbs.StatusCode is null or nbs.StatusCode = 1)
--	and bd.LocationNo = @loc
group by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
order by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')

-- Buys by Class
insert into #buys
select
	bd.LocationNo [LocationNo]
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date) [DatePurchased]
	,'Used' [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,count(distinct bd.BuyXactionID) [Buys]
from
	ReportsView..vw_BuyDetail bd
	left outer join ReportsView.dbo.vw_NewBuySystemData nbs on 
		bd.LocatioNno = nbs.Locationno
		and bd.BuyXactionID = nbs.BuyBinNo
		and bd.LineNumber = nbs.ItemLineNo
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(bd.BuyType)) = ptg.ProdType
where 
	bd.EndDate >= dateadd(yy,-2,@date)
	and bd.EndDate < @date
	and bd.Status = 'A' 
	and (nbs.StatusCode is null or nbs.StatusCode = 1)
--	and bd.LocationNo = @loc
group by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
order by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)

-- Buys by All
insert into #buys
select
	bd.LocationNo [LocationNo]
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date) [DatePurchased]
	,'All' [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,count(distinct bd.BuyXactionID) [Buys]
from
	ReportsView..vw_BuyDetail bd
	left outer join ReportsView.dbo.vw_NewBuySystemData nbs on 
		bd.LocatioNno = nbs.Locationno
		and bd.BuyXactionID = nbs.BuyBinNo
		and bd.LineNumber = nbs.ItemLineNo
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(bd.BuyType)) = ptg.ProdType
where 
	bd.EndDate >= dateadd(yy,-2,@date)
	and bd.EndDate < @date
	and bd.Status = 'A' 
	and (nbs.StatusCode is null or nbs.StatusCode = 1)
--	and bd.LocationNo = @loc
group by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)
order by
	bd.LocationNo
	,cast(cast(datepart(mm,bd.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bd.EndDate) as varchar(4)) as date)

/**** Sales ***/
/*
declare 
	@date date
	,@fiscal date

set @date = '12/1/2015'
set @fiscal = cast('07-01-' + cast((datepart(yyyy,@date) - case when datepart(mm,@date) < 7 then 1 else 0 end) as varchar(4)) as date)

-- drop table #sales
*/

select
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date) [DateSold]
	,isnull(bs.ProductClass,'Other') [ProductClass]
	,isnull(bs.ProductGroup,'Other') [ProductGroup]
	,isnull(ltrim(rtrim(bs.ProductType)),'Other') [ProductType]
	,isnull(bs.StandardSection,'Other') [Section]
	,sum(bs.ExtendedAmt) [Sales]
	,sum(case when bs.IsReturn = 'N' then bs.Qty else 0 end) [QtySold]
	,sum(case when bs.DiscountPct = '0' and bs.ProductType <> 'NOST' and (abs(bs.ExtendedAmt) <= 1 or abs(bs.ExtendedAmt) in (2,3,4,5,6,7,8,9,10)) then bs.ExtendedAmt else 0 end) [ClearSales]
	,sum(case when bs.DiscountPct = '0' and bs.ProductType <> 'NOST' and (abs(bs.ExtendedAmt) <= 1 or abs(bs.ExtendedAmt) in (2,3,4,5,6,7,8,9,10)) then bs.Qty else 0 end) [ClearQtySold]
	,sum(case when bs.DiscountPct = '0' and (bs.DiscountPct > 0 or abs(bs.ExtendedAmt) < bs.Price) and (abs(bs.ExtendedAmt) > 1 and abs(bs.ExtendedAmt) not in (2,3,4,5,6,7,8,9,10)) then bs.ExtendedAmt else 0 end) [MDSales]
	,sum(case when bs.DiscountPct = '0' and (bs.DiscountPct > 0 or abs(bs.ExtendedAmt) < bs.Price) and (abs(bs.ExtendedAmt) > 1 and abs(bs.ExtendedAmt) not in (2,3,4,5,6,7,8,9,10)) then bs.Qty else 0 end) [MDQtySold]
	,sum(case when bs.DiscountPct > '0' then bs.ExtendedAmt else 0 end) [DiscountSales]
	,sum(case when bs.DiscountPct > '0' then bs.Qty else 0 end) [DiscountQtySold]
	,sum(case when bs.DiscountPct = '0' and abs(bs.ExtendedAmt) > 1 and (bs.ProductType = 'NOST' or bs.ExtendedAmt not in (2,3,4,5,6,7,8,9,10)) then bs.ExtendedAmt else 0 end) [OriginalSales]
	,sum(case when bs.DiscountPct = '0' and abs(bs.ExtendedAmt) > 1 and (bs.ProductType = 'NOST' or bs.ExtendedAmt not in (2,3,4,5,6,7,8,9,10)) then bs.Qty else 0 end) [OriginalQtySold]
	,sum(case when bs.DiscountCode = 'EMPLOYEE  ' then bs.ExtendedAmt else 0 end) [EmployeeSales]
	,sum(case when bs.DiscountCode = 'EMPLOYEE  ' then bs.Qty else 0 end) [EmployeeQtySold]
into #sales
from
	ReportsView..SalesDetails bs
where
	bs.EndDate >= dateadd(yy,-2,@date)
	and bs.EndDate < @date
--	and bs.LocationNo = @loc
group by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
	,isnull(bs.ProductGroup,'Other')
	,isnull(ltrim(rtrim(bs.ProductType)),'Other')
	,isnull(bs.StandardSection,'Other')
order by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
	,isnull(bs.ProductGroup,'Other')
	,isnull(ltrim(rtrim(bs.ProductType)),'Other')
	,isnull(bs.StandardSection,'Other')

-- Sales Trans by Type
/*
declare 
	@date date
	,@fiscal date

set @date = '1/1/2016'
set @fiscal = cast('07-01-' + cast((datepart(yyyy,@date) - case when datepart(mm,@date) < 7 then 1 else 0 end) as varchar(4)) as date)
*/
-- drop table #salestrans
select
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date) [DateSold]
	,isnull(bs.ProductClass,'Other') [ProductClass]
	,isnull(bs.ProductGroup,'Other') [ProductGroup]
	,isnull(ltrim(rtrim(bs.ProductType)),'Other') [ProductType]
	,cast('All' as varchar(30)) [Section]
	,count(distinct bs.SalesXActionID) [Trans]
into #salestrans
from
	ReportsView..SalesDetails bs
where
	bs.EndDate >= dateadd(yy,-2,@date)
	and bs.EndDate < @date
group by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
	,isnull(bs.ProductGroup,'Other')
	,isnull(ltrim(rtrim(bs.ProductType)),'Other')
order by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
	,isnull(bs.ProductGroup,'Other')
	,isnull(ltrim(rtrim(bs.ProductType)),'Other')
	
-- Sales Trans by Group
insert into #salestrans
select
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date) [DateSold]
	,isnull(bs.ProductClass,'Other') [ProductClass]
	,isnull(bs.ProductGroup,'Other') [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,count(distinct bs.SalesXActionID) [Trans]
from
	ReportsView..SalesDetails bs
where
	bs.EndDate >= dateadd(yy,-2,@date)
	and bs.EndDate < @date
group by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
	,isnull(bs.ProductGroup,'Other')
order by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
	,isnull(bs.ProductGroup,'Other')

-- Sales Trans by Class
insert into #salestrans
select
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date) [DateSold]
	,isnull(bs.ProductClass,'Other') [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,count(distinct bs.SalesXActionID) [Trans]
from
	ReportsView..SalesDetails bs
where
	bs.EndDate >= dateadd(yy,-2,@date)
	and bs.EndDate < @date
group by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
order by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')

-- Sales Trans by Section
insert into #salestrans
select
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date) [DateSold]
	,isnull(bs.ProductClass,'Other') [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,isnull(bs.StandardSection,'Other') [Section]
	,count(distinct bs.SalesXActionID) [Trans]
from
	ReportsView..SalesDetails bs
where
	bs.EndDate >= dateadd(yy,-2,@date)
	and bs.EndDate < @date
group by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
	,isnull(bs.StandardSection,'Other')
order by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	,isnull(bs.ProductClass,'Other')
	,isnull(bs.StandardSection,'Other')

-- Sales Trans by All
insert into #salestrans
select
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date) [DateSold]
	,'All' [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,count(distinct bs.SalesXActionID) [Trans]
from
	ReportsView..SalesDetails bs
where
	bs.EndDate >= dateadd(yy,-2,@date)
	and bs.EndDate < @date
group by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
order by
	bs.LocationNo
	,cast(cast(datepart(mm,bs.EndDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,bs.EndDate) as varchar(4)) as date)
	

/*** Online Sales ***/
/*
declare 
	@date date
	,@fiscal date
	,@loc varchar(5)

set @date = '12/1/2015'
set @fiscal = cast('07-01-' + cast((datepart(yyyy,@date) - case when datepart(mm,@date) < 7 then 1 else 0 end) as varchar(4)) as date)
set @loc = '00049'

-- drop table #onlinesales
-- drop table #onlinesales_sec
*/

select
	slm.LocationNo [LocationNo]
	,cast(cast(datepart(mm,mo.ShipDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,mo.ShipDate) as varchar(4)) as date) [DateSold]
	,'Used' [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,isnull(ltrim(rtrim(spi.ProductType)),'Other') [ProductType]
	,isnull(sss.StandardSection,'Other') [Section]
	,sum(mo.Price - mo.RefundAmount) [Sales]
	,sum(mo.RefundAmount) [Refunds]
	,sum(mo.ShippingFee) [Credits]
	,sum(mo.ShippedQuantity) [QtySold]
into #onlinesales
from
	ReportsView..vw_MonsoonOrders mo
	inner join ReportsView..StoreLocationMaster slm on
		'00'+mo.LocationNo = slm.LocationNo
		and slm.StoreType = 'S'
	inner join ReportsView..vw_SipsProductInventoryFull spi with (nolock) on
		replace(mo.SKU,'U','') = spi.ItemCode
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(spi.ProductType)) = ptg.ProdType
	left outer join ReportsView..vw_SipsStandardSections sss on
		spi.SubjectKey = sss.SipsSubjectID
where
	left(mo.SKU,1) = 'U'
	and mo.ShipDate >= dateadd(yy,-2,@date)
	and mo.ShipDate < @date
	and mo.[Status] = 'Shipped'
	and mo.Location = 'At Location Sales'
--	and slm.LocationNo = @loc
group by
	slm.LocationNo
	,cast(cast(datepart(mm,mo.ShipDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,mo.ShipDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(spi.ProductType)),'Other')
	,isnull(sss.StandardSection,'Other')
order by
	slm.LocationNo
	,cast(cast(datepart(mm,mo.ShipDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,mo.ShipDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(spi.ProductType)),'Other')
	,isnull(sss.StandardSection,'Other')

insert into #onlinesales
select
	slm.LocationNo [LocationNo]
	,cast(cast(datepart(mm,mo.ShipDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,mo.ShipDate) as varchar(4)) as date) [DateSold]
	,cast('New' as varchar(5)) [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,isnull(ltrim(rtrim(pm.ProductType)),'Other') [ProductType]
	,isnull(dss.StandardSection,'Other') [Section]
	,sum(mo.Price - mo.RefundAmount) [Sales]
	,sum(mo.RefundAmount) [Refunds]
	,sum(mo.ShippingFee) [Credits]
	,sum(mo.ShippedQuantity) [QtySold]
from
	ReportsView..vw_MonsoonOrders mo
	inner join ReportsView..StoreLocationMaster slm on
		'00'+mo.LocationNo = slm.LocationNo
		and slm.StoreType = 'S'
	inner join ReportsData..ProductMaster pm with (nolock) on
		replace(mo.SKU,'D','') = pm.ItemCode
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(pm.ProductType)) = ptg.ProdType
	left outer join ReportsView..vw_DistributionStandardSections dss on
		pm.SectionCode = dss.DistributionSection
where
	left(mo.SKU,1) = 'D'
	and mo.ShipDate >= dateadd(yy,-2,@date)
	and mo.ShipDate < @date
	and mo.[Status] = 'Shipped'
	and mo.Location = 'At Location Sales'
--	and slm.LocationNo = @loc
group by
	slm.LocationNo
	,cast(cast(datepart(mm,mo.ShipDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,mo.ShipDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(pm.ProductType)),'Other')
	,isnull(dss.StandardSection,'Other')
order by
	slm.LocationNo
	,cast(cast(datepart(mm,mo.ShipDate) as varchar(2)) + '-1-' + cast(datepart(yyyy,mo.ShipDate) as varchar(4)) as date)
	,isnull(ptg.PTypeGroup,'Other')
	,isnull(ltrim(rtrim(pm.ProductType)),'Other')
	,isnull(dss.StandardSection,'Other')

/*** Transfers ***/
/*
declare 
	@date date
	,@fiscal date
	,@loc varchar(5)

set @date = '3/1/2019'
set @fiscal = cast('07-01-' + cast((datepart(yyyy,@date) - case when datepart(mm,@date) < 7 then 1 else 0 end) as varchar(4)) as date)
set @loc = '00049'

/*
drop table #xfertrash
drop table #xferin
drop table #xferout
*/
*/





select
	slm.LocationNo [LocationNo]
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date) [DateXfer]
	,isnull(ptg.NewUsed,'Other') [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,ltrim(rtrim(std.ProductType)) [ProductType]
	,isnull(isnull(dss.standardSection,sss.StandardSection),'Other') [Section]
	,sum(isnull(std.DipsCost,abc.Cost) * std.Quantity) [CostsTrash]
	,sum(std.Quantity) [QtyTrash]
into #xfertrash
from
	ReportsData..SipsTransferBinHeader sth
	inner join ReportsView..StoreLocationMaster slm on
		sth.LocationNo = slm.LocationNo
		and slm.StoreType = 'S'
	inner join ReportsData..Locations l on
		sth.ToLocationNo = l.LocationNo
		and l.Status = 'A'
		and l.LocationType = 'T'
		and l.LocationNo <> '00300'
		and l.LocationNo not in ('00275','00290')
	inner join ReportsData..SipsTransferBinDetail std on
		sth.TransferBinNo = std.TransferBinNo
	left outer join ReportsData..AvgBookCost_v2 abc on
		std.AvgBookCostID = abc.AvgBookCostID
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(std.ProductType)) = ptg.ProdType
	left outer join ReportsView..vw_SipsProductInventoryFull spi with (nolock) on
		std.SipsItemCode = spi.ItemCode
	left outer join ReportsData..ProductMaster pm with (nolock) on
		std.DipsItemCode = pm.ItemCode
	left outer join ReportsView..vw_SipsStandardSections sss on
		spi.SubjectKey = sss.SipsSubjectID
	left outer join ReportsView..vw_DistributionStandardSections dss on
		pm.SectionCode = dss.DistributionSection
where
	sth.UpdateTime >= dateadd(yy,-2,@date)
	and sth.UpdateTime < @date
	and sth.StatusCode = '3'
	and std.DipsCost < '500'
	and not(std.DipsCost > '75' and (DipsCost / std.Quantity) < '50') 
	and std.Quantity < '11000'
--	and slm.LocationNo = @loc
group by
	slm.LocationNo
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date)
	,isnull(ptg.NewUsed,'Other')
	,isnull(ptg.PTypeGroup,'Other')
	,ltrim(rtrim(std.ProductType))
	,isnull(isnull(dss.StandardSection,sss.StandardSection),'Other')
order by
	slm.LocationNo
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date)
	,isnull(ptg.NewUsed,'Other')
	,isnull(ptg.PTypeGroup,'Other')
	,ltrim(rtrim(std.ProductType))
	,isnull(isnull(dss.StandardSection,sss.StandardSection),'Other')

select
	slm.LocationNo [LocationNo]
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date) [DateXfer]
	,isnull(ptg.NewUsed,'Other') [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,ltrim(rtrim(std.ProductType)) [ProductType]
	,isnull(isnull(dss.StandardSection,sss.StandardSection),'Other') [Section]
	,sum(isnull(std.DipsCost,abc.Cost) * std.Quantity) [CostsOut]
	,sum(std.Quantity) [QtyOut]
into #xferout
from
	ReportsData..SipsTransferBinHeader sth
	inner join ReportsView..StoreLocationMaster slm on
		sth.LocationNo = slm.LocationNo
		and slm.StoreType = 'S'
	inner join ReportsData..Locations l on
		sth.ToLocationNo = l.LocationNo
		and l.Status = 'A'
		and ((l.LocationType = 'I' and l.LocationNo not in ('00884','00275','00290'))
			or (l.LocationType = 'S' or l.LocationNo = '00300'))
	inner join ReportsData..SipsTransferBinDetail std on
		sth.TransferBinNo = std.TransferBinNo
	left outer join ReportsData..AvgBookCost_v2 abc on
		std.AvgBookCostID = abc.AvgBookCostID
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(std.ProductType)) = ptg.ProdType
	left outer join ReportsData..ProductMaster pm with (nolock) on
		std.DipsItemCode = pm.ItemCode
	left outer join ReportsView..vw_SipsProductInventoryFull spi with (nolock) on
		std.SipsItemCode = spi.ItemCode
	left outer join ReportsView..vw_DistributionStandardSections dss on 
		dss.DistributionSection = pm.SectionCode
	left outer join ReportsView..vw_SipsStandardSections sss on 
		sss.SipsSubjectID = spi.SubjectKey
where
	sth.UpdateTime >= dateadd(yy,-2,@date)
	and sth.UpdateTime < @date
	and sth.StatusCode = '3'
	and std.DipsCost < '500'
	and not(std.DipsCost > '75' and (DipsCost / std.Quantity) < '50') 
	and std.Quantity < '11000'
--	and slm.LocationNo = @loc
group by
	slm.LocationNo
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date)
	,isnull(ptg.NewUsed,'Other')
	,isnull(ptg.PTypeGroup,'Other')
	,ltrim(rtrim(std.ProductType))
	,isnull(isnull(dss.StandardSection,sss.StandardSection),'Other')
order by
	slm.LocationNo
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date)
	,isnull(ptg.NewUsed,'Other')
	,isnull(ptg.PTypeGroup,'Other')
	,ltrim(rtrim(std.ProductType))
	,isnull(isnull(dss.StandardSection,sss.StandardSection),'Other')

select
	slm.LocationNo [LocationNo]
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date) [DateXfer]
	,isnull(ptg.NewUsed,'Other') [ProductClass]
	,isnull(ptg.PTypeGroup,'Other') [ProductGroup]
	,ltrim(rtrim(std.ProductType)) [ProductType]
	,isnull(isnull(dss.StandardSection,sss.StandardSection),'Other') [Section]
	,sum(isnull(std.DipsCost,abc.Cost) * std.Quantity) [CostsIn]
	,sum(std.Quantity) [QtyIn]
into #xferin
from
	ReportsData..SipsTransferBinHeader sth
	inner join ReportsView..StoreLocationMaster slm on
		sth.ToLocationNo = slm.LocationNo
		and slm.StoreType = 'S'
	inner join ReportsData..Locations l on
		sth.LocationNo = l.LocationNo
		and l.Status = 'A'
		and l.LocationType = 'S'
	inner join ReportsData..SipsTransferBinDetail std on
		sth.TransferBinNo = std.TransferBinNo
	left outer join ReportsData..AvgBookCost_v2 abc on
		std.AvgBookCostID = abc.AvgBookCostID
	left outer join ReportsView..ProductTypeGroup_Ext ptg on
		ltrim(rtrim(std.ProductType)) = ptg.ProdType
	left outer join ReportsData..ProductMaster pm with (nolock) on
		std.DipsItemCode = pm.ItemCode
	left outer join ReportsView..vw_SipsProductInventoryFull spi with (nolock) on
		std.SipsItemCode = spi.ItemCode
	left outer join ReportsView..vw_DistributionStandardSections dss on 
		dss.DistributionSection = pm.SectionCode
	left outer join ReportsView..vw_SipsStandardSections sss on 
		sss.SipsSubjectID = spi.SubjectKey
where
	sth.UpdateTime >= dateadd(yy,-2,@date)
	and sth.UpdateTime < @date
	and sth.StatusCode = '3'
	and std.DipsCost < '500'
	and not(std.DipsCost > '75' and (DipsCost / std.Quantity) < '50') 
	and std.Quantity < '11000'
--	and slm.LocationNo = @loc
group by
	slm.LocationNo
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date)
	,isnull(ptg.NewUsed,'Other')
	,isnull(ptg.PTypeGroup,'Other')
	,ltrim(rtrim(std.ProductType))
	,isnull(isnull(dss.StandardSection,sss.StandardSection),'Other')
order by
	slm.LocationNo
	,cast(cast(datepart(mm,sth.UpdateTime) as varchar(2)) + '-1-' + cast(datepart(yyyy,sth.UpdateTime) as varchar(4)) as date)
	,isnull(ptg.NewUsed,'Other')
	,isnull(ptg.PTypeGroup,'Other')
	,ltrim(rtrim(std.ProductType))
	,isnull(isnull(dss.StandardSection,sss.StandardSection),'Other')


/** Consolidate ***/
/*
drop table #consolidate
drop table #final
drop table #final_product
drop table #final_section
*/

select
	isnull(s.LocationNo,c.LocationNo) [LocationNo]
	,isnull(s.DateSold,c.DatePurchased) [DateSold]
	,isnull(s.ProductClass,c.ProductClass) [ProductClass]
	,isnull(s.ProductGroup,c.ProductGroup) [ProductGroup]
	,isnull(s.ProductType,c.ProductType) [ProductType]
	,isnull(s.Section,c.Section) [Section]
	,isnull(s.Sales,0) [Sales]
	,isnull(s.QtySold,0) [QtySold]
	,isnull(s.ClearSales,0) [ClearSales]
	,isnull(s.ClearQtySold,0) [ClearQtySold]
	,isnull(s.MDSales,0) [MDSales]
	,isnull(s.MDQtySold,0) [MDQtySold]
	,isnull(s.DiscountSales,0) [DiscountSales]
	,isnull(s.DiscountQtySold,0) [DiscountQtySold]
	,isnull(s.OriginalSales,0) [OriginalSales]
	,isnull(s.OriginalQtySold,0) [OriginalQtySold]
	,isnull(s.EmployeeSales,0) [EmployeeSales]
	,isnull(s.EmployeeQtySold,0) [EmployeeQtySold]
	,isnull(c.Costs,0) [Costs]
	,isnull(c.QtyPurchased,0) [QtyPurchased]
	,s.Sales - isnull(c.Costs,0)  [GrossProfit]
	,isnull(o.Sales,0) [iSales]
	,isnull(o.QtySold,0) [QtyiSales]
	,isnull(xo.CostsOut,0) [CostsOut]
	,isnull(xo.QtyOut,0) [QtyOut]
	,isnull(xi.CostsIn,0) [CostsIn]
	,isnull(xi.QtyIn,0) [QtyIn]
	,isnull(xt.CostsTrash,0) [CostsTrash]
	,isnull(xt.QtyTrash,0) [QtyTrash]
	,s.Sales + isnull(o.Sales,0) [TotalSales]
	,isnull(c.Costs,0) + isnull(xi.CostsIn,0) - isnull(xo.CostsOut,0) [TotalCosts]
	,s.QtySold + isnull(o.QtySold,0) [TotalQtySold]
	,isnull(c.QtyPurchased,0) + isnull(xi.QtyIn,0) - isnull(xo.QtyOut,0) [TotalQtyPurchased]
into #consolidate
from
	#sales s
	full outer join #costs c on
		s.DateSold = c.DatePurchased
		and s.LocationNo = c.LocationNo
		and s.ProductClass = c.ProductClass
		and s.ProductGroup = c.ProductGroup
		and s.ProductType = c.ProductType
		and s.Section = c.Section
	left outer join #onlinesales o on
		s.DateSold = o.DateSold
		and s.LocationNo = o.LocationNo
		and s.ProductClass = o.ProductClass
		and s.ProductGroup = o.ProductGroup
		and s.ProductType = o.ProductType
		and s.Section = o.Section
	left outer join #xferout xo on
		s.DateSold = xo.DateXfer
		and s.LocationNo = xo.LocationNo
		and s.ProductClass = xo.ProductClass
		and s.ProductGroup = xo.ProductGroup
		and s.ProductType = xo.ProductType
		and s.Section = xo.Section
	left outer join #xferin xi on
		s.DateSold = xi.DateXfer
		and s.LocationNo = xi.LocationNo
		and s.ProductClass = xi.ProductClass
		and s.ProductGroup = xi.ProductGroup
		and s.ProductType = xi.ProductType
		and s.Section = xi.Section
	left outer join #xfertrash xt on
		s.DateSold = xt.DateXfer
		and s.LocationNo = xt.LocationNo
		and s.ProductClass = xt.ProductClass
		and s.ProductGroup = xt.ProductGroup
		and s.ProductType = xt.ProductType
		and s.Section = xt.Section
order by
	s.LocationNo
	,s.DateSold
	,s.ProductClass
	,s.ProductGroup
	,s.ProductType

select * into #final from #consolidate where 0 = 1

insert into #final
select
	s.LocationNo [LocationNo]
	,s.DateSold [DateSold]
	,'All' [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,sum(s.Sales) [Sales]
	,sum(s.QtySold) [QtySold]
	,sum(s.ClearSales) [ClearSales]
	,sum(s.ClearQtySold) [ClearQtySold]
	,sum(s.MDSales) [MDSales]
	,sum(s.MDQtySold) [MDQtySold]
	,sum(s.DiscountSales) [DiscountSales]
	,sum(s.DiscountQtySold) [DiscountQtySold]
	,sum(s.OriginalSales) [OriginalSales]
	,sum(s.OriginalQtySold) [OriginalQtySold]
	,sum(s.EmployeeSales) [EmployeeSales]
	,sum(s.EmployeeQtySold) [EmployeeQtySold]
	,sum(s.Costs) [Costs]
	,sum(s.QtyPurchased) [QtyPurchased]
	,sum(s.GrossProfit) [GrossProfit]
	,sum(s.iSales) [iSales]
	,sum(s.QtyiSales) [QtyiSales]
	,sum(s.CostsOut) [CostsOut]
	,sum(s.QtyOut) [QtyOut]
	,sum(s.CostsIn) [CostsIn]
	,sum(s.QtyIn) [QtyIn]
	,sum(s.CostsTrash) [CostsTrash]
	,sum(s.QtyTrash) [QtyTrash]
	,sum(s.TotalSales) [TotalSales]
	,sum(s.TotalCosts) [TotalCosts]
	,sum(s.TotalQtySold) [TotalQtySold]
	,sum(s.TotalQtyPurchased) [TotalQtyPurchased]
from
	#consolidate s
group by
	s.LocationNo
	,s.DateSold
order by
	s.LocationNo
	,s.DateSold

insert into #final
select
	s.LocationNo [LocationNo]
	,s.DateSold [DateSold]
	,s.ProductClass [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,sum(s.Sales) [Sales]
	,sum(s.QtySold) [QtySold]
	,sum(s.ClearSales) [ClearSales]
	,sum(s.ClearQtySold) [ClearQtySold]
	,sum(s.MDSales) [MDSales]
	,sum(s.MDQtySold) [MDQtySold]
	,sum(s.DiscountSales) [DiscountSales]
	,sum(s.DiscountQtySold) [DiscountQtySold]
	,sum(s.OriginalSales) [OriginalSales]
	,sum(s.OriginalQtySold) [OriginalQtySold]
	,sum(s.EmployeeSales) [EmployeeSales]
	,sum(s.EmployeeQtySold) [EmployeeQtySold]
	,sum(s.Costs) [Costs]
	,sum(s.QtyPurchased) [QtyPurchased]
	,sum(s.GrossProfit) [GrossProfit]
	,sum(s.iSales) [iSales]
	,sum(s.QtyiSales) [QtyiSales]
	,sum(s.CostsOut) [CostsOut]
	,sum(s.QtyOut) [QtyOut]
	,sum(s.CostsIn) [CostsIn]
	,sum(s.QtyIn) [QtyIn]
	,sum(s.CostsTrash) [CostsTrash]
	,sum(s.QtyTrash) [QtyTrash]
	,sum(s.TotalSales) [TotalSales]
	,sum(s.TotalCosts) [TotalCosts]
	,sum(s.TotalQtySold) [TotalQtySold]
	,sum(s.TotalQtyPurchased) [TotalQtyPurchased]
from
	#consolidate s
group by
	s.LocationNo
	,s.DateSold
	,s.ProductClass
order by
	s.LocationNo
	,s.DateSold
	,s.ProductClass

insert into #final
select
	s.LocationNo [LocationNo]
	,s.DateSold [DateSold]
	,s.ProductClass [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,s.Section [Section]
	,sum(s.Sales) [Sales]
	,sum(s.QtySold) [QtySold]
	,sum(s.ClearSales) [ClearSales]
	,sum(s.ClearQtySold) [ClearQtySold]
	,sum(s.MDSales) [MDSales]
	,sum(s.MDQtySold) [MDQtySold]
	,sum(s.DiscountSales) [DiscountSales]
	,sum(s.DiscountQtySold) [DiscountQtySold]
	,sum(s.OriginalSales) [OriginalSales]
	,sum(s.OriginalQtySold) [OriginalQtySold]
	,sum(s.EmployeeSales) [EmployeeSales]
	,sum(s.EmployeeQtySold) [EmployeeQtySold]
	,sum(s.Costs) [Costs]
	,sum(s.QtyPurchased) [QtyPurchased]
	,sum(s.GrossProfit) [GrossProfit]
	,sum(s.iSales) [iSales]
	,sum(s.QtyiSales) [QtyiSales]
	,sum(s.CostsOut) [CostsOut]
	,sum(s.QtyOut) [QtyOut]
	,sum(s.CostsIn) [CostsIn]
	,sum(s.QtyIn) [QtyIn]
	,sum(s.CostsTrash) [CostsTrash]
	,sum(s.QtyTrash) [QtyTrash]
	,sum(s.TotalSales) [TotalSales]
	,sum(s.TotalCosts) [TotalCosts]
	,sum(s.TotalQtySold) [TotalQtySold]
	,sum(s.TotalQtyPurchased) [TotalQtyPurchased]
from
	#consolidate s
where
	s.ProductGroup = 'Hardbacks'
group by
	s.LocationNo
	,s.DateSold
	,s.ProductClass
	,s.Section
order by
	s.LocationNo
	,s.DateSold
	,s.ProductClass
	,s.Section

insert into #final
select
	s.LocationNo [LocationNo]
	,s.DateSold [DateSold]
	,s.ProductClass [ProductClass]
	,s.ProductGroup [ProductGroup]
	,'All' [ProductType]
	,'All' [Section]
	,sum(s.Sales) [Sales]
	,sum(s.QtySold) [QtySold]
	,sum(s.ClearSales) [ClearSales]
	,sum(s.ClearQtySold) [ClearQtySold]
	,sum(s.MDSales) [MDSales]
	,sum(s.MDQtySold) [MDQtySold]
	,sum(s.DiscountSales) [DiscountSales]
	,sum(s.DiscountQtySold) [DiscountQtySold]
	,sum(s.OriginalSales) [OriginalSales]
	,sum(s.OriginalQtySold) [OriginalQtySold]
	,sum(s.EmployeeSales) [EmployeeSales]
	,sum(s.EmployeeQtySold) [EmployeeQtySold]
	,sum(s.Costs) [Costs]
	,sum(s.QtyPurchased) [QtyPurchased]
	,sum(s.GrossProfit) [GrossProfit]
	,sum(s.iSales) [iSales]
	,sum(s.QtyiSales) [QtyiSales]
	,sum(s.CostsOut) [CostsOut]
	,sum(s.QtyOut) [QtyOut]
	,sum(s.CostsIn) [CostsIn]
	,sum(s.QtyIn) [QtyIn]
	,sum(s.CostsTrash) [CostsTrash]
	,sum(s.QtyTrash) [QtyTrash]
	,sum(s.TotalSales) [TotalSales]
	,sum(s.TotalCosts) [TotalCosts]
	,sum(s.TotalQtySold) [TotalQtySold]
	,sum(s.TotalQtyPurchased) [TotalQtyPurchased]
from
	#consolidate s
group by
	s.LocationNo
	,s.DateSold
	,s.ProductClass
	,s.ProductGroup
order by
	s.LocationNo
	,s.DateSold
	,s.ProductClass
	,s.ProductGroup

insert into #final
select
	s.LocationNo [LocationNo]
	,s.DateSold [DateSold]
	,s.ProductClass [ProductClass]
	,s.ProductGroup [ProductGroup]
	,s.ProductType [ProductType]
	,'All' [Section]
	,sum(s.Sales) [Sales]
	,sum(s.QtySold) [QtySold]
	,sum(s.ClearSales) [ClearSales]
	,sum(s.ClearQtySold) [ClearQtySold]
	,sum(s.MDSales) [MDSales]
	,sum(s.MDQtySold) [MDQtySold]
	,sum(s.DiscountSales) [DiscountSales]
	,sum(s.DiscountQtySold) [DiscountQtySold]
	,sum(s.OriginalSales) [OriginalSales]
	,sum(s.OriginalQtySold) [OriginalQtySold]
	,sum(s.EmployeeSales) [EmployeeSales]
	,sum(s.EmployeeQtySold) [EmployeeQtySold]
	,sum(s.Costs) [Costs]
	,sum(s.QtyPurchased) [QtyPurchased]
	,sum(s.GrossProfit) [GrossProfit]
	,sum(s.iSales) [iSales]
	,sum(s.QtyiSales) [QtyiSales]
	,sum(s.CostsOut) [CostsOut]
	,sum(s.QtyOut) [QtyOut]
	,sum(s.CostsIn) [CostsIn]
	,sum(s.QtyIn) [QtyIn]
	,sum(s.CostsTrash) [CostsTrash]
	,sum(s.QtyTrash) [QtyTrash]
	,sum(s.TotalSales) [TotalSales]
	,sum(s.TotalCosts) [TotalCosts]
	,sum(s.TotalQtySold) [TotalQtySold]
	,sum(s.TotalQtyPurchased) [TotalQtyPurchased]
from
	#consolidate s
group by
	s.LocationNo
	,s.DateSold
	,s.ProductClass
	,s.ProductGroup
	,s.ProductType
order by
	s.LocationNo
	,s.DateSold
	,s.ProductClass
	,s.ProductGroup
	,s.ProductType

/*** add odd metrics to final ***/

-- drop table #final_product
select
	f.LocationNo
	,f.DateSold [Month]
	,f.ProductClass
	,f.ProductGroup
	,f.ProductType
	,'All' [Section]
	,f.Sales
	,f.QtySold
	,f.ClearSales
	,f.ClearQtySold
	,f.MDSales
	,f.MDQtySold
	,f.DiscountSales
	,f.DiscountQtySold
	,f.OriginalSales
	,f.OriginalQtySold
	,f.EmployeeSales
	,f.EmployeeQtySold
	,f.Costs + isnull(c.Costs,0) [Costs]
	,f.QtyPurchased + isnull(c.QtyPurchased,0) [QtyPurchased]
	,f.GrossProfit
	,f.iSales
	,f.QtyiSales
	,f.CostsOut
	,f.QtyOut
	,f.CostsIn
	,f.QtyIn
	,f.CostsTrash
	,f.QtyTrash
	,f.TotalSales
	,f.TotalCosts + isnull(c.Costs,0) [TotalCosts]
	,f.TotalQtySold
	,f.TotalQtyPurchased + isnull(c.QtyPurchased,0) [TotalQtyPurchased]
	,t.Trans [Transactions]
	,b.Buys [Buys]
into #final_product
from
	#final f
	left outer join #usedcosts c on
		f.DateSold = c.DatePurchased
		and f.LocationNo = c.LocationNo
		and f.ProductClass = c.ProductClass
		and f.ProductGroup = c.ProductGroup
		and f.ProductType = c.ProductType
		and f.Section = c.Section
	left outer join #buys b on
		f.DateSold = b.DatePurchased
		and f.LocationNo = b.LocationNo
		and f.ProductClass = b.ProductClass
		and f.ProductGroup = b.ProductGroup
		and f.ProductType = b.ProductType
		and f.Section = b.Section
	left outer join #salestrans t on
		f.DateSold = t.DateSold
		and f.LocationNo = t.LocationNo
		and f.ProductClass = t.ProductClass
		and f.ProductGroup = t.ProductGroup
		and f.ProductType = t.ProductType
		and f.Section = t.Section
where
	f.Section = 'All'
order by
	f.LocationNo
	,f.DateSold 
	,f.ProductClass
	,f.ProductGroup
	,f.ProductType

insert into #final_product
select
	'00000' [LocationNo]
	,f.[Month] [Month]
	,f.ProductClass
	,f.ProductGroup
	,f.ProductType
	,'All' [Section]
	,sum(f.Sales) / s.StoreCount
	,sum(f.QtySold) / s.StoreCount
	,sum(f.ClearSales) / s.StoreCount
	,sum(f.ClearQtySold) / s.StoreCount
	,sum(f.MDSales) / s.StoreCount
	,sum(f.MDQtySold) / s.StoreCount
	,sum(f.DiscountSales) / s.StoreCount
	,sum(f.DiscountQtySold) / s.StoreCount
	,sum(f.OriginalSales) / s.StoreCount
	,sum(f.OriginalQtySold) / s.StoreCount
	,sum(f.EmployeeSales) / s.StoreCount
	,sum(f.EmployeeQtySold) / s.StoreCount
	,sum(f.Costs) / s.StoreCount
	,sum(f.QtyPurchased) / s.StoreCount
	,sum(f.GrossProfit) / s.StoreCount
	,sum(f.iSales) / s.StoreCount
	,sum(f.QtyiSales) / s.StoreCount
	,sum(f.CostsOut) / s.StoreCount
	,sum(f.QtyOut) / s.StoreCount
	,sum(f.CostsIn) / s.StoreCount
	,sum(f.QtyIn) / s.StoreCount
	,sum(f.CostsTrash) / s.StoreCount
	,sum(f.QtyTrash) / s.StoreCount
	,sum(f.TotalSales) / s.StoreCount
	,sum(f.TotalCosts) / s.StoreCount
	,sum(f.TotalQtySold) / s.StoreCount
	,sum(f.TotalQtyPurchased) / s.StoreCount
	,sum(f.Transactions) / s.StoreCount
	,sum(f.Buys) / s.StoreCount
from
	#final_product f
	inner join #stores s on f.[Month] = s.[Date]
group by
	s.StoreCount
	,f.[Month]
	,f.ProductClass
	,f.ProductGroup
	,f.ProductType
order by
	s.StoreCount
	,f.[Month]
	,f.ProductClass
	,f.ProductGroup
	,f.ProductType





-- drop table #final_section
select
	f.LocationNo
	,f.DateSold [Month]
	,f.ProductClass [ProductClass]
	,'All' [ProductGroup]
	,'All' [ProductType]
	,f.Section [Section]
	,f.Sales
	,f.QtySold
	,f.ClearSales
	,f.ClearQtySold
	,f.MDSales
	,f.MDQtySold
	,f.DiscountSales
	,f.DiscountQtySold
	,f.OriginalSales
	,f.OriginalQtySold
	,f.EmployeeSales
	,f.EmployeeQtySold
	,f.Costs -- + isnull(c.Costs,0) [Costs]
	,f.QtyPurchased -- + isnull(c.QtyPurchased,0) [QtyPurchased]
	,f.GrossProfit
	,f.iSales
	,f.QtyiSales
	,f.CostsOut
	,f.QtyOut
	,f.CostsIn
	,f.QtyIn
	,f.CostsTrash
	,f.QtyTrash
	,f.TotalSales
	,f.TotalCosts -- + isnull(c.Costs,0) [TotalCosts]
	,f.TotalQtySold
	,f.TotalQtyPurchased -- + isnull(c.QtyPurchased,0) [TotalQtyPurchased]
	,t.Trans [Transactions]
	,'0' [Buys]
into #final_section
from
	#final f
/*
	left outer join #usedcosts c on
		f.DateSold = c.DatePurchased
		and f.LocationNo = c.LocationNo
		and f.ProductClass = c.ProductClass
		and c.ProductGroup = 'All'
		and c.ProductType = 'All'
		and f.Section = c.Section
	left outer join #buys b on
		f.DateSold = b.DatePurchased
		and f.LocationNo = b.LocationNo
		and f.ProductClass = b.ProductClass
		and b.ProductGroup = 'All'
		and b.ProductType = 'All'
		and f.Section = b.Section
*/
	left outer join #salestrans t on
		f.DateSold = t.DateSold
		and f.LocationNo = t.LocationNo
		and f.ProductClass = t.ProductClass
		and t.ProductGroup = t.ProductGroup
		and t.ProductType = 'All'
		and f.Section = t.Section
where
	f.Section <> 'All'
order by
	f.LocationNo
	,f.DateSold 
	,f.ProductClass
	,f.Section

insert into #final_section
select
	'00000' [LocationNo]
	,f.[Month] [Month]
	,f.ProductClass
	,'All' [ProductGroup]
	,'All' [ProductType]
	,f.Section [Section]
	,sum(f.Sales) / s.StoreCount
	,sum(f.QtySold) / s.StoreCount
	,sum(f.ClearSales) / s.StoreCount
	,sum(f.ClearQtySold) / s.StoreCount
	,sum(f.MDSales) / s.StoreCount
	,sum(f.MDQtySold) / s.StoreCount
	,sum(f.DiscountSales) / s.StoreCount
	,sum(f.DiscountQtySold) / s.StoreCount
	,sum(f.OriginalSales) / s.StoreCount
	,sum(f.OriginalQtySold) / s.StoreCount
	,sum(f.EmployeeSales) / s.StoreCount
	,sum(f.EmployeeQtySold) / s.StoreCount
	,sum(f.Costs) / s.StoreCount
	,sum(f.QtyPurchased) / s.StoreCount
	,sum(f.GrossProfit) / s.StoreCount
	,sum(f.iSales) / s.StoreCount
	,sum(f.QtyiSales) / s.StoreCount
	,sum(f.CostsOut) / s.StoreCount
	,sum(f.QtyOut) / s.StoreCount
	,sum(f.CostsIn) / s.StoreCount
	,sum(f.QtyIn) / s.StoreCount
	,sum(f.CostsTrash) / s.StoreCount
	,sum(f.QtyTrash) / s.StoreCount
	,sum(f.TotalSales) / s.StoreCount
	,sum(f.TotalCosts) / s.StoreCount
	,sum(f.TotalQtySold) / s.StoreCount
	,sum(f.TotalQtyPurchased) / s.StoreCount
	,sum(f.Transactions) / s.StoreCount
	,'0'
from
	#final_section f
	inner join #stores s on f.[Month] = s.[Date]
group by
	s.StoreCount
	,f.[Month]
	,f.ProductClass
	,f.Section
order by
	s.StoreCount
	,f.[Month]
	,f.ProductClass
	,f.Section

select * from #final_product where LocationNo < '00065' order by LocationNo, [Month], ProductClass, ProductGroup, ProductType
select * from #final_product where LocationNo >= '00065' order by LocationNo, [Month], ProductClass, ProductGroup, ProductType


select * from #final_section where LocationNo < '00065' order by LocationNo, [Month], ProductClass, Section
select * from #final_section where LocationNo >= '00065' order by LocationNo, [Month], ProductClass, Section

/*
select * into ReportsView..StarliteProducts from #final_product order by LocationNo, [Month], ProductClass, ProductGroup, ProductType
select * into ReportsView..StarliteSections from #final_section order by LocationNo, [Month], ProductClass, Section

select * from 
*/