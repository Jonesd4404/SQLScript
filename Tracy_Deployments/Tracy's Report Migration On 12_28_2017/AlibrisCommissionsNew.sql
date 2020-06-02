USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[AlibrisCommissions]    Script Date: 12/19/2016 15:29:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AlibrisCommissions]') AND type in (N'U'))
DROP TABLE [dbo].[AlibrisCommissions]
GO

USE [OnlineSalesReporting]
GO

/****** Object:  Table [dbo].[AlibrisCommissions]    Script Date: 12/19/2016 15:29:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AlibrisCommissions](
	[SellerName] [nvarchar](100) ,
	[Category] [nvarchar](255) ,
	[FlatCommission] [smallmoney] NULL,
	[BNFlatCommUS] [smallmoney] NULL,
	[BNFlatCommCanada] [smallmoney] NULL,
	[EarlyCancelFlat] [smallmoney] NULL,
	[AlbrisCommPct] [decimal](9, 3) NULL,
	[PartnerACommPct] [decimal](9, 3) NULL,
    [PartnerBCommPct] [decimal](9, 3) NULL,
    [PartnerBFlat] [smallmoney] NULL,
    [MinFee] [smallmoney] NULL,
    [MaxFee] [smallmoney] NULL,
	[ShipMethod] [varchar](23) ,
	[StartDate] [datetime] ,
	[EndDate] [datetime] ,
	CONSTRAINT [PK_AlibrisCommissions_1] PRIMARY KEY CLUSTERED 
	 (SellerName,Category,ShipMethod,StartDate,EndDate)
) ON [PRIMARY]

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.25,1.25,1.25,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','9/1/2009','10/1/2013')

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.35,1.35,1.35,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','9/1/2009','10/1/2013')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.35,1.35,1.35,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','9/1/2009','10/1/2013')    
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.25,1.25,1.25,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','9/1/2009','10/1/2013')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.35,1.35,1.35,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','9/1/2009','10/1/2013')
    
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values  ( 'Alibris','Books',1.25,1.19,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','10/1/2013','12/31/2099')      

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.35,0.84,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','10/1/2013','12/31/2099')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.35,0.84,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','10/1/2013','12/31/2099')    
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.25,1.19,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','10/1/2013','12/31/2099')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Books',1.35,0.84,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','10/1/2013','12/31/2099')
    
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values (  'Alibris','Default',1.25,1.19,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','10/1/2013','12/31/2099')       

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Default',1.35,0.84,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','10/1/2013','12/31/2099')

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Default',1.35,0.84,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','10/1/2013','12/31/2099')
        
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Default',1.25,1.19,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','10/1/2013','12/31/2099')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Default',1.35,0.84,1.64,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','10/1/2013','12/31/2099')
    
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values  ('Alibris','Dvds',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','9/1/2009','10/1/2013')        

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Dvds',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','9/1/2009','10/1/2013')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Dvds',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','9/1/2009','10/1/2013')
        
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Dvds',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','9/1/2009','10/1/2013')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Dvds',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','9/1/2009','10/1/2013')
    
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values  ('Alibris','Dvds',1.25,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','10/1/2013','12/31/2099')        

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Dvds',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','10/1/2013','12/31/2099')  

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Dvds',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','10/1/2013','12/31/2099')  
        
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Dvds',1.25,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','10/1/2013','12/31/2099')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Dvds',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','10/1/2013','12/31/2099')
       
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values  ( 'Alibris','Music',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','9/1/2009','10/1/2013')     

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','9/1/2009','10/1/2013')

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','9/1/2009','10/1/2013')
        
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','9/1/2009','10/1/2013')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','9/1/2009','10/1/2013')
    
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',1.25,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','10/1/2013','12/31/2099')         

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','10/1/2013','12/31/2099')

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','10/1/2013','12/31/2099')
        
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',1.25,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','10/1/2013','12/31/2099')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','Music',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','10/1/2013','12/31/2099')
    
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VhsVideos',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','9/1/2009','10/1/2013')         

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values  ('Alibris','VhsVideos',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','9/1/2009','10/1/2013')         
   
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values  ('Alibris','VhsVideos',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','9/1/2009','10/1/2013')    
        
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values  ('Alibris','VhsVideos',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','9/1/2009','10/1/2013') 
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VhsVideos',0.80,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','9/1/2009','10/1/2013')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VhsVideos',1.25,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','10/1/2013','12/31/2099')
    
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VhsVideos',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','10/1/2013','12/31/2099')         

 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VhsVideos',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','10/1/2013','12/31/2099')      
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values  ('Alibris','VhsVideos',1.25,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','10/1/2013','12/31/2099')         

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ( 'Alibris','VhsVideos',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','10/1/2013','12/31/2099') 
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VHS Videos',1.25,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard','10/1/2013','12/31/2099')
    
insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VHS Videos',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited','10/1/2013','12/31/2099')
    
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VHS Videos',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Expedited International','10/1/2013','12/31/2099')
       
 insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values ('Alibris','VHS Videos',1.25,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Standard International','10/1/2013','12/31/2099')         

insert into OnlineSalesReporting..AlibrisCommissions (SellerName, Category, FlatCommission, BNFlatCommUS, BNFlatCommCanada, EarlyCancelFlat, AlbrisCommPct, PartnerACommPct, PartnerBCommPct,
    PartnerBFlat, MinFee, MaxFee, ShipMethod, StartDate, EndDate )
    values   ('Alibris','VHS Videos',1.35,0.80,0.80,0.50,0.15,0.20,0.15,0.25,0.50,60.00,'Two Day','10/1/2013','12/31/2099')  


GO


