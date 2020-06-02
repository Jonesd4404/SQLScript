USE master;
GO

ALTER DATABASE tempdb 
MODIFY FILE (NAME = temp8, FILENAME = 'F:\MSSQL\DATA\tempdb_mssql_8.ndf');
GO

ALTER DATABASE tempdb 
MODIFY FILE (NAME = templog, FILENAME = 'F:\MSSQL\DATA\templog.ldf');
GO