--Identifying Top Objects Associated with Lock Contention
Use master
SELECT      TOP 100
            OBJECT_NAME(o.object_id, o.database_id) object_nm,
            o.index_id,
            partition_number, 
            page_lock_wait_count, 
            page_lock_wait_in_ms,
            case when mid.database_id is null then 'N' else 'Y' end as missing_index_identified
FROM sys.dm_db_index_operational_stats (db_id('DBName'), NULL, NULL, NULL) o
LEFT OUTER JOIN (SELECT DISTINCT database_id, object_id 
                         FROM sys.dm_db_missing_index_details) as mid 
      ON mid.database_id = o.database_id and mid.object_id = o.object_id
Where  page_lock_wait_count<>0 --and Index_id <> 1
ORDER BY page_lock_wait_count DESC