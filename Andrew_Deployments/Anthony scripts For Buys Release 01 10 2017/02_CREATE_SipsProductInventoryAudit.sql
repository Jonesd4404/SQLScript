USE [SIPS]
GO

/****** Object:  Table [dbo].[SipsProductInventory]    Script Date: 7/18/2017 2:53:26 PM ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SipsProductInventoryAudit](
	[ItemCode] [int] NOT NULL,
	[LocationNo] [char](5) NOT NULL,
	[SipsID] [int] NOT NULL,
	[Active] [char](1) NOT NULL,
	[DateInStock] [datetime] NULL,
	[EmployeeDiscPct] [decimal](5, 2) NOT NULL,
	[IsDiscountable] [char](1) NOT NULL,
	[IsTaxable] [char](1) NOT NULL,
	[LastSaleDate] [smalldatetime] NULL,
	[QuantityOnHand] [int] NOT NULL,
	[QuantityReserved] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[CreateUser] [varchar](100) NOT NULL,
	[LocationID] [varchar](10) NOT NULL,
	[SubjectKey] [smallint] NOT NULL,
	[CreatedForPos] [tinyint] NOT NULL,
	[CreateMachine] [nvarchar](128) NULL,
	[ProductType] [varchar](4) NOT NULL,
	[ItemScore] [tinyint] NULL,
	[BuyXactionID] [char](10) NULL,
	[ItemStatus] [tinyint] NULL,
	[AuditDate] [datetime]
 CONSTRAINT [PK_SipsProductInventory_Audit] PRIMARY KEY CLUSTERED 
(
	[ItemCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO




