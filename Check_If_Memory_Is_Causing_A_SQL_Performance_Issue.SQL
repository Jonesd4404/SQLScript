SELECT current_workers_count, scheduler_id, cpu_id
               status, is_online, failed_to_create_worker
FROM sys.dm_os_schedulers
WHERE status='visible online'
GO
