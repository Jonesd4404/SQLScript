---- changes the name, description, and enables status of the job NightlyBackups.  
--USE msdb ;  
--GO  

--EXEC dbo.sp_update_job  
--    @job_name = N'NightlyBackups',  
--    @new_name = N'NightlyBackups -- Disabled',  
--    @description = N'Nightly backups disabled during server migration.',  
--    @enabled = 1 ;  
--GO 

---- changes the name, description, and enables status of the job NightlyBackups.  
--USE msdb ;  
--GO  

--EXEC dbo.sp_update_job  
--    @job_name = N'BT backup',  
--    @new_name = N'BT backup -- Enabled',  
--    @description = N'Nightly backup of BT database.',  
--    @enabled = 1 ;  
--GO 

---- changes the name, description, and enables status of the job NightlyBackups.  
--USE msdb ;  
--GO  

--EXEC dbo.sp_update_job  
--    @job_name = N'BT backup -- Enabled',  
--    @new_name = N'BT backup -- Disabled',  
--    @description = N'Nightly backup of BT database.',  
--    @enabled = 0 ;  
--GO

--Agent history clean up: distribution
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'Agent history clean up: distribution',  
    @new_name = N'Agent history clean up: distribution',  
    @description = N'Removes replication agent history from the distribution database.',  
    @enabled = 1 ;  
GO 

 --CDC_Copy_TTB_Items_2WMS
USE msdb ;  
GO  

EXEC dbo.sp_update_job  
    @job_name = N'CDC_Copy_TTB_Items_2WMS',  
    @new_name = N'CDC_Copy_TTB_Items_2WMS',  
    @description = N'Execute Package: CDC_Copy_TTB_Items_2WMS',  
    @enabled = 1 ;  
GO 




 CDC_MissingTitleUpdate
 CDC_UPC_QOH_Trans_Insert
 Create New User Accounts
 DBA_CC_RitaAuthVerifyMailer
 DBA_DBFileGrowth_HPB_db
 DBA_Failed SEQUOIA Scheduled Jobs
 DBA_MAINT_FailMaintSendMail
 DBA_MAINT_Log_Reader_Status
 DBA_NET_ScheduledTaskList
 DBA_SysProcessCopy
 DBA_SysProcessCopySizer
 DBAAlerts - Shrink Database
 DBAAlerts backup
 Defrag SR2_BatchDetail
 distribution backup
 Distribution clean up: distribution
 DS_AutoSetRDC_MonthEndDate
 DS_PMD_UpdateReportItemCode
 EmployeeCards_AddAnniversary
 EmployeeCards_LoadCardsToPrint_HR
 EmployeeCards_NightlyMaintenance
 Expired subscription clean up
 Generate sqldiag
 HPB_db - Shrink Database
 HPB_db Full (sequoia_HPB_pm_bu)  backup  + copy to Jacaranda h:\ drive
 HPB_DIST_dict backup
 HPB_iGC backup
 HPB_iR backup  + copy to Jacaranda h:\ drive
 HPB_iR backup  + copy to Jacaranda h:\ drive
 HPB_iRL backup
 HPB_pCC backup
 HPB_POS_dict backup
 HPB_Receiving - Shrink Database
 HPB_Receiving_11pm backup  + copy to Jacaranda h:\ drive  - now at 1:15am
 iGC_NewOrders
 iR_CopyToHistory
 iR_CreateiRFromTRDaily
 iR_PMXactionsCreateUpdates
 iR_SmartScheduler_V2
 iR_SR2_RunTransactionBatch
 iR_TruncateTransactionsDaily
 master backup
 model backup
 msdb backup
 NON_MSMQ_IRL_Process
 NON_MSMQ_IRL_Process_ActiveLocations
 POS_ClearErrorLogsFolder
 PosBaseNETMGR backup
 Receiving_SR2_UpdateReceivingShipmentsInfo
 Reinitialize subscriptions having data validation failures
 ReorderRequisitionCleanUp
 Replication agents checkup
 SEQUOIA-HPB_db-1
 sp_SDS_DBSpaceWeekly - List of all DBs, Logs Used/Free + %
 TruncateLog_BT
 TruncateLog_DBAAlerts
 TruncateLog_HPB_db
 TruncateLog_HPB_iR
 TruncateLog_HPB_Receiving
 TruncateLog_HPB_SCustUsers
 TruncateLog_HPB_SynchData
 Update Pre-Order Items
 WMS Scheme Items to DIPS Update
 WMS Schemes to DIPS Update
 WMS Ship UPC Items
 WMS_UL_ShipmentProcessor







































