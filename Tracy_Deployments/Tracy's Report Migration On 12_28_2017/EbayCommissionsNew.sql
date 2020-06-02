USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[EbayCommissions]    Script Date: 12/19/2016 15:29:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EbayCommissions]') AND type in (N'U'))
DROP TABLE [dbo].[EbayCommissions]
GO

USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[EbayCommissions]    Script Date: 12/19/2016 15:29:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[EbayCommissions](
	[SellerName] [nvarchar](100) ,
	[FlatCommission] [smallmoney] NULL,
	[CommPct] [decimal](9, 3) NULL,
	[MaxFee] [smallmoney] NULL,
    [PayPal] [decimal](9, 3) NULL,
    [IntlPayPal] [decimal](9, 3) NULL,
    [PayPalFlat] [smallmoney] NULL,
    [IntlPayPalFlat] [smallmoney] NULL,
    [StartDate] [datetime] ,
	[EndDate] [datetime] 
		 CONSTRAINT [PK_EbayCommissions_1] PRIMARY KEY CLUSTERED 
	 (SellerName,StartDate,EndDate)
) ON [PRIMARY]

insert into OnlineSalesReporting..EbayCommissions (SellerName, FlatCommission, CommPct,  MaxFee, PayPal, IntlPayPal,PayPalFlat, IntlPayPalFlat, StartDate, EndDate )
    values ('Ebay',0,	0.10,	750	,0.029 ,0.039,0.3,0.3, '5/1/2009','3/29/2017')

insert into OnlineSalesReporting..EbayCommissions (SellerName, FlatCommission, CommPct,  MaxFee, PayPal, IntlPayPal,PayPalFlat, IntlPayPalFlat, StartDate, EndDate )
    values ('Ebay',0,	0.10,	750	,0.029 ,0.044,0.3,0.3, '3/29/2017','12/31/2099')

GO


