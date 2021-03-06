BACKUP DATABASE [Monsoon] TO  [677Media-LAR-1__MONSOON_Monsoon_pm_bu] WITH NOFORMAT, NOINIT,  NAME = N'Monsoon-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'Monsoon' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'Monsoon' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''Monsoon'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [677Media-LAR-1__MONSOON_Monsoon_pm_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO


BACKUP DATABASE [master] TO  [677Media-LAR-1__MONSOON_master_bu] WITH NOFORMAT, NOINIT,  NAME = N'master-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'master' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'master' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''master'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [677Media-LAR-1__MONSOON_master_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [model] TO  [677Media-LAR-1__MONSOON_model_bu] WITH NOFORMAT, NOINIT,  NAME = N'model-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'model' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'model' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''model'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [677Media-LAR-1__MONSOON_model_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO


BACKUP DATABASE [msdb] TO  [677Media-LAR-1__MONSOON_msdb_bu] WITH NOFORMAT, NOINIT,  NAME = N'msdb-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'msdb' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'msdb' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''msdb'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [677Media-LAR-1__MONSOON_msdb_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
