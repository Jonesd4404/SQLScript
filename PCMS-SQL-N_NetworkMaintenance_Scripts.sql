/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [msdb].[dbo].[sysjobs]
  WHERE name = 'Restore_ReportsData_From_Orange_afterSageUpgrade'

  --Enable jobs
 BEGIN TRAN
 UPDATE [msdb].[dbo].[sysjobs]
 SET enabled = 1
 WHERE name in(
'_ArchiveXML1                      :every day at 2:45am',
'_ArchiveXML3                   :every day at 2:45am',
'_PCMS_HD_NonSales     Z: every 14 min from 12:00 am to 11:59 pm',
'_PCMS_HD_Sales            Z: every 5 min from 7:33 am to 1:59 am',
'_PCMS_IR_COPY             Z: every 5 min from 7:33 am to 1:59 am',
'_PCMSInventorySips     Z: every 2 min from 12:00 am to 11:59 pm',
'Copy HourlySales to BKHourlySales     :every day at 2:00am',
'Copy Max User Role',
'CopytoBKTablesandDeletefromInput  :every day at 5:00am',
'CopyUserData                 :Once Daily at 5:30AM',
'Create Daily Store Daily Control  : every day at 2:00am',
'Delta Maintenance           :every day at 2:30am',
'HOUSEKEEPING    :Every Day at 4:15 AM',
'Populate_Buy_SIPS_Summary',
'Sales History Maintenance  :every day at 5:00am',
'XMLHistoryMaintenance  :every day at 5:00am')
  --ROLLBACK TRAN
  --COMMIT TRAN

 --Diable jobs
 BEGIN TRAN
 UPDATE [msdb].[dbo].[sysjobs]
 SET enabled = 0
  WHERE name in(
'_ArchiveXML1                      :every day at 2:45am',
'_ArchiveXML3                   :every day at 2:45am',
'_PCMS_HD_NonSales     Z: every 14 min from 12:00 am to 11:59 pm',
'_PCMS_HD_Sales            Z: every 5 min from 7:33 am to 1:59 am',
'_PCMS_IR_COPY             Z: every 5 min from 7:33 am to 1:59 am',
'_PCMSInventorySips     Z: every 2 min from 12:00 am to 11:59 pm',
'Copy HourlySales to BKHourlySales     :every day at 2:00am',
'Copy Max User Role',
'CopytoBKTablesandDeletefromInput  :every day at 5:00am',
'CopyUserData                 :Once Daily at 5:30AM',
'Create Daily Store Daily Control  : every day at 2:00am',
'Delta Maintenance           :every day at 2:30am',
'HOUSEKEEPING    :Every Day at 4:15 AM',
'Populate_Buy_SIPS_Summary',
'Sales History Maintenance  :every day at 5:00am',
'XMLHistoryMaintenance  :every day at 5:00am')
  --ROLLBACK TRAN
  --COMMIT TRAN
