DECLARE @CounterPrefix NVARCHAR(30) 
SET @CounterPrefix = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:'
ELSE 'MSSQL$' + @@SERVICENAME + ':'
END ; -- Capture the first counter set 
SELECT  CAST(1 AS INT) AS collection_instance , [OBJECT_NAME] , counter_name , instance_name ,         
cntr_value , cntr_type , CURRENT_TIMESTAMP AS collection_time INTO #perf_counters_init FROM
sys.dm_os_performance_counters 
WHERE   ( OBJECT_NAME = @CounterPrefix + 'Access Methods' AND counter_name = 'Full Scans/sec')     OR 
( OBJECT_NAME = @CounterPrefix + 'Access Methods' AND counter_name = 'Index Searches/sec')         OR 
( OBJECT_NAME = @CounterPrefix + 'Buffer Manager' AND counter_name = 'Lazy Writes/sec')            OR 
( OBJECT_NAME = @CounterPrefix + 'Buffer Manager' AND counter_name = 'Page life expectancy')       OR 
( OBJECT_NAME = @CounterPrefix + 'General Statistics' AND counter_name = 'Processes Blocked')      OR 
( OBJECT_NAME = @CounterPrefix + 'General Statistics' AND counter_name = 'User Connections')       OR 
( OBJECT_NAME = @CounterPrefix + 'Locks' AND counter_name = 'Lock Waits/sec')                      OR 
( OBJECT_NAME = @CounterPrefix + 'Locks' AND counter_name = 'Lock Wait Time (ms)')                 OR 
( OBJECT_NAME = @CounterPrefix + 'SQL Statistics' AND counter_name = 'SQL Re-Compilations/sec')    OR 
( OBJECT_NAME = @CounterPrefix + 'Memory Manager'    AND counter_name = 'Memory Grants Pending')   OR 
( OBJECT_NAME = @CounterPrefix + 'SQL Statistics'    AND counter_name = 'Batch Requests/sec')      OR 
( OBJECT_NAME = @CounterPrefix + 'SQL Statistics'    AND counter_name = 'SQL Compilations/sec') 
 
-- Wait on Second between data collection WAITFOR DELAY '00:00:01' 
 
-- Capture the second counter set 
SELECT  CAST(2 AS INT) AS collection_instance , OBJECT_NAME , counter_name , instance_name , 
cntr_value , cntr_type , 
CURRENT_TIMESTAMP AS collection_time INTO #perf_counters_second 
FROM sys.dm_os_performance_counters 
WHERE   
(OBJECT_NAME = @CounterPrefix + 'Access Methods' AND counter_name = 'Full Scans/sec')         OR 
( OBJECT_NAME = @CounterPrefix + 'Access Methods' AND counter_name = 'Index Searches/sec')    OR
( OBJECT_NAME = @CounterPrefix + 'Buffer Manager' AND counter_name = 'Lazy Writes/sec')       OR 
( OBJECT_NAME = @CounterPrefix + 'Buffer Manager' AND counter_name = 'Page life expectancy')  OR 
( OBJECT_NAME = @CounterPrefix + 'General Statistics' AND counter_name = 'Processes Blocked') OR 
( OBJECT_NAME = @CounterPrefix + 'General Statistics' AND counter_name = 'User Connections' ) 


SELECT * FROM #perf_counters_init

SELECT * FROM #perf_counters_second