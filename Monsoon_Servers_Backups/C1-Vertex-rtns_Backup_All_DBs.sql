DECLARE @name VARCHAR(100) -- database name  
DECLARE @tbname VARCHAR(100) -- database name 
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
--C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\Backup
--SET @path = 'F:\mssql\Backup\'
--SET @path = '\\c1-vertex-rtns\C$\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\Backup\'
SET @path = '\\sql-nas-backup\bkupcorpsqlserver\bkupcorpsqlserver\c1-Vertex-rtns\'

-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('tempdb')  -- Exclude these databases
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + @fileDate + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName
   PRINT @name
   
   FETCH NEXT FROM db_cursor INTO @name   
END   
 
CLOSE db_cursor   
DEALLOCATE db_cursor
