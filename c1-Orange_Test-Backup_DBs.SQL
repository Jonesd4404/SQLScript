
--8:19:17 for VM 10 backups of each db on Speedtest_vm, no core of memory limits
--10:11:22 time for 10 backups of each db on Speedtest, no core or memory limits


DECLARE @name VARCHAR(100) -- database name  
DECLARE @tbname VARCHAR(100) -- database name 
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @Count1 VARCHAR(10)
SET @Count1 = 0
 
 --WHILE (@Count1 < 10)
 --BEGIN
-- specify database backup directory
--H:\MSSQL\Backup
SET @path = 'H:\MSSQL\Backup\'
--SET @path = '\\sequoia-vm\F$\MSSQL\BackupFromJacaranda-v\Sequoia\'  
 
-- specify filename format
--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- Exclude these databases

--DECLARE tb_cursor CURSOR FOR  
--SELECT name FROM sys.tables
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

-- OPEN tb_cursor   
--FETCH NEXT FROM tb_cursor INTO @tbname

WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '.BAK'   
   --SET @fileName = @path + @name + @Count1 + '.BAK' 
   BACKUP DATABASE @name TO DISK = @fileName WITH COMPRESSION, STATS = 1
   --PRINT @name + '..' + @tbname
 
   --FETCH NEXT FROM tb_cursor INTO @tbname
   FETCH NEXT FROM db_cursor INTO @name   
END   

--CLOSE tb_cursor   
--DEALLOCATE tb_cursor
 

CLOSE db_cursor   
DEALLOCATE db_cursor

--SET @Count1 = @Count1 + 1
--END

--SELECT * FROM sys.databases
--WHERE table_type = 'base table' 

--backup Test 1 52:06
--backup Test 2 54:17
--backup Test 3 52:44
--backup Test 4 51:27
--backup Test 5 51:11
--backup Test 6 53:32
--backup Test 7 51:29
--backup Test 8 51:00
--backup Test 9 49:46
--backup Test 10 50:07

