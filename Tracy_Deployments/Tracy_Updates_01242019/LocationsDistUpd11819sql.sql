USE [ReportsData]
GO

--use [HPB_db]
--GO


--set the non SIPS stores
	   update dbo.LocationsDist
	   set  RptSIPSloc ='N'
	   where locationid in (
	   '0000000001',
'0000000002',
'0000000006',
'0000000010',
'0000000014',
'0000000015',
'0000000016',
'0000000023',
'0000000025',
'0000000029',
'0000000030',
'0000000031',
'0000000033',
'0000000035',
'0000000036',
'0000000039',
'0000000043',
'0000000047',
'0000000051',
'0000000058',
'0000000063',
'0000000066',
'0000000071',
'0000000075',
'0000000085',
'0000000086',
'0000000089',
'0000000090',
'0000000092',
'0000000099',
'0000000102',
'0000000104',
'0000000110',
'0000000113',
'0000000114',
'0000000115',
'0000000116',
'0000000117',
'0000000118',
'0000000119',
'0000000120',
'0000000121',
'0000000122',
'0000000123',
'0000000124',
'0000000125',
'0000000126',
'0000000127',
'0000000128',
'0000000130',
'0000000131',
'0000000132',
'0000000134',
'0000000135',
'0000000136',
'0000000137',
'0000000139',
'0000000154',
'0000000155',
'0000000159',
'0000000166',
'0000000167',
'0000000170',
'0000000171',
'0000000172',
'0000000173',
'0000000176',
'0000000177',
'0000000178',
'0000000179',
'0000000180',
'0000000181',
'0000000182',
'0000000183',
'0000000184',
'0000000185',
'0000000186',
'0000000187',
'0000000188',
'0000000189',
'0000000192',
'0000000193',
'0000000194',
'0000000195',
'0000000196',
'0000000197',
'0000000198',
'0000000200',
'0000000201',
'0000000202',
'0000000203',
'0000000204',
'0000000205',
'0000000207',
'0000000209',
'0000000212',
'0000000213',
'0000000216',
'0000000217',
'0000000218',
'0000000219',
'0000000225',
'0000000227',
'0000000228',
'0000000231',
'0000000232',
'0000000233',
'0000000234',
'0000000238');

--set the Alt Stores
  update dbo.LocationsDist
	   set  RptAltStore ='Y'
	   where locationid in (
	   '0000000213',
'0000000216',
'0000000217',
'0000000218',
'0000000238') ;

--set the Outlet Stores
  update dbo.LocationsDist
	   set  RptOutlet ='Y'
	   where locationid in (
'0000000168',
'0000000169');

--set the BookSmarter Stores
  update dbo.LocationsDist
	   set  RptBookSmarter ='Y'
	   where locationid in (
	   '0000000174',
'0000000175');

--set the Store that will not 
  update dbo.LocationsDist
	   set  RptTransferCost ='N'
	   where locationid in (
	   '0000000213',
'0000000216',
'0000000217',
'0000000218',
'0000000238',
'0000000168',
'0000000169') ;


--set the open date Bloomington 
  update dbo.LocationsDist
	   set  OpenDate ='11/15/2012',
	    Region='Southeast'
	   where locationid =
	   '0000000213' ;

	   
--set the open date Bowling Green
  update dbo.LocationsDist
	   set  OpenDate ='10/7/2013',
	   Region='Southeast'
	   where locationid ='0000000216' ;


--set the open date Rockford
  update dbo.LocationsDist
	   set  OpenDate ='10/17/2013',
	    Region='Central'
	   where locationid =
'0000000217' ;

--set the open date Olympia
  update dbo.LocationsDist
	   set  OpenDate ='10/15/2013',
	   Region='Western'
	   where locationid =
'0000000218' ;

--set the open date Waco 
  update dbo.LocationsDist
	   set  OpenDate ='11/24/2018'
	   where locationid =
'0000000238'  ;

--set the open date Wichita
  update dbo.LocationsDist
	   set  OpenDate ='10/08/2018',
	   Region='Central'
	   where locationid =
'0000000241' ;

--set the open date Bogey Hills
  update dbo.LocationsDist
	   set  OpenDate ='8/14/2017'
	   where locationid =
'0000000235' ;

--set the open date Vernon Hills
  update dbo.LocationsDist
	   set  OpenDate ='4/08/2018'
	   where locationid =
'0000000237' ;

--set the open date Dallas outlet
  update dbo.LocationsDist
	   set  OpenDate ='1/18/2009'
	   where locationid =
'0000000169' ;

--set the open date Ohio outlet
  update dbo.LocationsDist
	   set  OpenDate ='3/30/2010'
	   where locationid =
'0000000168' ;

--set the open date Dallas BookSmarter
  update dbo.LocationsDist
	   set  OpenDate ='2/5/2009'
	   where locationid =
'0000000175' ;

--set the open date Ohio BookSmarter
  update dbo.LocationsDist
	   set  OpenDate ='12/10/2008'
	   where locationid =
'0000000174' ;