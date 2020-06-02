USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[MonsoonCommissions]    Script Date: 12/19/2016 15:29:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MonsoonCommissions]') AND type in (N'U'))
DROP TABLE [dbo].[MonsoonCommissions]
GO

USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[MonsoonCommissions]    Script Date: 12/19/2016 15:29:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MonsoonCommissions](
	[SellerName] [nvarchar](100),
	[CommPct] [decimal](9, 3) NULL,
	[StartDate] [datetime] ,
	[EndDate] [datetime]
	 CONSTRAINT [PK_MonsoonCommissions_1] PRIMARY KEY CLUSTERED 
	 (SellerName,StartDate,EndDate)
) ON [PRIMARY]

insert into OnlineSalesReporting..MonsoonCommissions (SellerName,  CommPct, StartDate, EndDate )
    values ('Monsoon', .017, '1/1/2008','12/31/2099')



GO


