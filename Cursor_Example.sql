--Shows all table names for each database in an Instance

Use master
GO

DECLARE @dbname VARCHAR(50)   
DECLARE @statement NVARCHAR(max)

DECLARE db_cursor CURSOR 
LOCAL FAST_FORWARD
FOR  
SELECT name
FROM MASTER.dbo.sysdatabases
WHERE name NOT IN ('master','model','msdb','tempdb','distribution','ft','ft2')  
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @dbname  
WHILE @@FETCH_STATUS = 0  
BEGIN  

--SELECT @statement = 'use '+@dbname +';'+ 'CREATE USER [TipsDemoUser] 
--FOR LOGIN [TipsDemoUser]; EXEC sp_addrolemember N''db_datareader'', 
--[TipsDemoUser];EXEC sp_addrolemember N''db_datawriter'', [TipsDemoUser]'

SELECT @statement = 'use '+@dbname +';'+ 'SELECT * from information_Schema.tables;SELECT COUNT(*) AS Number_Of_Tables from Information_schema.tables;'

-- EXEC sp_addrolemember N''db_datareader'', 
--[TipsDemoUser];EXEC sp_addrolemember N''db_datawriter'', [TipsDemoUser]'

exec sp_executesql @statement
PRINT @dbname

FETCH NEXT FROM db_cursor INTO @dbname  
END  
CLOSE db_cursor  
DEALLOCATE db_cursor 