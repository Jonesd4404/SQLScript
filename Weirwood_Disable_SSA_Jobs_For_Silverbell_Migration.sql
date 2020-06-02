-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Copy_Locations',  
    --@new_name = N'NightlyBackups -- Disabled',  
    --@description = N'Nightly backups disabled during server migration.',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Copy_PM_to_PMSequoia',  
    --@new_name = N'BT backup -- Enabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

-- changes the name, description, and enables status of the job NightlyBackups.  
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Copy_ProductTypesSequoia',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_Almond_InventoryCodes',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_iSalesDiPSInventoryControl_Almond_ReportsData',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_SIPS_ClearanceItemCode',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_SipsPriceChanges_Almond_ReportsData',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_SipsProductTypes_Almond_ReportsData',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_SipsProductTypes_rHPB_Historical',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_SipsSalesHistory_Almond_ReportsData',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_SIPSSIHDailyToCopy                                            Z: every 9 min from 8:30 am - 2:00 am',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DTS_SubjectSummary_Almond_ReportsData',  
    --@new_name = N'BT backup -- Disabled',  
    --@description = N'Nightly backup of BT database.',  
    @enabled = 0 ;  
GO 