--Agent history clean up: distribution
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Agent history clean up: distribution',  
    @new_name = N'Agent history clean up: distribution',  
    @description = N'Removes replication agent history from the distribution database.',  
    @enabled = 0 ;  
GO 

 --CDC_Copy_TTB_Items_2WMS
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'CDC_Copy_TTB_Items_2WMS',  
    @new_name = N'CDC_Copy_TTB_Items_2WMS',  
    @description = N'Execute Package: CDC_Copy_TTB_Items_2WMS',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'CDC_MissingTitleUpdate',  
    @new_name = N'CDC_MissingTitleUpdate',  
    @description = N'Execute Package: CDC_MissingTitleUpdate',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'CDC_MissingTitleUpdate',  
    @new_name = N'CDC_MissingTitleUpdate',  
    @description = N'Execute Package: CDC_MissingTitleUpdate',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'CDC_UPC_QOH_Trans_Insert',  
    @new_name = N'CDC_UPC_QOH_Trans_Insert',  
    @description = N'Execute Package: CDC_UPC_QOH_Trans_Insert',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Create New User Accounts',  
    @new_name = N'Create New User Accounts',  
    @description = N'Execute Package: Create New User Accounts',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_CC_RitaAuthVerifyMailer',  
    @new_name = N'DBA_CC_RitaAuthVerifyMailer',  
    @description = N'Execute Package: DBA_CC_RitaAuthVerifyMailer',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_DBFileGrowth_HPB_db',  
    @new_name = N'DBA_DBFileGrowth_HPB_db',  
    @description = N'Execute Package: DBA_DBFileGrowth_HPB_db',  
    @enabled = 0 ;  
GO 
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_Failed SEQUOIA Scheduled Jobs',  
    @new_name = N'DBA_Failed SEQUOIA Scheduled Jobs',  
    @description = N'Execute Package: DBA_Failed SEQUOIA Scheduled Jobs',  
    @enabled = 0 ;  
GO 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_MAINT_FailMaintSendMail',  
    @new_name = N'DBA_MAINT_FailMaintSendMail',  
    @description = N'Execute Package: DBA_MAINT_FailMaintSendMail',  
    @enabled = 0 ;  
GO 
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_MAINT_Log_Reader_Status',  
    @new_name = N'DBA_MAINT_Log_Reader_Status',  
    @description = N'Execute Package: DBA_MAINT_Log_Reader_Status',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_NET_ScheduledTaskList',  
    @new_name = N'DBA_NET_ScheduledTaskList',  
    @description = N'Execute Package: DBA_NET_ScheduledTaskList',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_NET_ScheduledTaskList',  
    @new_name = N'DBA_NET_ScheduledTaskList',  
    @description = N'Execute Package: DBA_NET_ScheduledTaskList',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_SysProcessCopy',  
    @new_name = N'DBA_SysProcessCopy',  
    @description = N'Execute Package: DBA_SysProcessCopy',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBA_SysProcessCopySizer',  
    @new_name = N'DBA_SysProcessCopySizer',  
    @description = N'Execute Package: DBA_SysProcessCopySizer',  
    @enabled = 0 ;  
GO
 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBAAlerts - Shrink Database',  
    @new_name = N'DBAAlerts - Shrink Database',  
    @description = N'Execute Package: DBAAlerts - Shrink Database',  
    @enabled = 0 ;  
GO
 
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DBAAlerts backup',  
    @new_name = N'DBAAlerts backup',  
    @description = N'Execute Package: DBAAlerts backup',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Defrag SR2_BatchDetail',  
    @new_name = N'Defrag SR2_BatchDetail',  
    @description = N'Execute Package: Defrag SR2_BatchDetail',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'distribution backup',  
    @new_name = N'distribution backup',  
    @description = N'Execute Package: distribution backup',  
    @enabled = 0 ;  
GO
 
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Distribution clean up: distribution',  
    @new_name = N'Distribution clean up: distribution',  
    @description = N'Execute Package: Distribution clean up: distribution',  
    @enabled = 0 ;  
GO
 
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DS_AutoSetRDC_MonthEndDate',  
    @new_name = N'DS_AutoSetRDC_MonthEndDate',  
    @description = N'Execute Package: DS_AutoSetRDC_MonthEndDate',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'DS_PMD_UpdateReportItemCode',  
    @new_name = N'DS_PMD_UpdateReportItemCode',  
    @description = N'Execute Package: DS_PMD_UpdateReportItemCode',  
    @enabled = 0 ;  
GO

 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'EmployeeCards_AddAnniversary',  
    @new_name = N'EmployeeCards_AddAnniversary',  
    @description = N'Execute Package: EmployeeCards_AddAnniversary',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'EmployeeCards_LoadCardsToPrint_HR',  
    @new_name = N'EmployeeCards_LoadCardsToPrint_HR',  
    @description = N'Execute Package: EmployeeCards_LoadCardsToPrint_HR',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'EmployeeCards_LoadCardsToPrint_HR',  
    @new_name = N'EmployeeCards_LoadCardsToPrint_HR',  
    @description = N'Execute Package: EmployeeCards_LoadCardsToPrint_HR',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'EmployeeCards_NightlyMaintenance',  
    @new_name = N'EmployeeCards_NightlyMaintenance',  
    @description = N'Execute Package: EmployeeCards_NightlyMaintenance',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Expired subscription clean up',  
    @new_name = N'Expired subscription clean up',  
    @description = N'Execute Package: Expired subscription clean up',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Generate sqldiag',  
    @new_name = N'Generate sqldiag',  
    @description = N'Execute Package: Generate sqldiag',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_db - Shrink Database',  
    @new_name = N'HPB_db - Shrink Database',  
    @description = N'Execute Package: HPB_db - Shrink Database',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_db Full (sequoia_HPB_pm_bu)  backup  + copy to Jacaranda h:\ drive',  
    @new_name = N'HPB_db Full (sequoia_HPB_pm_bu)  backup  + copy to Jacaranda h:\ drive',  
    @description = N'Execute Package: HPB_db Full (sequoia_HPB_pm_bu)  backup  + copy to Jacaranda h:\ drive',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_DIST_dict backup',  
    @new_name = N'HPB_DIST_dict backup',  
    @description = N'HPB_DIST_dict backup',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_iGC backup',  
    @new_name = N'HPB_iGC backup',  
    @description = N'HPB_iGC backup',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_iR backup  + copy to Jacaranda h:\ drive',  
    @new_name = N'HPB_iR backup  + copy to Jacaranda h:\ drive',  
    @description = N'HPB_iR backup  + copy to Jacaranda h:\ drive',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_iRL backup',  
    @new_name = N'HPB_iRL backup',  
    @description = N'HPB_iRL backup',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_pCC backup',  
    @new_name = N'HPB_pCC backup',  
    @description = N'HPB_pCC backup',  
    @enabled = 0 ;  
GO


USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_POS_dict backup',  
    @new_name = N'HPB_POS_dict backup',  
    @description = N'HPB_POS_dict backup',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_Receiving - Shrink Database',  
    @new_name = N'HPB_Receiving - Shrink Database',  
    @description = N'HPB_Receiving - Shrink Database',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'HPB_Receiving_11pm backup  + copy to Jacaranda h:\ drive  - now at 1:15am',  
    @new_name = N'HPB_Receiving_11pm backup  + copy to Jacaranda h:\ drive  - now at 1:15am',  
    @description = N'HPB_Receiving_11pm backup  + copy to Jacaranda h:\ drive  - now at 1:15am',  
    @enabled = 0 ;  
GO
 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'iGC_NewOrders',  
    @new_name = N'iGC_NewOrders',  
    @description = N'iGC_NewOrders',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'iR_CopyToHistory',  
    @new_name = N'iR_CopyToHistory',  
    @description = N'iR_CopyToHistory',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'iR_CreateiRFromTRDaily',  
    @new_name = N'iR_CreateiRFromTRDaily',  
    @description = N'iR_CreateiRFromTRDaily',  
    @enabled = 0 ;  
GO
 
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'iR_PMXactionsCreateUpdates',  
    @new_name = N'iR_PMXactionsCreateUpdates',  
    @description = N'iR_PMXactionsCreateUpdates',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'iR_SmartScheduler_V2',  
    @new_name = N'iR_SmartScheduler_V2',  
    @description = N'iR_SmartScheduler_V2',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'iR_SR2_RunTransactionBatch',  
    @new_name = N'iR_SR2_RunTransactionBatch',  
    @description = N'iR_SR2_RunTransactionBatch',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'iR_TruncateTransactionsDaily',  
    @new_name = N'iR_TruncateTransactionsDaily',  
    @description = N'iR_TruncateTransactionsDaily',  
    @enabled = 0 ;  
GO
 
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'NON_MSMQ_IRL_Process',  
    @new_name = N'NON_MSMQ_IRL_Process',  
    @description = N'NON_MSMQ_IRL_Process',  
    @enabled = 0 ;  
GO
 

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'NON_MSMQ_IRL_Process_ActiveLocations',  
    @new_name = N'NON_MSMQ_IRL_Process_ActiveLocations',  
    @description = N'NON_MSMQ_IRL_Process',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'PosBaseNETMGR backup',  
    @new_name = N'PosBaseNETMGR backup',  
    @description = N'PosBaseNETMGR backup',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Receiving_SR2_UpdateReceivingShipmentsInfo',  
    @new_name = N'Receiving_SR2_UpdateReceivingShipmentsInfo',  
    @description = N'Receiving_SR2_UpdateReceivingShipmentsInfo',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Reinitialize subscriptions having data validation failures',  
    @new_name = N'Reinitialize subscriptions having data validation failures',  
    @description = N'Reinitialize subscriptions having data validation failures',  
    @enabled = 0 ;  
GO


USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'ReorderRequisitionCleanUp',  
    @new_name = N'ReorderRequisitionCleanUp',  
    @description = N'ReorderRequisitionCleanUp',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Replication agents checkup',  
    @new_name = N'Replication agents checkup',  
    @description = N'Replication agents checkup',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'SEQUOIA-HPB_db-1',  
    @new_name = N'SEQUOIA-HPB_db-1',  
    @description = N'SEQUOIA-HPB_db-1',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'sp_SDS_DBSpaceWeekly - List of all DBs, Logs Used/Free + %',  
    @new_name = N'sp_SDS_DBSpaceWeekly - List of all DBs, Logs Used/Free + %',  
    @description = N'sp_SDS_DBSpaceWeekly - List of all DBs, Logs Used/Free + %',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'TruncateLog_BT',  
    @new_name = N'TruncateLog_BT',  
    @description = N'TruncateLog_BT',  
    @enabled = 0 ;  
GO


USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'TruncateLog_DBAAlerts',  
    @new_name = N'TruncateLog_DBAAlerts',  
    @description = N'TruncateLog_DBAAlerts',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'TruncateLog_HPB_db',  
    @new_name = N'TruncateLog_HPB_db',  
    @description = N'TruncateLog_HPB_db',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'TruncateLog_HPB_iR',  
    @new_name = N'TruncateLog_HPB_iR',  
    @description = N'TruncateLog_HPB_iR',  
    @enabled = 0 ;  
GO


USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'TruncateLog_HPB_Receiving',  
    @new_name = N'TruncateLog_HPB_Receiving',  
    @description = N'TruncateLog_HPB_Receiving',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'TruncateLog_HPB_SCustUsers',  
    @new_name = N'TruncateLog_HPB_SCustUsers',  
    @description = N'TruncateLog_HPB_SCustUsers',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'TruncateLog_HPB_SynchData',  
    @new_name = N'TruncateLog_HPB_SynchData',  
    @description = N'TruncateLog_HPB_SynchData',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Update Pre-Order Items',  
    @new_name = N'Update Pre-Order Items',  
    @description = N'Update Pre-Order Items',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'WMS Scheme Items to DIPS Update',  
    @new_name = N'WMS Scheme Items to DIPS Update',  
    @description = N'WMS Scheme Items to DIPS Update',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'WMS Schemes to DIPS Update',  
    @new_name = N'WMS Schemes to DIPS Update',  
    @description = N'WMS Schemes to DIPS Update',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'WMS Ship UPC Items',  
    @new_name = N'WMS Ship UPC Items',  
    @description = N'WMS Ship UPC Items',  
    @enabled = 0 ;  
GO

USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'WMS_UL_ShipmentProcessor',  
    @new_name = N'WMS_UL_ShipmentProcessor',  
    @description = N'WMS_UL_ShipmentProcessor',  
    @enabled = 0 ;  
GO
