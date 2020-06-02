DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @path VARCHAR(256) -- path for backup files 
DECLARE @CreateDate DateTime;

SET @CreateDate = GETDATE()
PRINT @CreateDate
SET @CreateDate = (DATEADD(day,-1,@CreateDate))
PRINT @CreateDate

SELECT @fileDate = CONVERT(VARCHAR(20),@CreateDate,112) 
PRINT @filedate

SET @path = '\\mesquite\E$\backupfromsequoia-vm\sequoia_DBAAlerts_' + @fileDate + '_.BAK'
PRINT @path


RESTORE DATABASE [S_DBAAlerts] 

FROM  DISK = @path
--FROM  DISK = N'E:\BackupFromSequoia-VM\sequoia_DBAAlerts_bu.BAK' 
WITH  FILE = 1,  MOVE N'DBAAlerts' TO N'F:\MSSQL\Data\Sequoia\S_DBAAlerts.MDF',  
MOVE N'DBAAlerts_log' TO N'E:\SQLLogs_Sequoia\S_DBAAlerts_LOG.LDF',  
NOUNLOAD,  REPLACE,  STATS = 10
GO
