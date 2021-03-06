USE [master]
GO

DECLARE	@return_value int,
		@schema varchar(max)

EXEC	@return_value = [dbo].[sp_WhoIsActive]
		@schema = @schema OUTPUT

SELECT	@schema as N'@schema'

SELECT	'Return Value' = @return_value

GO

sp_who5

SP_who2

--Find all DMV objects
--Types: 
--	V=View
--	TF= SQL table-valued function
--	IF= SQL inlined table-valued function
SELECT * FROM sys.all_objects 
WHERE [name] LIKE '%DM_%' AND [type] IN ('V', 'TF', 'IF')
	AND [schema_id] = 4;  --The sys schema has schema_id =4;

	Select * from sys.dm_os_waiting_tasks
	SELECT * from sys.dm_tran_locks
	SELECT * from sys.dm_tran_blocks

	USE [master]
GO
SELECT  session_id
 ,blocking_session_id
 ,wait_time
 ,wait_type
 ,last_wait_type
 ,wait_resource
 ,transaction_isolation_level
 ,lock_timeout
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
GO

	USE [master]
GO
SELECT  --session_id
 COUNT(blocking_session_id)
 --,wait_time
 --,wait_type
 --,last_wait_type
 --,wait_resource
 --,transaction_isolation_level
 --,lock_timeout
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
GO

@Query =
'USE [master]
GO
DECLARE @Blocks INT	
SET @Blocks = 
(SELECT  --session_id
 COUNT(blocking_session_id)
 --,wait_time
 --,wait_type
 --,last_wait_type
 --,wait_resource
 --,transaction_isolation_level
 --,lock_timeout
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0)'




USE [master]
GO
DECLARE @BlockNumber INT;
SET @BlockNumber = (SELECT COUNT(blocking_session_id)
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0)

PRINT @BlockNumber
USE msdb

If @BlockNumber <> 0
BEGIN
--USE msdb
EXEC sp_send_dbmail 
@profile_name='SQL2K8_WEIRWOOD_Mail',
@recipients='DJones2@HPB.com;DGreen@HalfPriceBooks.com',
@subject='Number of Weirwood Query Blocks = ',
@body= @BlockNumber;
END

