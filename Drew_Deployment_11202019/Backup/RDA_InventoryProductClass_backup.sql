USE [ReportsData]
GO

/****** Object:  Table [dbo].[RDA_InventoryProductClass]    Script Date: 11/20/2019 1:11:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RDA_InventoryProductClass](
	[ProductClassID] [bigint] NOT NULL,
	[Category] [varchar](15) NULL,
	[Type_Description] [varchar](15) NULL,
	[ProductType] [varchar](4) NULL,
 CONSTRAINT [PK_RDA_InventoryProductClass] PRIMARY KEY CLUSTERED 
(
	[ProductClassID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 97) ON [PRIMARY]
) ON [PRIMARY]

GO


