USE [iSales]
GO

/****** Object:  StoredProcedure [dbo].[RPT_SipsItemSearchTool_SipsInfo]    Script Date: 12/2/2019 12:03:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[RPT_SipsItemSearchTool_SipsInfo]
	--declare
	@ItemCode BIGINT
	----,@LocationNo char(5)
AS
/********************************************
SIPS Item Search Tool

Created For: 
Users to find information about
sales history, shelf scan history, listing
and delisting patterns of SIPS items...

Created By:
dgreen - 9.7.2010

TDennis - 12/2/2019 - #10273 Outlet / BookSmarter Transfer project - Removed the logic for location.  Added sips..SipsProductMaster for ISBN and Title.  Added LocationNo 
from SIPS..SipsProductInventory.
********************************************/
DECLARE @Sku NVARCHAR(63)
	,@InventoryItemID INT;

SET @Sku = 'U' + cast(@ItemCode AS NVARCHAR(62));

/*******************************************
Sips Product Inventory / Sales History
********************************************/
/*
declare @SipsInfo table (ItemCode bigint, Active char(1), DateInStock datetime, Price money, 
							ItemScore tinyint, ProductType varchar(4), SalesXactionID char(10), 
							SaleDate datetime)

insert @SipsInfo
*/
SELECT spi.ItemCode
	,spi.Active
	,spi.DateInStock
	,spi.Price
	,spi.ItemScore
	,spi.ProductType
	,ssh.SalesXactionId
	,ssh.EndDate [SaleDate]
	,spm.ISBN
	,spm.Title
	,spi.LocationNo
FROM SIPS..SipsProductInventory spi WITH (NOLOCK)
LEFT JOIN SIPS..SipsSalesHistory ssh WITH (NOLOCK) ON spi.ItemCode = ssh.SipsItemCode
LEFT JOIN sips..SipsProductMaster spm WITH (NOLOCK) ON spi.SipsID = spm.SipsID
WHERE spi.ItemCode = @ItemCode
	----and spi.LocationNo = @LocationNo;
GO


