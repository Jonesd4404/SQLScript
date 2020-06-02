USE [master]
GO
DECLARE @BlockNumber varchar(5);
DECLARE @Sub varchar(50);
SET @BlockNumber = (SELECT COUNT(blocking_session_id)
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0)

SET @Sub = 'Number of current blocks = ' + @BlockNumber
USE msdb
If @BlockNumber >= 5
BEGIN
--USE msdb
EXEC sp_send_dbmail 
@profile_name='SQL2K8_WEIRWOOD_Mail',
@recipients='DJones2@HPB.com;DGreen@HalfPriceBooks.com',
@subject = @Sub,
@query = 
'USE [master]
SELECT  session_id
 ,blocking_session_id
 ,wait_time
 ,wait_type
 ,last_wait_type
 ,wait_resource
 ,transaction_isolation_level
 ,lock_timeout
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0',
@attach_query_result_as_file = 1,
@query_attachment_filename = 'Blocking.txt'
END

