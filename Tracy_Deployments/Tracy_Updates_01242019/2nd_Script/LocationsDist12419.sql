USE [ReportsData]
GO

--use [HPB_db]
--GO


--set the non SIPS stores
	   update dbo.LocationsDist
	   set  RptSIPSloc ='N'
	   where locationid in (
	   '0000000004',
	   '0000000037',
	   '0000000142',
	   '0000000143',
	   '0000000153')