USE [Sips]
GO

/****** Object:  Table [dbo].[BuysSipsSummary]    Script Date: 3/22/2019 1:32:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BuysSipsSummary](
	[BusinessDate] [char](10) NOT NULL,
	[StoreCode] [char](4) NOT NULL,
	[TotalItemsBuys] [int] NULL,
	[TotalItemsSips] [int] NULL,
	[TotalItemsUN] [int] NULL,
	[TotalItemsDVD] [int] NULL,
	[TotalItemsCDU] [int] NULL,
	[PercentSipsPurchased] [decimal](12, 6) NULL,
	[TotalItemsBuysYear] [int] NULL,
	[TotalItemsSipsYear] [int] NULL,
	[TotalItemsUNYear] [int] NULL,
	[TotalItemsDVDYear] [int] NULL,
	[TotalItemsCDUYear] [int] NULL,
	[PercentSipsPurchasedYear] [decimal](12, 6) NULL,
	[TotalItemsBuysMonth] [int] NULL,
	[TotalItemsSipsMonth] [int] NULL,
	[TotalItemsUNMonth] [int] NULL,
	[TotalItemsDVDMonth] [int] NULL,
	[TotalItemsCDUMonth] [int] NULL,
	[PercentSipsPurchasedMonth] [decimal](12, 6) NULL,
	[PercentSipsCompare] [decimal](12, 6) NULL,
 CONSTRAINT [PK_BuysSipsSummary] PRIMARY KEY NONCLUSTERED 
(
	[BusinessDate] ASC,
	[StoreCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


