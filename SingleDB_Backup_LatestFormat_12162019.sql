DECLARE @fileName VARCHAR(512) -- filename for backup  

SET @fileName = 'F:\MSSQL\Backup\' + 'WHITEBEAM#' + 'master' + '#' + (CONVERT(VARCHAR(20),GETDATE(),112) + 'T') + (select format(SYSDATETIME(), 'HH')) + 
(select format(SYSDATETIME(), 'mm')) + (select format(SYSDATETIME(), 'ss')) + '#Full' + '.BAK' 
PRINT @fileName

BACKUP DATABASE [master] TO DISK = @fileName  WITH COMPRESSION, STATS = 1
SET @fileName = 'F:\MSSQL\Backup\' + 'WHITEBEAM#' + 'Master' + '#Complete' + '.TXT'  
BACKUP DATABASE [master] TO DISK = @fileName  WITH COMPRESSION, STATS = 1
 

