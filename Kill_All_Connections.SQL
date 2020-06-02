-- =============================================
-- Author:        Nicholas Rogoff
-- Create date: 04/03/2010
-- Description:    Script that Kills all connections to a database
-- except the current one
-- http://blog.nicholasrogoff.com/2010/09/01/sql-script-to-kill-all-connections-to-a-sql-server-database/
-- Kill all connections to a SQL Server database
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
DECLARE    @execSql NVARCHAR(1000)
DECLARE @databaseName VARCHAR(100)
DECLARE @NoKilled INT

exec sp_who2

-- *** CHANGE THE NAME OF THE DATABASE *** ---
SET @databaseName = 'TexasBookman_NOP'   
  
PRINT 'START: Killing active connections to the "' + @databaseName + '" database'  
 
-- Count Connections
select @NoKilled = COUNT(*)  
from master.dbo.sysprocesses   
where db_name(dbid) = @databaseName   
 and  
 DBID <> 0   
 and  
 spid <> @@spid 
  
-- Create the sql to kill the active database connections   
set @execSql = ''  
select @execSql = @execSql + 'kill ' + convert(char(10), spid) + ' '  
from master.dbo.sysprocesses   
where db_name(dbid) = @databaseName   
 and  
 DBID <> 0   
 and  
 spid <> @@spid   

exec (@execSql)   
 
PRINT 'END: Killed "' + CAST(@NoKilled AS VARCHAR(4)) 
+ '" active connections to the "' + @databaseName + '" database'

print @execSql 

exec sp_who2

/*
-- Z: increased from 10 to 20
print 'waitfor delay 00:00:20'
select GETDATE()
waitfor delay '00:00:20'
select GETDATE()
print 'done-waitfor delay 00:00:20'
*/

-- Z: 3/20-14  increased from 20 to 30
print 'waitfor delay 00:00:30'
select GETDATE()
waitfor delay '00:00:30'
select GETDATE()
print 'done-waitfor delay 00:00:30'

exec sp_who2
