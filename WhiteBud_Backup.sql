DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @FileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @FileHour VARCHAR(4) -- used for backup hour in 24 hour time format 00-23
DECLARE @FileMinute VARCHAR(4) -- used for backup minute 
DECLARE @FileSecond VARCHAR(4) -- used for backup seconds
DECLARE @FileMonth VARCHAR(4) -- used for backup month
DECLARE @FileDay VARCHAR(4) -- used for backup day
DECLARE @FileYear VARCHAR(4) -- used for backup year
 
-- specify database backup directory
SET @path = 'F:\MSSQL\Backup\'

SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
SET @FileMonth= (SELECT DATEPART(Month, SYSDATETIME()))

IF LEN(@FileMonth) = 1
BEGIN
SET @FileMonth = '0' + @FileMonth
PRINT @FileMonth
END

--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
SET @FileDay= (SELECT DATEPART(Day, SYSDATETIME()))

IF LEN(@FileDay) = 1
BEGIN
SET @FileDay = '0' + @FileDay
PRINT @FileDay
END

SET @FileYear= (SELECT DATEPART(YYYY, SYSDATETIME()))
PRINT @FileYear


SET @FileHour = (select DATEPART(Hour,SYSDATETIME()))
SET @FileMinute = (select DATEPART(Minute,SYSDATETIME()))
SET @FileSecond = (select DATEPART(Second,SYSDATETIME()))

IF LEN(@FileHour) = 1
BEGIN
SET @FileHour = '0' + @FileHour
PRINT @FileHour
END

IF LEN(@FileMinute) = 1
BEGIN
SET @FileMinute = '0' + @FileMinute
PRINT @FileMinute
END

IF LEN(@FileSecond) = 1
BEGIN
SET @FileSecond = '0' + @FileSecond
PRINT @FileSecond
END

 SET @FileName = @path + 'WhiteBud#' +  'BFA15' + '#' +@FileYear + '-' + @FileMonth + '-' + @FileDay + 'T' + @FileHour + @FileMinute + @FileSecond + '#Full' + '.BAK'  
 BACKUP DATABASE [BFA15] TO DISK = @FileName  WITH COMPRESSION, STATS = 1
 PRINT @FileName

USE [DBAAdmin]
INSERT INTO Backup_Names
--(DatabaseName)
VALUES
(@FileName)


 SET @FileName = @FileName + '.Complete'  
 BACKUP DATABASE [DEJ_Test] TO DISK = @FileName  WITH COMPRESSION , STATS = 10
 PRINT @FileName

--MOVE \\WhiteBud\F$\MSSQL\BACKUP\WhiteBud#BFA15*.BAK \\c1-veeam\sql_agent_backups\WHITEBUD_SQL2K14--MOVE \\WhiteBud\F$\MSSQL\BACKUP\WhiteBud#BFA15*.Complete \\c1-veeam\sql_agent_backups\WHITEBUD_SQL2K14
--RENAME \\whitebeam\E$\backups\WhiteBud#BFA15*.BAK WhiteBud_BFA15.BAK
--USE [master]
--RESTORE DATABASE [BFA15] FROM  DISK = N'E:\Backups\whitebud_BFA15.bak' WITH  FILE = 1,  MOVE N'GPSBFA10Dat.mdf' TO N'F:\MSSQL\Data--\GPSBFA15Dat.mdf',  MOVE N'GPSBFA15Log.ldf' TO N'E:\SQLLogs\GPSBFA15Log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5
--GO
--DEL E:\backups\WhiteBud_BFA15.BAK


