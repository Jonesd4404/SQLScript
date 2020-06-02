
--Shows all bakups on database D database, L Log, I Incremental
--From 
USE msdb ; 
SELECT   backup_set_id ,          
backup_start_date ,          
backup_finish_date ,          
backup_size ,          
recovery_model ,          
[type] 
FROM dbo.backupset 
WHERE database_name = 'Bookworm'