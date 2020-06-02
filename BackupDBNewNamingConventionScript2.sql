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
SET @path = 'C:\MonsoonBackups\'

--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
SET @fileMonth = (select format(SYSDATETIME(), 'MM'))
SET @fileDay = (select format(SYSDATETIME(), 'dd'))
SET @fileYear = (select format(SYSDATETIME(), 'yyyy'))
--PRINT @fileMonth
--PRINT @fileDay
--PRINT @fileYear


SET @fileHour = (select format(SYSDATETIME(), 'HH'))
SET @fileMinute = (select format(SYSDATETIME(), 'mm'))
SET @fileSecond = (select format(SYSDATETIME(), 'ss'))

 SET @fileName = @path + 'Thicket-01#' + 'dbaadmin' + '#' + @fileYear + '-' + @fileMonth + '-' + @fileDay  + 'T' + @fileHour + @fileMinute + @fileSecond + '#Full' + '.BAK'  
 PRINT @fileName

  SET @fileName = 'C:\MonsoonBackups\' + 'Thicket-01#' + 'dbaadmin' + '#' + (select format(SYSDATETIME(), 'yyyy')) + '-' + 
 (select format(SYSDATETIME(), 'MM'))+ '-' + (select format(SYSDATETIME(), 'dd'))  + 'T' + 
 (select format(SYSDATETIME(), 'HH')) + (select format(SYSDATETIME(), 'mm')) + (select format(SYSDATETIME(), 'ss'))+ '#Full' + '.BAK'  
 PRINT @fileName