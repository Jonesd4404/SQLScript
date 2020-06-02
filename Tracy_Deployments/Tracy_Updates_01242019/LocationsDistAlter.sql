USE [ReportsData]
GO

--use [HPB_db]
--GO

ALTER TABLE dbo.LocationsDist ADD
       RptSIPSLoc char(1) NOT NULL CONSTRAINT DF_LocationsDist_RptSIPSLoc DEFAULT 'Y',
       RptAltStore char(1) NOT NULL CONSTRAINT DF_LocationsDist_RptAltStore DEFAULT 'N',
       RptOutlet char(1) NOT NULL CONSTRAINT DF_LocationsDist_RptOutlet DEFAULT 'N',
       RptBookSmarter char(1) NOT NULL CONSTRAINT DF_LocationsDist_RptBookSmarter DEFAULT 'N',
       RptTransferCost char(1) NOT NULL CONSTRAINT DF_LocationsDist_RptTransferCost DEFAULT 'Y';

