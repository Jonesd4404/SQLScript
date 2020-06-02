DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @fileHour VARCHAR(4) -- used for backup hour in 24 hour time format 00-23
DECLARE @fileMinute VARCHAR(4) -- used for backup minute 
DECLARE @fileSecond VARCHAR(4) -- used for backup seconds
DECLARE @fileMonth VARCHAR(4) -- used for backup month
DECLARE @fileDay VARCHAR(4) -- used for backup day
DECLARE @fileYear VARCHAR(4) -- used for backup year
 
-- specify database backup directory
SET @path = '\\squirrel\F$\MSSQL\BACKUP\'

SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
SET @fileMonth= (SELECT DATEPART(Month, SYSDATETIME()))

IF LEN(@fileMonth) = 1
BEGIN
SET @fileMonth = '0' + @fileMonth
PRINT @FileMonth
END

--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
SET @fileDay= (SELECT DATEPART(Day, SYSDATETIME()))

IF LEN(@fileDay) = 1
BEGIN
SET @fileDay = '0' + @fileDay
PRINT @FileDay
END

SET @fileYear= (SELECT DATEPART(YYYY, SYSDATETIME()))
PRINT @FileYear


SET @fileHour = (select DATEPART(Hour,SYSDATETIME()))
SET @fileMinute = (select DATEPART(Minute,SYSDATETIME()))
SET @fileSecond = (select DATEPART(Second,SYSDATETIME()))

IF LEN(@fileHour) = 1
BEGIN
SET @fileHour = '0' + @fileHour
PRINT @FileHour
END

IF LEN(@fileMinute) = 1
BEGIN
SET @fileMinute = '0' + @fileMinute
PRINT @FileMinute
END

IF LEN(@fileSecond) = 1
BEGIN
SET @fileSecond = '0' + @fileSecond
PRINT @FileSecond
END

 SET @fileName = @path + 'Squirrel#' + 'Master' + '#' +@fileYear + '-' + @fileMonth + '-' + @fileDay + 'T' + @fileHour + @fileMinute + @fileSecond + '#Full' + '.BAK'  
 BACKUP DATABASE [Master] TO DISK = @fileName  WITH COMPRESSION, STATS = 1
 PRINT @fileName

 SET @fileName = @filename + '.Complete'  
 BACKUP DATABASE [DEJ_Test] TO DISK = @fileName  WITH COMPRESSION , STATS = 10
 PRINT @fileName

--MOVE \\Squirrel\F$\MSSQL\BACKUP\Squirrel#Master*.BAK \\c1-veeam\sql_agent_backups\WEIRWOOD-BKUP_2K8R2\
--MOVE \\Squirrel\F$\MSSQL\BACKUP\Squirrel#Master*.Complete \\c1-veeam\sql_agent_backups\WEIRWOOD-BKUP_2K8R2\
