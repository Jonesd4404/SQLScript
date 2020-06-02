USE [master]
DECLARE @SPID_TO_KILL [INT];
DECLARE @SQL nvarchar(1000)

SET @SPID_TO_KILL =
(SELECT  session_id
FROM    sys.dm_exec_requests  
        CROSS APPLY sys.dm_exec_sql_text(sql_handle)  
		WHERE datediff(SECOND,getdate(),start_time) < - 7200) --running for longer than 2 hours

IF (@SPID_TO_KILL is not NULL)
BEGIN
SET @SQL = 'KILL ' + CAST(@SPID_TO_KILL as varchar(4))
EXEC (@SQL)

--Combines Kill statement with the headings and the query executing more than 2 hours.......
SET @SQL = 'The statement executed was ' + @SQL + CHAR(13) + 'for the following querie' + CHAR(13) + (SELECT  session_id FROM    sys.dm_exec_requests  
CROSS APPLY sys.dm_exec_sql_text(sql_handle)  WHERE datediff(SECOND,getdate(),start_time) < - 7200)

USE msdb
    EXEC sp_send_dbmail
      @profile_name = "SQL2K14_PCMS-SQL-N",
      @recipients = "Dale_Jones@HalfPriceBooks.com",
      @subject = "PCMS-SQL Long Running Queries",
      @body = @SQL
END

IF (@SPID_TO_KILL is null) --To be commented out after testing for a week.......
BEGIN
USE msdb
    EXEC sp_send_dbmail
      @profile_name = "SQL2K14_PCMS-SQL-N",
      @recipients = "Dale_Jones@HalfPriceBooks.com",
      @subject = "PCMS-SQL Long Running Queries",
      @body = "No long running Queries found."
END