DECLARE @name VARCHAR(100) -- database name  
DECLARE @tbname VARCHAR(100) -- database name 
--DECLARE @path VARCHAR(256) -- path for backup files  
--DECLARE @fileName VARCHAR(256) -- filename for backup  
--DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
--SET @path = 'C:\Backup\'
SET @path = '\\sequoia-vm\F$\MSSQL\BackupFromJacaranda-v\Sequoia\'  
 
-- specify filename format
--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- Exclude these databases

DECLARE tb_cursor CURSOR FOR  
SELECT name FROM sys.tables
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

 OPEN tb_cursor   
FETCH NEXT FROM tb_cursor INTO @tbname

WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '.DIF'  
   BACKUP DATABASE @name TO DISK = @fileName  
   PRINT @name + '..' + @tbname
 
   FETCH NEXT FROM tb_cursor INTO @tbname
   FETCH NEXT FROM db_cursor INTO @name   
END   

CLOSE tb_cursor   
DEALLOCATE tb_cursor
 

CLOSE db_cursor   
DEALLOCATE db_cursor

--SELECT * FROM sys.databases
--WHERE table_type = 'base table' 