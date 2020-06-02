DECLARE @name VARCHAR(100) -- database name  
DECLARE @tbname VARCHAR(100) -- database name 
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  

DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @fileHour VARCHAR(4) -- used for backup hour in 24 hour time format 00-23
DECLARE @fileMinute VARCHAR(4) -- used for backup minute 
DECLARE @fileSecond VARCHAR(4) -- used for backup seconds
DECLARE @fileMonth VARCHAR(4) -- used for backup month
DECLARE @fileDay VARCHAR(4) -- used for backup day
DECLARE @fileYear VARCHAR(4) -- used for backup year

DECLARE @DB_Backup INT;
DECLARE @serverName VARCHAR(20) -- used for server name
DECLARE @DatabaseName VARCHAR(20) -- used for Database Name
SET @ServerName = 'SAGE';
SET @DatabaseName = 'Master'

SET @DB_Backup = 0
 
-- specify database backup directory
--SET @path = 'O:\MSSQL\BACKUP\'
--SET @path = '\\C1-VEEAM\d$\Backup\SQL_AGENT_BACKUPS\'  
SET @path = '\\C1-VEEAM\SQL_AGENT_BACKUPS\sage_2k14\'  
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
/*
WHERE name IN('BuyOffersDev','CatalogFeeds','Cosmos','DBAAdmin','DirectedScanning','Hive','HPB_HistoricalDaily','master','MathLab',
'model','msdb','NewReportsDEV','NorthWind','OFS','OFS_Assorted','PostageService','pubs','ReportsView','Sandbox','Sandbox_RD','VisNetic MailFlow',
'VisNetic_History','VisNetic_MailFlow');*/

WHERE name IN
('master','model','msdb','OFS','archShelfScan','archSIPS','BuyOffersDev','CatalogFeeds','Cosmos','DBAAdmin','PostageService',
'archHPB_SALES','DirectedScanning','Hive','HPB_HistoricalDaily','MathLab','NewReportsDEV','NorthWind','OFS_Assorted','PCMS_IMPORT','pubs',
'Report_Analytics','Reports','ReportsData','ReportsView','rHPB_Historical','Sandbox','Sandbox_RD','VertexReturns',
'VisNetic MailFlow','VisNetic_History','VisNetic_MailFlow','BakerTaylor','Buy_Analytics','BUYS','Catalog',
'Customers','Gardner','HPB_INV','HPB_SALES','ISIS','rILS_DATA','Monsoon','DEJ_Temp','Base_Analytics_Cashew','Buy_Analytics_Cashew',
'C1-INFDB','WMS_ILS','WMS_AR_ILS')

 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

WHILE @@FETCH_STATUS = 0   
BEGIN   
--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
   SET @fileMonth = (select format(SYSDATETIME(), 'MM'))
   SET @fileDay = (select format(SYSDATETIME(), 'dd'))
   SET @fileYear = (select format(SYSDATETIME(), 'yyyy'))
   PRINT @fileMonth
   PRINT @fileDay
   PRINT @fileYear


   SET @fileHour = (select format(SYSDATETIME(), 'HH'))
   SET @fileMinute = (select format(SYSDATETIME(), 'mm'))
   SET @fileSecond = (select format(SYSDATETIME(), 'ss'))
   PRINT @fileHour
   PRINT @fileMinute
   PRINT @fileSecond

   SET @fileName = @path + @ServerName + '#' + @name + '#' + @fileYear + '-' + @fileMonth + '-' + @fileDay  + 'T' + @fileHour + @fileMinute + @fileSecond + '#Full' + '.BAK'  
   PRINT @fileName

   --SET @fileName = @path + 'SAGE_' + @name + '_' + @fileDate + '_Full' + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName  WITH COMPRESSION, STATS = 1
   PRINT @name
   SET @DB_Backup = @DB_Backup + 1 

   SET @fileName = @path + @ServerName + '#' + @name + '#' + 'Complete' + '.TXT'  
   PRINT @fileName

   BACKUP DATABASE [DEJ_Temp] TO  
   DISK = @FileName
   WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10

   FETCH NEXT FROM db_cursor INTO @name   
END   

--CLOSE tb_cursor   
--DEALLOCATE tb_cursor
 

CLOSE db_cursor   
DEALLOCATE db_cursor

PRINT 'Number of Databases backed up = '
PRINT @DB_Backup