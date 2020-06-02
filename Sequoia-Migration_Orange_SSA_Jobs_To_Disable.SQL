
-- Use on Orange

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS   CCardAccountSetup',  
    @new_name = N'DTS   CCardAccountSetup -- Disabled',  
    @description = N'DTS   CCardAccountSetup disabled during server migration.',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS   CCardSettlementCorp',  
    @new_name = N'DTS   CCardSettlementCorp -- Disabled',  
    @description = N'DTS   CCardSettlementCorp Disabled during server migration',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS   rd_2     Z: 5-20-15 modified',  
    @new_name = N'DTS   rd_2     Z: 5-20-15 modified -- Disabled',  
    @description = N'DTS   rd_2     Z: 5-20-15 modified Disabled.',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS   rd_StoreDailyControl (runs at 9a +11a)',  
    @new_name = N'DTS   rd_StoreDailyControl (runs at 9a +11a)',  
    @description = N'DTS   rd_StoreDailyControl (runs at 9a +11a)',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS   UltiPro Employee Info Import',  
    @new_name = N'DTS   UltiPro Employee Info Import',  
    @description = N'DTS   UltiPro Employee Info Import',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'NON_MSMQ_PcmsInventoryAdjustmentXactions',  
    @new_name = N'NON_MSMQ_PcmsInventoryAdjustmentXactions',  
    @description = N'NON_MSMQ_PcmsInventoryAdjustmentXactions',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'rd_master_0  (orig 8:35p)',  
    @new_name = N'rd_master_0  (orig 8:35p)',  
    @description = N'rd_master_0  (orig 8:35p)',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'rd_master_1  (orig 8:50p)',  
    @new_name = N'rd_master_1  (orig 8:50p)',  
    @description = N'rd_master_1  (orig 8:50p)',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'rd_master_2  - PI removed - is now by itself as "rd_master_PI_for_Joey"   (orig 8:55p)',  
    @new_name = N'rd_master_2  - PI removed - is now by itself as "rd_master_PI_for_Joey"   (orig 8:55p)',  
    @description = N'rd_master_2  - PI removed - is now by itself as "rd_master_PI_for_Joey"   (orig 8:55p)',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'rd_master_3  (orig 9:00p)',  
    @new_name = N'rd_master_3  (orig 9:00p)',  
    @description = N'rd_master_3  (orig 9:00p)',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'rd_master_4  (orig 9:05p)',  
    @new_name = N'rd_master_4  (orig 9:05p)',  
    @description = N'rd_master_4  (orig 9:05p)',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'rd_master_5  (orig 9:10p)',  
    @new_name = N'rd_master_5  (orig 9:10p)',  
    @description = N'rd_master_5  (orig 9:10p)',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'rd_master_PI_for_Joey',  
    @new_name = N'rd_master_PI_for_Joey',  
    @description = N'rd_master_PI_for_Joey',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'UPC Conv - QOH Adj - S&S Trans',  
    @new_name = N'UPC Conv - QOH Adj - S&S Trans',  
    @description = N'UPC Conv - QOH Adj - S&S Trans',  
    @enabled = 0 ;  
GO 