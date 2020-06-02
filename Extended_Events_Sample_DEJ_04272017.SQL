SELECT  a.execution_count ,
    OBJECT_NAME(objectid) Name,
    query_text = SUBSTRING( 
    b.text, 
    a.statement_start_offset/2, 
    (    CASE WHEN a.statement_end_offset = -1 
        THEN len(convert(nvarchar(max), b.text)) * 2 
        ELSE a.statement_end_offset 
        END - a.statement_start_offset)/2
    ) ,
    b.dbid ,
    dbname = db_name(23) ,
    b.objectid ,
    a.creation_time,
    a.last_execution_time,
    a.*
FROM            sys.dm_exec_query_stats a 
CROSS APPLY     sys.dm_exec_sql_text(a.sql_handle) as b 
WHERE OBJECT_NAME(objectid) LIKE '%'
ORDER BY a.last_execution_time DESC



SELECT DB_NAME(database_id) AS [Database], database_id  
FROM sys.databases;  

SELECT *  
FROM sys.databases;  

-- Begin Auditing Code ------------------------
CREATE EVENT SESSION [EXEC_SP] ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1), 
     collect_statement=(0)
    ACTION(sqlserver.client_app_name, 
     sqlserver.client_hostname,
     sqlserver.database_id,
     sqlserver.database_name,
     sqlserver.username)
    WHERE (([object_type]=(8272)) 
     AND ([source_database_id]=(23)))) -- replace with your database ID
ADD TARGET package0.asynchronous_file_target
  (
    SET FILENAME = N'E:\DBA_Audit\SP_Exec.xel',
    METADATAFILE = N'E:\DBA_Audit\SP_Exec.xem'
  );
GO

ALTER EVENT SESSION [EXEC_SP] ON SERVER
  STATE = START;
GO
To review events data you can run this query:
;WITH ee_data AS 
(
  SELECT data = CONVERT(XML, event_data)
    FROM sys.fn_xe_file_target_read_file(
   'E:\DBA_Audit\SP_Exec*.xel', 
   'E:\DBA_Audit\SP_Exec*.xem', 
   NULL, NULL
)
),
tab AS
(
SELECT 
  [host] = data.value('(event/action[@name="client_hostname"]/value)[1]','nvarchar(400)'),
  app_name = data.value('(event/action[@name="client_app_name"]/value)[1]','nvarchar(400)'),
  username = data.value('(event/action[@name="username"]/value)[1]','nvarchar(400)'),
  [object_name] = data.value('(event/data[@name="object_name"]/value)[1]','nvarchar(250)'),
  [timestamp] = data.value('(event/@timestamp)[1]','datetime2')
FROM ee_data
)
SELECT DISTINCT [host], app_name, username, MAX([timestamp]) as last_executed, 
  COUNT([object_name]) as number_of_executions, [object_name]
  FROM tab 
  GROUP BY [host], app_name, username, [object_name] ;
