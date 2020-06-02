DECLARE @fileName VARCHAR(256) -- filename for backup 
 DECLARE @fileName2 VARCHAR(256) -- filename for backup 
 DECLARE @NameLength int
 --F:\MSSQL\Backup\WhiteBud#BFA09#2020-03-13T112112#Full.BAK.Complete
SET @fileName = (SELECT MAX( [DatabaseName]) FROM [DBAAdmin].[dbo].[Backup_Names]
WHERE DatabaseName LIKE 'F:\MSSQL\Backup\WhiteBud#BFA09%')
PRINT @fileName
SET @NameLength = LEN(@fileName)
PRINT @NameLength

SET @fileName2 = RIGHT(@fileName, @NameLength - 16)
PRINT @fileName2 

SET @fileName2 = 'E:\backups\' + @fileName2
PRINT @fileName2

--SET @fileName2 = 'E:\Backups\WhiteBud#BFA09#2020-03-13T141602#Full.BAK'
PRINT @fileName2


USE [master]
RESTORE DATABASE [BFA09] 
FROM  
DISK = @fileName2
--DISK = N'E:\Backups\whitebud#BFA09*.bak' 
WITH  FILE = 1,  MOVE N'GPSBOOKDat.mdf' TO N'F:\MSSQL\Data\GPSBFA09Dat.mdf',  MOVE N'GPSBOOKLog.ldf' TO N'E:\SQLLogs\GPSBFA09Log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5

GO

/*
DELETE FROM [DBAAdmin].[dbo].[Backup_Names]
WHERE DatabaseName LIKE 'F:\MSSQL\Backup\WhiteBud#BFA09%'
*/