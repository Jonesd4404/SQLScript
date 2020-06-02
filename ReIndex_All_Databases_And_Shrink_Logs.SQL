begin
declare @dbname varchar(50)
declare @logname varchar(50)
declare @sql varchar(2000)
declare cDB cursor for select name from sys.databases
open cDB
fetch next from cDB into @dbname
while @@fetch_status=0
begin
exec ('use ['+@dbname+']')
exec ('sp_MSForEachTable @command1="dbcc dbreindex (''?'')"')
begin try
exec ('alter database ['+@dbname+'] set recovery simple')
declare cLog cursor for select name from sys.database_files where type_desc='LOG'
open cLog
fetch next from cLog into @logname
while @@fetch_status=0
begin
begin try
dbcc shrinkfile (@logname,0)
end try begin catch end catch
fetch next from cLog into @logname
end
close cLog
deallocate cLog
dbcc shrinkdatabase (@dbname, TRUNCATEONLY)
exec ('alter database ['+@dbname+'] set recovery full')
end try begin catch end catch
fetch next from cDB into @dbname
end
close cDB
deallocate cDB
end 