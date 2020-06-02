--select name from sys.databases
USE [rHPB_Historical]
GO
DECLARE @TDEJ DateTime;
SET @TDEJ = (SELECT MAX([EndDate]) FROM [rHPB_Historical].[dbo].[SalesHeaderHistory_Recent])
PRINT 'rHPB_Historical'
PRINT @TDEJ
--UNION ALL
--USE [archShelfScan]
--GO
--DECLARE @TDEJ DateTime;
--SET @TDEJ = (SELECT MAX([EndDate]) FROM [archShelfScan].[dbo].[SalesHeaderHistory_Recent])
--PRINT 'rHPB_Historical' + @TDEJ
----UNION ALL


--archShelfScan
--archHPB_SALES
--archSIPS
--HPB_INV
--HPB_SALES
--Monsoon
--Reports
--Sandbox
--rHPB_Historical
--rILS_Data
--DBAAdmin
--ReportsView
--MathLab
--Customers
--PCMS_IMPORT
--ISIS
--OFS_Assorted
--OFS
--DirectedScanning
--PostageService
--Hive
--BUYS
SET @TDEJ = (SELECT TOP (1) RecordDateTime FROM [Buys].[dbo].[BuyActivityLog])
PRINT 'Buys'
PRINT @TDEJ


--ReportsData
SET @TDEJ = (SELECT MAX( StartDate)FROM [ReportsData].[dbo].[dba_SaleasHeaderBatch])
PRINT 'ReportsData'
PRINT @TDEJ



--CatalogFeeds
--BakerTaylor
SET @TDEJ = (SELECT MAX([IssueDateTime]) FROM [BakerTaylor].[dbo].[order_Header])
PRINT 'BakerTaylor'
PRINT @TDEJ
--UNION ALL

--BuyOffersDev

--Catalog
--NewReportsDEV
--Cosmos
--VisNetic_History
--VisNetic_MailFlow