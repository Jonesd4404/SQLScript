--Script to enable SSA jobs

BEGIN TRAN
UPDATE [msdb].[dbo].[sysjobs]
SET enabled = 1
WHERE name IN(
'Backup_NewReportsDEV',
'Restore_ReportsData_From_Orange',
'Mathlab_StoreLocationMaster_Copy_To_Orange_ReportsData',
'ReportsView - Insert New OFS Cross Ship Data',
'Backup_Report_Analytics',
'Backup_MathLab',
'Restore_Catalog_From_Weirwood',
'HPB_SALES_Restore_Permissions_After_DB_Restore',
'Restore_HPB_SALES_FROM_ORANGE_afterSageUpgrade',
'.rg_restore_Customers from Silverbell                        = tic: 5:02  sec',
'Migration_Backups',
'Backup_Sandbox_RD',
'Backup_System_DBs',
'Restore_HPB_INV_FROM_ORANGE',
'Reset Jay''s Permissions After Database Restores',
'admin_mtce_Add_Brad_Ron_To_DB_DataReader Role and View SP on ISIS after daily restore',
'.....Restore_OFS_PostageService_And_Cosmos_For_Rebekah_Davis',
'Backup_CatalogFeeds',
'Restore_VisNetic_Daily',
'Restore_rILS_Data_rHPB_Historical_Reports_Monsoon',
'Restore_Buys_From_Weirwood',
'Backup_DirectedScanning',
'syspolicy_purge_history',
'Restore_PCMS_IMPORT_From_PCMS-SQL-N',
'Email_Latest_End_Date_For_HPB_SALES',
'Restore_BakerTaylor_From_Silverbell',
'Catalog Export Updates To HPB.com',
'...Admin_Special_Backup_Of_ReportsData_To_G_Drive_For_Brad',
'Backup_ReportsView',
'.Restore_SHOWPLAN_To_HPB\AJorda_After_Morning_Restore',
'Redo Permissions for OffersUser',
'Backup_Sandbox',
'.rg_restore_Gardner_from Silverbell                        = tic: 1:59  sec',
'Restore_ISIS_From_Weirwood',
'RDA_RU_EmployeeMetrics')

--ROLLBACK TRAN
--COMMIT TRAN
