DECLARE @name VARCHAR(50) -- database name  
--DECLARE @path VARCHAR(256) -- path for backup files  
--DECLARE @fileName VARCHAR(256) -- filename for backup  
--DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
--SET @path = 'C:\Backup\'
--SET @path = '\\sequoia-vm\F$\MSSQL\BackupFromJacaranda-v\Sequoia\'  
 
-- specify filename format
--SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- Exclude these databases
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
  USE @name --Enter the name of the database you want to reindex 
 
DECLARE @TableName varchar(255) 
DECLARE TableCursor CURSOR FOR 
 
SELECT table_name FROM information_schema.tables 
WHERE table_type = 'base table' 
 
OPEN TableCursor 
FETCH NEXT FROM TableCursor INTO @TableName 
WHILE @@FETCH_STATUS = 0 
 
BEGIN 
 DBCC DBREINDEX(@TableName,' ',90) 
 PRINT @TableName
 FETCH NEXT FROM TableCursor INTO @TableName 
END 
 
 CLOSE TableCursor 
 DEALLOCATE TableCursor 
 
   FETCH NEXT FROM db_cursor INTO @name   
END   

 
CLOSE db_cursor   
DEALLOCATE db_cursor