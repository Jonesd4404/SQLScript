SELECT * 
FROM 
sys.dm_exec_connections AS Blocking 
JOIN 
sys.dm_exec_requests AS Blocked 
ON 
Blocking.session_id = Blocked.blocking_session_id 
JOIN sys.dm_os_waiting_tasks 
AS Waits  
ON Blocked.session_id = Waits.session_id 
RIGHT OUTER JOIN sys.dm_exec_sessions Sess  
ON Blocking.session_id = sess.session_id 
CROSS APPLY sys.dm_exec_sql_text(Blocking.most_recent_sql_handle) AS BlockingSQL 
CROSS APPLY sys.dm_exec_sql_text(Blocked.sql_handle) AS BlockedSQL