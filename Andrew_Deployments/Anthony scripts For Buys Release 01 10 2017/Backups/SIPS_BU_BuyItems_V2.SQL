USE [SIPS]
GO

/****** Object:  StoredProcedure [dbo].[BU_BuyItems_V2]    Script Date: 1/10/2018 7:42:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[BU_BuyItems_V2]
	@LocationNo char(5),
	@buyBinNo int
as

set nocount on

/*
06/09/13 removed Type
*/

select	
--added 02.17.2016 going to automatically add the checkbox column
	--case when SuggestedPrice > 0 then cast('1' as bit)
	case when i.Price > 0 and i.SipsID != '' then cast('1' as bit)
	when i.SuggestedPrice > 0 and i.SipsID != '' then CAST('1' as bit)
	--when i.ListPrice > 0 and i.SipsID != '' then CAST('1' as bit)
	 else cast('0' as bit)
	 end as PrintLabel,
	h.BuyBinNo as BuyID,
	h.CreateTime, h.UpdateTime,
	h.BinType,
	cast(h.TotalOffer as varchar(30)) as TotalOffer,
	h.TotalQuantity,
	i.ItemLineNo as RNo,i.ItemDescription as Title,
	t.BuyType,
	--g.ProductGroup as [Type],
	i.Quantity, cast(i.Offer as varchar(30)) as LineOffer, 
	case i.StatusCode when 1 then 'Active' when 0 then 'Deleted' end as ItemStatus,
	s.BuyStatusName, 
	datediff(minute, h.CreateTime, h.UpdateTime ) as TotalTimeMin,
	i.SipsID,
	coalesce(i.ISBN,'S'+cast(i.SipsID as varchar(20)),'D'+i.DipsItemCode) as ISBN
	--added 02.01.2016 to support suggested offers
	,Scoring_ID
	--06.03.2016 commenting out the Suggested Price, we will price off of 1/2 List
	--,SuggestedPrice as Price
	--,convert(decimal(10,2),ListPrice) / 2  as Price
	--06.08.2016 PRICING will show what item was priced at
	--,case 
	--	when i.Price is not null then cast(i.Price as varchar(30)) 
	--	--when i.SuggestedPrice > 0 then CAST(cast((cast(i.SuggestedPrice as decimal)/2) -.01 as money) as varchar(10))
	--	when i.SuggestedPrice > 0 then CAST(i.SuggestedPrice as varchar(30))
	--	--when i.ListPrice is not null then cast(cast((cast(i.ListPrice AS decimal)/ 2) - .01 as money) as varchar(30))
	--	else '0.00'
	-- end Price
	,dbo.SIPS_UFN_CalculateHalfPrice(ListPrice) as Price
	--06.06.2016 PRICING
	--07.25.2016 change back to ListPrice
	--,CAST(SuggestedPrice as varchar(10)) as ListPrice
	,cast(ListPrice as varchar(30)) as ListPrice--per meeting on 06/06 they want to see list price right next to the Price
	,i.LabelPrinted as ItemCode
from	
	buys.dbo.BuyBinHeader h
	left join buys.dbo.BuyBinItems i
		on h.LocationNo = i.LocationNo
		and h.BuyBinNo = i.BuyBinNo
	left join buys.dbo.BuyTypes t
		on i.BuyTypeID = t.BuyTypeID
	--left join buys.dbo.SearchServiceProductGroup g
	--	on g.BuyTypeID = t.BuyTypeID
	inner join buys.dbo.BuyStatusCodes s
		on h.StatusCode = s.BuyStatusID
	inner join buys.dbo.BuyCustomers c
		on h.CustomerNo = c.CustomerNo
where
	h.LocationNo = @LocationNo
	and h.BuyBinNo = @buyBinNo
	
order by
	i.ItemLineNo






GO

