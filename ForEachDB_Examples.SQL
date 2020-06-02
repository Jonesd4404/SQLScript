DECLARE @command varchar(1000) 
SELECT @command = 'USE ? SELECT name FROM sysobjects WHERE xtype = ''U'' ORDER BY name' 
EXEC sp_MSforeachdb @command 




DECLARE @command varchar(1000) 
SELECT @command = 'USE ? select * from sys.database_files' 
EXEC sp_MSforeachdb @command 