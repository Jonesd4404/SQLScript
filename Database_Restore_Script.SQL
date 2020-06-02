RESTORE DATABASE [HIVE] 
FROM  DISK = N'F:\MSSQL\BackupFromSilverbell\silverbell_Hive_compressed_bu.bak' 
WITH  FILE = 1,  MOVE N'HIVE_log' TO N'E:\SQLLogs\HIVE.ldf',  NOUNLOAD,  REPLACE,  STATS = 10
GO