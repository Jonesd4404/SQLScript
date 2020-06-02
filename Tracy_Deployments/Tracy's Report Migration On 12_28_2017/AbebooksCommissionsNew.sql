USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[AbebooksCommissions]    Script Date: 12/19/2016 15:29:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AbebooksCommissions]') AND type in (N'U'))
DROP TABLE [dbo].[AbebooksCommissions]
GO

USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[AbebooksCommissions]    Script Date: 12/19/2016 15:29:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AbebooksCommissions](
	[SellerName] [nvarchar](100) ,
	[FlatCommission] [smallmoney] NULL,
	[CommPct] [decimal](9, 3) NULL,
	[MinFee] [smallmoney] NULL,
	[MaxFee] [smallmoney] NULL,
    [CreditCardBase] [decimal](9, 3) NULL,
    [CreditCardOver] [decimal](9, 3) NULL,
    [CreditCardVar] [smallmoney] NULL,
    [CreditCardMin] [smallmoney] NULL,
	[StartDate] [datetime] ,
	[EndDate] [datetime] 
	 CONSTRAINT [PK_AbebooksCommissions_1] PRIMARY KEY CLUSTERED 
	 (SellerName,StartDate,EndDate)
) ON [PRIMARY]

insert into OnlineSalesReporting..AbebooksCommissions (SellerName, FlatCommission, CommPct, MinFee, MaxFee, CreditCardBase, CreditCardOver, CreditCardVar, CreditCardMin, StartDate, EndDate )
    values ('Abebooks',	0,	0.08,	0.5, 40, 0.055,	0.035,	500, .50, '9/1/2009','12/31/2099')



GO


