--***************** Run the top section on Sequoia Connection **********************
DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
--SET @path = 'C:\Backup\'
SET @path = '\\sequoia-vm\F$\MSSQL\BackupFromJacaranda-v\Sequoia\'  
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- Exclude these databases
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName  
 
   FETCH NEXT FROM db_cursor INTO @name   
END   

 
CLOSE db_cursor   
DEALLOCATE db_cursor



--********** Run This Section on Sequoia-vm *************************
USE [master]
RESTORE DATABASE [BT] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\BT_20170623.BAK' WITH  FILE = 1,  
MOVE N'BT_Data' TO N'f:\MSSQL\data\BT_Data.MDF',  
MOVE N'BT_Log' TO N'f:\MSSQL\data\BT_Log.LDF',  
NOUNLOAD,  STATS = 1
GO

USE [master]
RESTORE DATABASE [DBAAdmin] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\DBAAdmin_20170623.BAK' WITH  FILE = 1,  
MOVE N'DBAAdmin_Data' TO N'f:\MSSQL\data\DBAAdmin_Data.MDF',  
MOVE N'DBAAdmin_Log' TO N'f:\MSSQL\data\DBAAdmin_Log.LDF',  
NOUNLOAD,  STATS = 1
GO

USE [master]
RESTORE DATABASE [DBAAlerts] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\DBAAlerts_20170623.BAK' WITH  FILE = 1,  
MOVE N'DBAAlerts_Data' TO N'f:\MSSQL\data\DBAAlerts_Data.MDF',  
MOVE N'DBAAlerts_Log' TO N'f:\MSSQL\data\DBAAlerts_log.ldf',  
NOUNLOAD,  STATS = 1
GO

USE [master]
RESTORE DATABASE [rILS] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\rILS_20170623.BAK' WITH  FILE = 1,  
MOVE N'rILS_Data' TO N'f:\MSSQL\data\rILS_Data.MDF',  
MOVE N'rILS_Log' TO N'f:\MSSQL\data\rILS_Log.LDF',  
NOUNLOAD,  STATS = 1
GO

USE [master]
RESTORE DATABASE [pubs] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\pubs_20170623.BAK' WITH  FILE = 1,  
MOVE N'pubs' TO N'f:\MSSQL\data\pubs.mdf',  
MOVE N'pubs_log' TO N'f:\MSSQL\data\pubs_log.ldf',  
NOUNLOAD,  STATS = 1
GO

USE [master]
RESTORE DATABASE [PosBaseNETMGR] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\PosBaseNETMGR_20170623.BAK' WITH  FILE = 1,  
MOVE N'PosBaseNETMGR_Data' TO N'f:\MSSQL\data\PosBaseNETMGR_Data.MDF',  
MOVE N'PosBaseNETMGR_Log' TO N'f:\MSSQL\data\PosBaseNETMGR_Log.LDF',  
NOUNLOAD,  STATS = 1
GO

USE [master]
RESTORE DATABASE [HPB_Receiving] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\HPB_Receiving_BU_20170623.BAK' WITH  FILE = 1,  
MOVE N'HPB_Receiving_Data' TO N'f:\MSSQL\data\HPB_Receiving_data.mdf',  
MOVE N'HPB_Receiving_Log' TO N'f:\MSSQL\data\HPB_Receiving_log.ldf',  
NOUNLOAD,  STATS = 1
GO

USE [master]
RESTORE DATABASE [BT] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\BT_20170623.BAK' WITH  FILE = 1,  
MOVE N'BT_Data' TO N'f:\MSSQL\data\BT_Data.MDF',  
MOVE N'BT_Log' TO N'f:\MSSQL\data\BT_Log.LDF',  
NOUNLOAD,  STATS = 1
GO

USE [master]
RESTORE DATABASE [HPB_DIST_dict] FROM  
DISK = N'F:\MSSQL\BackupFromJacaranda-v\Sequoia\HPB_DIST_dict_20170623.BAK' WITH  FILE = 1,  
MOVE N'HPB_dict_dat' TO N'f:\MSSQL\data\HPB_DIST_dict_Data.mdf',  
MOVE N'HPB_dict_log' TO N'f:\MSSQL\data\HPB_DIST_dict_log.ldf',  
NOUNLOAD,  STATS = 1
GO

