USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_backup_All_Database_For_C1-VEEAM]    Script Date: 02/12/2019 11:11:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DECLARE @name VARCHAR(100) -- database name  
DECLARE @tbname VARCHAR(100) -- database name 
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
SET @path = 'C:\C1-INFDB_SQL_Backups\' 

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
   SET @fileName = @path + 'C1-INFDB_' + @name +'_' + @fileDate + '_FULL' + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName
   PRINT @name
   
   FETCH NEXT FROM db_cursor INTO @name   
END   
 
CLOSE db_cursor   
DEALLOCATE db_cursor


