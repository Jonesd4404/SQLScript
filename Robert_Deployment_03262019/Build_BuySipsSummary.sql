/****** Script for SelectTopNRows command from SSMS  ******/

USE [SIPS]
GO
/****** Object:  StoredProcedure [dbo].[GetParamData]    Script Date: 3/20/2019 11:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[Build_BuySipsSummary]
	
as
begin 
declare @MaxStore char(5)

declare @BusinessDate char(10),
		@MinDay int,
		@MinYear int,
		@MaxYear int,
		@MinMonth int,
		@LocationNo varchar(5),
		@StoreCode varchar(4),
		@DaySearch datetime,
		@YearSearch datetime,
		@MonthSearch datetime,
		@YearSearchTop datetime


--set @BusinessDate = '2019-03-22'
set @BusinessDate = convert(date,getdate(),10)
set @StoreCode = '0001'
set @MaxStore = '00300'


Set @DaySearch = DateAdd(day, -1, @BusinessDate) 
set @YearSearch = DateAdd(day, -1, DateAdd(year, -1, @BusinessDate))
set @YearSearchTop =  DateAdd(year, -1, @BusinessDate)
--set @MonthSearch = DateAdd(month, -1, @BusinessDate)
set @MonthSearch = DATEADD(m, DATEDIFF(m,0,@BusinessDate),0)


SELECT @MinDay = min(ItemCode)
  FROM [SIPS].[dbo].[SipsProductInventory] with (nolock)
  where DateInStock >= @DaySearch

SELECT @MinYear = min(ItemCode)
  FROM [SIPS].[dbo].[SipsProductInventory] with (nolock)
  where DateInStock >= @YearSearch 

SELECT @MaxYear = max(ItemCode)
  FROM [SIPS].[dbo].[SipsProductInventory] with (nolock)
  where DateInStock < @YearSearchTop

SELECT @MinMonth = min(ItemCode)
  FROM [SIPS].[dbo].[SipsProductInventory] with (nolock)
  where DateInStock >= @MonthSearch


declare @MinBinNo table
(
	LocationNo char(5),
	BuyBinNo int
)

declare @MinBinNoYear table
(
	LocationNo char(5),
	BuyBinNo int
)

declare @MinBinNoMonth table
(
	LocationNo char(5),
	BuyBinNo int
)

declare @TempDay table
(
	LocationNo char(5),
	SummaryOrder int,
	BuyType varchar(20),
	TotalItemsBuyType int
)

declare @TempYear table
(
	LocationNo char(5),
	SummaryOrder int,
	BuyType varchar(20),
	TotalItemsBuyType int
)

declare @TempMonth table
(
	LocationNo char(5),
	SummaryOrder int,
	BuyType varchar(20),
	TotalItemsBuyType int
)

declare @TotalItemBuys table
(
	LocationNo char(5),
	TotalItemsBuys int
)

declare @TotalItemSips table
(
	LocationNo char(5),
	TotalItemsSips int
)

declare @PercentSipsPurchased table
(
	LocationNo char(5),
	PercentSipsPurchased decimal(12,6)
	)


declare @TotalItemBuysYear table
(
	LocationNo char(5),
	TotalItemsBuys int
)

declare @TotalItemSipsYear table
(
	LocationNo char(5),
	TotalItemsSips int
)

declare @PercentSipsPurchasedYear table
(
	LocationNo char(5),
	PercentSipsPurchased decimal(12,6)
	)

declare @TotalItemBuysMonth table
(
	LocationNo char(5),
	TotalItemsBuys int
)

declare @TotalItemSipsMonth table
(
	LocationNo char(5),
	TotalItemsSips int
)

declare @PercentSipsPurchasedMonth table
(
	LocationNo char(5),
	PercentSipsPurchased decimal(12,6)
	)

declare @Totals table
(
		BusinessDate char(10),
		StoreCode char(4),
		TotalItemsBuys int,
		TotalItemsSips int,
		TotalItemsUN int,
		TotalItemsDVD int,
		TotalItemsCDU int,
		PercentSipsPurchased decimal(12,6),		
		TotalItemsBuysYear int,
		TotalItemsSipsYear int,
		TotalItemsUNYear int,
		TotalItemsDVDYear int,
		TotalItemsCDUYear int,
		PercentSipsPurchasedYear decimal(12,6),
		TotalItemsBuysMonth int,
		TotalItemsSipsMonth int,
		TotalItemsUNMonth int,
		TotalItemsDVDMonth int,
		TotalItemsCDUMonth int,
		PercentSipsPurchasedMonth decimal(12,6),
		PercentSipsCompare decimal(12,6)
)


insert into @MinBinNo
SELECT LocationNo, min(BuyBinNo)
  FROM [BUYS].[dbo].[BuyBinHeader]
  where CreateTime >= @DaySearch
  group by LocationNo
  order by LocationNo

insert into @MinBinNoYear
SELECT LocationNo, min(BuyBinNo)
  FROM [BUYS].[dbo].[BuyBinHeader]
  where CreateTime >= @YearSearch
  group by LocationNo
  order by LocationNo


insert into @MinBinNoMonth
SELECT LocationNo, min(BuyBinNo)
  FROM [BUYS].[dbo].[BuyBinHeader]
  where CreateTime >= @MonthSearch
  group by LocationNo
  order by LocationNo


--Day
insert into @TempDay
SELECT BBH.LocationNo, BBT.SummaryOrder, BBT.BuyType, sum(BBI.Quantity) as TotalItemsBuysType
  FROM	[Buys].[dbo].[BuyBinHeader] BBH with (nolock) inner join
		[Buys].[dbo].[BuyBinItems] BBI with (nolock) on
			BBI.LocationNo = BBH.LocationNo and
			BBI.BuyBinNo = BBH.BuyBinNo inner join
  		[Buys].[dbo].[BuyTypes] BBT on
			BBI.BuyTypeID = BBT.BuyTypeID inner join
		[SIPS].[dbo].[Locations] L on
			BBH.LocationNo = L.LocationNo inner join
		@MinBinNo MB on
			BBH.LocationNo = MB.LocationNo and
			BBH.BuyBinNo >= MB.BuyBinNo
  where BBH.CreateTime >= @DaySearch and
		BBT.BuyType in ('UN', 'DVD', 'CDU') and
		BBI.StatusCode = 1 and
		BBH.StatusCode = 1 and
		L.Status = 'A' and
			L.LocationType = 'S' and
			L.RetailStore= 'Y' and
			L.LocationNo < @MaxStore
  group by BBH.LocationNo, BBT.SummaryOrder, BBT.BuyType
  order by BBH.LocationNo, BBT.SummaryOrder


insert into @TotalItemBuys
select BBH.LocationNo, isnull(sum(BBI.Quantity),0)
  FROM	[Buys].[dbo].[BuyBinHeader] BBH with (nolock)  inner join
		[Buys].[dbo].[BuyBinItems] BBI with (nolock) on
			BBI.LocationNo = BBH.LocationNo and
			BBI.BuyBinNo = BBH.BuyBinNo inner join
		[SIPS].[dbo].[Locations] L on
			BBH.LocationNo = L.LocationNo inner join
		@MinBinNo MB on
			BBH.LocationNo = MB.LocationNo and
			BBH.BuyBinNo >= MB.BuyBinNo
  where BBH.CreateTime >= @DaySearch and
		BBI.StatusCode = 1 and
		BBH.StatusCode = 1 and
		L.Status = 'A' and
		L.LocationType = 'S' and
		L.RetailStore= 'Y' and
		L.LocationNo < @MaxStore
group by BBH.LocationNo
order by BBH.LocationNo

insert into @TotalItemSips
SELECT SPI.LocationNo, isnull(count(*),0)
  FROM [SIPS].[dbo].[SipsProductInventory] SPI with (nolock) inner join
  		[SIPS].[dbo].[Locations] L on
			SPI.LocationNo = L.LocationNo
  where DateInStock >= @DaySearch and
		ItemCode>= @MinDay and
		L.Status = 'A' and
		L.LocationType = 'S' and
		L.RetailStore= 'Y' and
		L.LocationNo < @MaxStore
group by SPI.LocationNo
order by SPI.LocationNo

/*
set @PercentSipsPurchased =  isnull((convert(decimal(12,2),@TotalItemsSips) / convert(decimal(12,2), @TotalItemsBuys )),0)
*/
insert into @PercentSipsPurchased
select TIB.LocationNo, isnull(convert(decimal(12,2),TIS.TotalItemsSips),0.00) / isnull(convert(decimal(12,2), TIB.TotalItemsBuys ),0.00)
from @TotalItemSips TIS inner join
	@TotalItemBuys TIB on
		TIS.LocationNo = TIB.LocationNo

--Year
insert into @TempYear
SELECT BBH.LocationNo, BBT.SummaryOrder, BBT.BuyType, sum(BBI.Quantity) as TotalItemsBuysType
  FROM	[Buys].[dbo].[BuyBinHeader] BBH with (nolock) inner join
		[Buys].[dbo].[BuyBinItems] BBI with (nolock) on
			BBI.LocationNo = BBH.LocationNo and
			BBI.BuyBinNo = BBH.BuyBinNo inner join
  		[Buys].[dbo].[BuyTypes] BBT on
			BBI.BuyTypeID = BBT.BuyTypeID inner join
		[SIPS].[dbo].[Locations] L on
			BBH.LocationNo = L.LocationNo inner join
		@MinBinNoYear MB on
			BBH.LocationNo = MB.LocationNo and
			BBH.BuyBinNo >= MB.BuyBinNo
  where (BBH.CreateTime >= @YearSearch and BBH.CreateTime < @YearSearchTop) and
		BBT.BuyType in ('UN', 'DVD', 'CDU') and
		BBI.StatusCode = 1 and
		BBH.StatusCode = 1 and
		L.Status = 'A' and
			L.LocationType = 'S' and
			L.RetailStore= 'Y' and
			L.LocationNo < @MaxStore
  group by BBH.LocationNo, BBT.SummaryOrder, BBT.BuyType
  order by BBH.LocationNo, BBT.SummaryOrder

insert into @TotalItemBuysYear
select BBH.LocationNo, isnull(sum(BBI.Quantity),0)
  FROM	[Buys].[dbo].[BuyBinHeader] BBH with (nolock) inner join  
		[Buys].[dbo].[BuyBinItems] BBI with(nolock) on
			BBI.LocationNo = BBH.LocationNo and
			BBI.BuyBinNo = BBH.BuyBinNo inner join
		[SIPS].[dbo].[Locations] L on
			BBH.LocationNo = L.LocationNo inner join
		@MinBinNoYear MB on
			BBH.LocationNo = MB.LocationNo and
			BBH.BuyBinNo >= MB.BuyBinNo
  where (BBH.CreateTime >= @YearSearch and BBH.CreateTime < @YearSearchTop) and
		BBI.StatusCode = 1 and
		BBH.StatusCode = 1 and
		L.Status = 'A' and
			L.LocationType = 'S' and
			L.RetailStore= 'Y' and
			L.LocationNo < @MaxStore
group by BBH.LocationNo
order by BBH.LocationNo


insert into @TotalItemSipsYear
SELECT SPI.LocationNo, isnull(count(*),0)
  FROM [SIPS].[dbo].[SipsProductInventory] SPI with (nolock) inner join
  		[SIPS].[dbo].[Locations] L on
			SPI.LocationNo = L.LocationNo
  where (DateInStock >= @YearSearch and DateInStock < @YearSearchTop) and
		ItemCode>= @MinYear and
		L.Status = 'A' and
		L.LocationType = 'S' and
		L.RetailStore= 'Y' and
		L.LocationNo < @MaxStore
group by SPI.LocationNo
order by SPI.LocationNo

/*
set @PercentSipsPurchasedYear =  isnull((convert(decimal(12,2),@TotalItemsSipsYear) / convert(decimal(12,2), @TotalItemsBuysYear )),0)
*/

insert into @PercentSipsPurchasedYear
select TIB.LocationNo, isnull(convert(decimal(12,2),TIS.TotalItemsSips),0.00) / isnull(convert(decimal(12,2), TIB.TotalItemsBuys ),0.00)
from @TotalItemSipsYear TIS inner join
	@TotalItemBuysYear TIB on
		TIS.LocationNo = TIB.LocationNo


--Month
insert into @TempMonth
SELECT BBH.LocationNo, BBT.SummaryOrder, BBT.BuyType, sum(BBI.Quantity) as TotalItemsBuysType
  FROM	[Buys].[dbo].[BuyBinHeader] BBH with (nolock) inner join
		[Buys].[dbo].[BuyBinItems] BBI with (nolock) on
			BBI.LocationNo = BBH.LocationNo and
			BBI.BuyBinNo = BBH.BuyBinNo inner join
  		[Buys].[dbo].[BuyTypes] BBT on
			BBI.BuyTypeID = BBT.BuyTypeID inner join
		[SIPS].[dbo].[Locations] L on
			BBH.LocationNo = L.LocationNo inner join
		@MinBinNoMonth MB on
			BBH.LocationNo = MB.LocationNo and
			BBH.BuyBinNo >= MB.BuyBinNo
  where BBH.CreateTime >= @MonthSearch and
		BBT.BuyType in ('UN', 'DVD', 'CDU') and
		BBI.StatusCode = 1 and
		BBH.StatusCode = 1 and
		L.Status = 'A' and
			L.LocationType = 'S' and
			L.RetailStore= 'Y' and
			L.LocationNo < @MaxStore
  group by BBH.LocationNo, BBT.SummaryOrder, BBT.BuyType
  order by BBH.LocationNo, BBT.SummaryOrder

insert into @TotalItemBuysMonth
select BBH.LocationNo, isnull(sum(BBI.Quantity),0)
  FROM	[Buys].[dbo].[BuyBinHeader] BBH with (nolock) inner join  
		[Buys].[dbo].[BuyBinItems] BBI with(nolock) on
			BBI.LocationNo = BBH.LocationNo and
			BBI.BuyBinNo = BBH.BuyBinNo inner join
		[SIPS].[dbo].[Locations] L on
			BBH.LocationNo = L.LocationNo inner join
		@MinBinNoMonth MB on
			BBH.LocationNo = MB.LocationNo and
			BBH.BuyBinNo >= MB.BuyBinNo
  where BBH.CreateTime >= @MonthSearch and
		BBI.StatusCode = 1 and
		BBH.StatusCode = 1 and
		L.Status = 'A' and
			L.LocationType = 'S' and
			L.RetailStore= 'Y' and
			L.LocationNo < @MaxStore
group by BBH.LocationNo
order by BBH.LocationNo


insert into @TotalItemSipsMonth
SELECT SPI.LocationNo, isnull(count(*),0)
  FROM [SIPS].[dbo].[SipsProductInventory] SPI with (nolock) inner join
  		[SIPS].[dbo].[Locations] L on
			SPI.LocationNo = L.LocationNo
  where DateInStock >= @MonthSearch and
		ItemCode>= @MinMonth and
		L.Status = 'A' and
		L.LocationType = 'S' and
		L.RetailStore= 'Y' and
		L.LocationNo < @MaxStore
group by SPI.LocationNo
order by SPI.LocationNo
/*
set @PercentSipsPurchasedMonth =  isnull((convert(decimal(12,2),@TotalItemsSipsMonth) / convert(decimal(12,2), @TotalItemsBuysMonth )),0)
*/

insert into @PercentSipsPurchasedMonth
select TIB.LocationNo, isnull(convert(decimal(12,2),TIS.TotalItemsSips),0.00) / isnull(convert(decimal(12,2), TIB.TotalItemsBuys ),0.00)
from @TotalItemSipsMonth TIS inner join
	@TotalItemBuysMonth TIB on
		TIS.LocationNo = TIB.LocationNo

insert into @Totals (BusinessDate, StoreCode, TotalItemsBuys, TotalItemsSips, TotalItemsUN,TotalItemsDVD,TotalItemsCDU, PercentSipsPurchased, 
					TotalItemsBuysYear, TotalItemsSipsYear, TotalItemsUNYear, TotalItemsDVDYear, TotalItemsCDUYear, PercentSipsPurchasedYear,
					TotalItemsBuysMonth, TotalItemsSipsMonth, TotalItemsUNMonth, TotalItemsDVDMonth, TotalItemsCDUMonth, PercentSipsPurchasedMonth )
select @BusinessDate, substring(LocationNo,2,4),0,0,0,0,0,0.0,0,0,0,0,0,0.0,0,0,0,0,0,0.0
from [SIPS].[dbo].[Locations]
where 		Status = 'A' and
			LocationType = 'S' and
			RetailStore= 'Y' and
			LocationNo < @MaxStore



update @Totals set TotalItemsUN = TotalItemsBuyType from @TempDay where BuyType = 'UN' and StoreCode = Substring(LocationNo, 2,4)
update @Totals set TotalItemsDVD = TotalItemsBuyType from @TempDay where BuyType = 'DVD' and StoreCode = Substring(LocationNo, 2,4)
update @Totals set TotalItemsCDU = TotalItemsBuyType from @TempDay where BuyType = 'CDU' and StoreCode = Substring(LocationNo, 2,4)

update @Totals set TotalItemsUNYear = TotalItemsBuyType from @TempYear where BuyType = 'UN' and StoreCode = Substring(LocationNo, 2,4)
update @Totals set TotalItemsDVDYear = TotalItemsBuyType from @TempYear where BuyType = 'DVD' and StoreCode = Substring(LocationNo, 2,4)
update @Totals set TotalItemsCDUYear = TotalItemsBuyType from @TempYear where BuyType = 'CDU' and StoreCode = Substring(LocationNo, 2,4)

update @Totals set TotalItemsUNMonth = TotalItemsBuyType from @TempMonth where BuyType = 'UN' and StoreCode = Substring(LocationNo, 2,4)
update @Totals set TotalItemsDVDMonth = TotalItemsBuyType from @TempMonth where BuyType = 'DVD' and StoreCode = Substring(LocationNo, 2,4)
update @Totals set TotalItemsCDUMonth = TotalItemsBuyType from @TempMonth where BuyType = 'CDU' and StoreCode = Substring(LocationNo, 2,4)

update @Totals set TotalItemsBuys = T.TotalItemsBuys from @TotalItemBuys T where StoreCode = Substring(T.LocationNo, 2,4)
update @Totals set TotalItemsSips = T.TotalItemsSips from @TotalItemSips T where StoreCode = Substring(T.LocationNo, 2,4)
update @Totals set PercentSipsPurchased = T.PercentSipsPurchased from @PercentSipsPurchased T where StoreCode = Substring(T.LocationNo, 2,4)

Update @Totals set TotalItemsBuysYear = T.TotalItemsBuys from @TotalItemBuysYear T where StoreCode = Substring(T.LocationNo, 2,4)
Update @Totals set TotalItemsSipsYear = T.TotalItemsSips from @TotalItemSipsYear T where StoreCode = Substring(T.LocationNo, 2,4)
Update @Totals set PercentSipsPurchasedYear = T.PercentSipsPurchased from @PercentSipsPurchasedYear T where StoreCode = Substring(T.LocationNo, 2,4)

Update @Totals set TotalItemsBuysMonth = T.TotalItemsBuys from @TotalItemBuysMonth T where StoreCode = Substring(T.LocationNo, 2,4)
Update @Totals set TotalItemsSipsMonth = T.TotalItemsSips from @TotalItemSipsMonth T where StoreCode = Substring(T.LocationNo, 2,4)
Update @Totals set PercentSipsPurchasedMonth = T.PercentSipsPurchased from @PercentSipsPurchasedMonth T where StoreCode = Substring(T.LocationNo, 2,4)

Update @Totals set  PercentSipsCompare = isnull(((convert(decimal(12,2),T.TotalItemsSips) - Convert(decimal(12,2),T.TotalItemsSipsYear)) / convert(decimal(12,2),NullIF(T.TotalItemsSipsYear,0))    ),0.0)  from @Totals T




truncate table [SIPS].[dbo].[BuysSipsSummary]
insert into [SIPS].[dbo].[BuysSipsSummary]
select * from @Totals order by BusinessDate,StoreCode

--CLOSE CursorLocation
--Deallocate CursorLocation

END