DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @fileHour VARCHAR(4) -- used for backup hour in 24 hour time format 00-23
DECLARE @fileMinute VARCHAR(4) -- used for backup minute 
DECLARE @fileSecond VARCHAR(4) -- used for backup seconds
DECLARE @fileMonth VARCHAR(4) -- used for backup month
DECLARE @fileDay VARCHAR(4) -- used for backup day
DECLARE @fileYear VARCHAR(4) -- used for backup year
DECLARE @serverName VARCHAR(20) -- used for server name
DECLARE @DatabaseName VARCHAR(20) -- used for Database Name
SET @ServerName = 'SAGE';
SET @DatabaseName = 'CatalogFeeds'
 
-- specify database backup directory
SET @path = '\\C1-VEEAM\SQL_AGENT_BACKUPS\sage_2k14\'

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

 SET @fileName = @path + @ServerName + '#' + @DatabaseName + '#' + @fileYear + '-' + @fileMonth + '-' + @fileDay  + 'T' + @fileHour + @fileMinute + @fileSecond + '#Full' + '.BAK'  
 PRINT @fileName

--BACKUP DATABASE [CatalogFeeds] TO  
BACKUP DATABASE [CatalogFeeds] TO 
DISK = @FileName
WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10

 SET @fileName = @path + @ServerName + '#' + @DatabaseName + '#' + 'Complete' + '.TXT'  
 PRINT @fileName

BACKUP DATABASE [DEJ_Temp] TO  
DISK = @FileName
WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO

