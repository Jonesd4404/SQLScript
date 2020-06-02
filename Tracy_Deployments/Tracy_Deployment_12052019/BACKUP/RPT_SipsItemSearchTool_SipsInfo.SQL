USE [iSales]
GO

/****** Object:  StoredProcedure [dbo].[RPT_SipsItemSearchTool_SipsInfo]    Script Date: 12/5/2019 2:24:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[RPT_SipsItemSearchTool_SipsInfo]



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
********************************************/


Declare @Sku nvarchar(63),
		@InventoryItemID int;


set @Sku = 'U' + cast(@ItemCode as nvarchar(62));



/*******************************************
Sips Product Inventory / Sales History
********************************************/

/*
declare @SipsInfo table (ItemCode bigint, Active char(1), DateInStock datetime, Price money, 
							ItemScore tinyint, ProductType varchar(4), SalesXactionID char(10), 
							SaleDate datetime)

insert @SipsInfo
*/

select spi.ItemCode
		,spi.Active
		,spi.DateInStock
		,spi.Price
		,spi.ItemScore
		,spi.ProductType
		,ssh.SalesXactionId
		,ssh.EndDate [SaleDate]
	
from SIPS..SipsProductInventory spi with (nolock)
	left join SIPS..SipsSalesHistory ssh with (nolock)
		on spi.ItemCode = ssh.SipsItemCode
where spi.ItemCode = @ItemCode
	and spi.LocationNo = @LocationNo;
GO

