-- Backup all system and user databases
-- Z. Jary  -  06-26-15
--Redbird is the server
--SQLRETURNS is the instance name.


BACKUP DATABASE [model] TO  [redbird_model_bu]
 WITH NOFORMAT, INIT,  NAME = N'model-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'model'
 and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'model' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''model'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [redbird_model_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [master] TO  [redbird_master_bu]
 WITH NOFORMAT, INIT,  NAME = N'master-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'master'
 and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'master' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''master'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [redbird_master_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [msdb] TO  [redbird_msdb_bu]
 WITH NOFORMAT, INIT,  NAME = N'msdb-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'msdb'
 and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'msdb' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''msdb'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [redbird_msdb_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [VertexReturns] TO  [redbird_VertexReturns_bu]
 WITH NOFORMAT, INIT,  NAME = N'VertexReturns-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'VertexReturns'
 and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'VertexReturns' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''VertexReturns'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [redbird_VertexReturns_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [VertexReturnsDocumentManager] TO  [redbird_VertexReturnsDocumentManager_bu]
 WITH NOFORMAT, INIT,  NAME = N'VertexReturnsDocumentManager-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'VertexReturnsDocumentManager'
 and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'VertexReturnsDocumentManager' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''VertexReturnsDocumentManager'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [redbird_VertexReturnsDocumentManager_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [VertexReturnsReportWriter] TO  [redbird_VertexReturnsReportWriter_bu]
 WITH NOFORMAT, INIT,  NAME = N'VertexReturnsReportWriter-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'VertexReturnsReportWriter'
 and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'VertexReturnsReportWriter' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''VertexReturnsReportWriter'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [redbird_VertexReturnsReportWriter_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

BACKUP DATABASE [VertexReturnsTaxCalendar] TO  [redbird_VertexReturnsTaxCalendar_bu]
 WITH NOFORMAT, INIT,  NAME = N'VertexReturnsTaxCalendar-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'VertexReturnsTaxCalendar'
 and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'VertexReturnsTaxCalendar' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''VertexReturnsTaxCalendar'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  [redbird_VertexReturnsTaxCalendar_bu] WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO