--3:28

DECLARE @name VARCHAR(100) -- database name  
DECLARE @tbname VARCHAR(100) -- database name 
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
SET @path = 'O:\MSSQL\BACKUP2\'
--SET @path = '\\C1-VEEAM\d$\Backup\SQL_AGENT_BACKUPS\'  
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name IN('archHPB_SALES','archShelfScan','archSIPS','BakerTaylor','Buy_Analytics','BuyOffersDev','Buys','Catalog','CatalogFeeds','Cosmos','Customers','DBAAdmin','DirectedScanning','Gardner','Hive','HPB_HistoricalDaily','HPB_INV','HPB_SALES',
'ISIS','MathLab','Monsoon',
'NewReportsDEV','NorthWind','OFS','OFS_Assorted','PCMS_IMPORT','PostageService','pubs','Report_Analytics','Reports','ReportsData','ReportsView',
'rHPB_Historical','rILS_DATA','Sandbox','Sandbox_RD','VertexReturns','VisNetic MailFlow',
'VisNetic_History','VisNetic_MailFlow');
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + 'SAGE_' + @name + '_' + '20191022' + '_Full' + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName  WITH COMPRESSION, STATS = 1
   PRINT @name
 
   FETCH NEXT FROM db_cursor INTO @name   
END   

--CLOSE tb_cursor   
--DEALLOCATE tb_cursor
 

CLOSE db_cursor   
DEALLOCATE db_cursor