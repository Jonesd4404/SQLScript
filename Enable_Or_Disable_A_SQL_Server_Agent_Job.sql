-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'NightlyBackups',  
    @new_name = N'NightlyBackups -- Disabled',  
    @description = N'Nightly backups disabled during server migration.',  
    @enabled = 1 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'BT backup',  
    @new_name = N'BT backup -- Enabled',  
    @description = N'Nightly backup of BT database.',  
    @enabled = 1 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'BT backup -- Enabled',  
    @new_name = N'BT backup -- Disabled',  
    @description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 