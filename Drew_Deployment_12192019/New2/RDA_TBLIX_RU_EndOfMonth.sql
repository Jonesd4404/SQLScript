USE [ReportsData]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RDA_EndOfMonth] (
	   [BusinessMonth] [date] NOT NULL,
	   [LocationNo] [varchar](30) NOT NULL, 
	   [RegionName] [varchar](30) NOT NULL,
	   [DistrictName] [varchar](30) NOT NULL,
       [total_NetSales] [decimal](19, 4) NULL,
	   [count_SalesTrans] [bigint] NULL,
	   [count_ItemsSold] [bigint] NULL,
	   [total_BuyOffers] [decimal](19,4) NULL,
	   [count_BuyTrans] [bigint] NULL,
	   [total_BuyQty] [bigint] NULL,
	   [total_iStoreSales] [decimal](19,4) NULL,
	   [count_iStoreOrders] [bigint] NULL,
	   [total_iStoreQty] [bigint] NULL,
	   [total_BookSmarterSales] [decimal](19,4) NULL,
	   [count_BookSmarterOrders] [bigint] NULL,
	   [total_BookSmarterQty] [bigint] NULL
,CONSTRAINT [PK_RDA_EndOfMonth] PRIMARY KEY CLUSTERED 
(
       [BusinessMonth] ASC,
       [LocationNo] ASC,
	   [RegionName] ASC,
	   [DistrictName] ASC
  
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 97) ON [PRIMARY]
) ON [PRIMARY]

