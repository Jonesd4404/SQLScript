USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[AmazonCommissions]    Script Date: 12/19/2016 15:29:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AmazonCommissions]') AND type in (N'U'))
DROP TABLE [dbo].[AmazonCommissions]
GO

USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[AmazonCommissions]    Script Date: 12/19/2016 15:29:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AmazonCommissions](
	[SellerName] [nvarchar](100),
	[Category] [nvarchar](255) ,
	[StdFlatComm] [smallmoney] NULL,
	[ExpFlatComm] [smallmoney] NULL,
	[StdOzFee] [decimal](6,6) null,
	[ExpOzFee] [decimal](6,6) null,
	[CommPct] [decimal](9, 3) NULL,
    [MinFee] [smallmoney] NULL,
    [RefundPct] [decimal](9, 3) NULL,
    [MaxFeeKept] [smallmoney] NULL,
    [CommType] [varchar](10) NULL,
	[StartDate] [datetime] ,
	[EndDate] [datetime] ,
	 CONSTRAINT [PK_AmazonCommissions_1] PRIMARY KEY CLUSTERED 
	 (SellerName,Category,StartDate,EndDate)
) ON [PRIMARY]
 
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Books',1.35,1.35,0,0,0.15,0,1,0,'Item','1/1/2008','3/1/2017')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Books',1.80,1.80,0,0,0.15,0,1,0,'Total','3/1/2017','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Consumer Electronics',0.45,0.65,0.05,0.10,0.08,1,.2,5, 'Item','3/1/2015','12/31/2099')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','ConsumerElectronics',0.45,0.65,0.05,0.10,0.08,1,.2,5,'Item','3/1/2015','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Default',1.35,1.35,0,0,0.15,0,1,0,'Item','3/1/2015','3/1/2017')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Default',1.80,1.80,0,0,0.15,0,1,0,'Total','3/1/2017','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Dvds',0.20,0.20,0,0,0.15,0,1,0,'Item','1/1/2008','3/1/2015')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Dvds',1.35,1.35,0,0,0.15,0,1,0,'Item','3/1/2015','3/1/2017')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Dvds',1.80,1.80,0,0,0.15,0,1,0,'Total','3/1/2017','12/31/2099')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Home',0.45,0.65,0.05,0.10,0.15,1,.2,5,'Item','3/1/2015','12/31/2099')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Music',0.20,0.20,0,0,0.15,0,1,0,'Item','1/1/2008','3/1/2015')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Music',1.35,1.35,0,0,0.15,0,1,0,'Item','3/1/2015','3/1/2017')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Music',1.80,1.80,0,0,0.15,0,1,0,'Total','3/1/2017','12/31/2099')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Musical Instruments',0.45,0.65,0.05,0.10,0.15,1,.2,5,'Item','3/1/2015','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','MusicalInstruments',0.45,0.65,0.05,0.10,0.15,1,.2,5,'Item','3/1/2015','12/31/2099')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Office Products',0.45,0.65,0.05,0.10,0.15,1,.2,5,'Item','3/1/2015','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Software',1.35,1.35,0,0,0.15,0,1,5,'Item','1/1/2008','3/1/2017')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Software',1.80,1.80,0,0,0.15,0,1,5,'Total','3/1/2017','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','SportsFitness',0.45,0.65,0.05,0.10,0.15,1,.2,5,'Item','3/1/2015','12/31/2099')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Sports and Fitness',0.45,0.65,0.05,0.10,0.15,1,.2,5,'Item','3/1/2015','12/31/2099')   
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','ToysAndGames',0.75,0.75,0,0,0.15,0,.2,5,'Item','1/1/2008','3/1/2015')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Toys And Games',0.45,0.65,0.05,0.10,0.15,1,.2,5,'Item','3/1/2015','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','ToysAndGames',0.45,0.65,0.05,0.10,0.15,1,.2,5,'Item','3/1/2015','12/31/2099')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VideoGames',1.35,1.35,0,0,0.15,0,1,5,'Item','1/1/2008','3/1/2017')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VideoGames',1.80,1.80,0,0,0.15,0,1,5,'Total','3/1/2017','12/31/2099')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Video Games',1.35,1.35,0,0,0.15,0,1,5,'Item','3/1/2015','3/1/2017')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Video Games',1.80,1.80,0,0,0.15,0,1,5,'Total','3/1/2017','12/31/2099')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VideoGameAccessories',0.75,0.75,0,0,0.15,0,1,5,'Item','1/1/2008','3/1/2015')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VideoGameAccessories',1.35,1.35,0,0,0.08,0,1,5,'Item','3/1/2015','3/1/2017')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VideoGameAccessories',1.80,1.80,0,0,0.08,0,1,5,'Total','3/1/2017','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Video Game Accessories',1.35,1.35,0,0,0.08,0,1,5,'Item','3/1/2015','3/1/2017')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Video Game Accessories',1.80,1.80,0,0,0.08,0,1,5,'Total','3/1/2017','12/31/2099')       

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Video Game Console',1.35,1.35,0,0,0.08,0,1,5,'Item','3/1/2015','3/1/2017')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','Video Game Console',1.80,1.80,0,0,0.08,0,1,5,'Total','3/1/2017','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VhsVideos',0.20,0.20,0,0,0.15,0,1,0,'Item','1/1/2008','3/1/2015')    

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VhsVideos',1.35,1.35,0,0,0.15,0,1,0,'Item','3/1/2015','3/1/2017')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VhsVideos',1.80,1.80,0,0,0.15,0,1,0,'Total','3/1/2017','12/31/2099')
    
insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VHS Videos',1.35,1.35,0,0,0.15,0,1,0,'Item','3/1/2015','3/1/2017')

insert into OnlineSalesReporting..AmazonCommissions (SellerName, Category, StdFlatComm, ExpFlatComm, StdOzFee, ExpOzFee, CommPct,  MinFee, RefundPct, MaxFeeKept, CommType, StartDate, EndDate )
    values ('AmazonMarketplaceUS','VHS Videos',1.80,1.80,0,0,0.15,0,1,0,'Total','3/1/2017','12/31/2099')
    

GO


