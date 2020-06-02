USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[HalfDotComCommissions]    Script Date: 12/19/2016 15:29:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HalfDotComCommissions]') AND type in (N'U'))
DROP TABLE [dbo].[HalfDotComCommissions]
GO

USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[HalfDotComCommissions]    Script Date: 12/19/2016 15:29:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[HalfDotComCommissions](
	[SellerName] [nvarchar](100) ,
	[FlatCommission] [smallmoney] NULL,
	[LowerLimit] [smallmoney] ,
	[UpperLimit] [smallmoney] ,
	[CommPct] [decimal](9, 3) NULL,
	--[CommType] [varchar](10) NULL,
	[StartDate] [datetime] ,
	[EndDate] [datetime] ,
	 CONSTRAINT [PK_HalfDotComCommissions_1] PRIMARY KEY CLUSTERED 
	 (SellerName,LowerLimit,UpperLimit,StartDate,EndDate)
) ON [PRIMARY]

insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0,	0	,50	,0.15	, '4/1/2009','12/16/2016')

insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0,	50.01	,100	,0.125	, '4/1/2009','12/16/2016')
    
insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0, 100.01,	250	,0.1	, '4/1/2009','12/16/2016')    

insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0,	250.01	,500	,0.075	, '4/1/2009','12/16/2016')

insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0,	500.01	,99999	,0.05	, '4/1/2009','12/16/2016')
    
insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0,	0	,50	,0.25	, '12/16/2016','12/31/2099')

insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0,	50.01	,100	,0.225	,  '12/16/2016','12/31/2099')
    
insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0, 100.01,	250	,0.2	,  '12/16/2016','12/31/2099')    

insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0,	250.01	,500	,0.175	, '12/16/2016','12/31/2099')

insert into OnlineSalesReporting..HalfDotComCommissions (SellerName, FlatCommission,LowerLimit, UpperLimit,CommPct,   StartDate, EndDate )
    values ('HalfDotCom',0,	500.01	,99999	,0.15	,  '12/16/2016','12/31/2099')   
GO


