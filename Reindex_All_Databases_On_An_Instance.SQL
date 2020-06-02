declare @execstmnt varchar (4000),@tablename varchar(255)

SET ARITHABORT ON
SET QUOTED_IDENTIFIER ON

--reindex
declare TableList cursor  for
	select	'DBCC DBREINDEX (''' + 
	quotename(TABLE_CATALOG,'[]') + '.' + 
	quotename(TABLE_SCHEMA,'[]') + '.' +  
	quotename(TABLE_NAME,'[]') + ''')' , TABLE_NAME
	from 	INFORMATION_SCHEMA.TABLES  
	where	TABLE_TYPE = 'BASE TABLE'
open TableList
fetch next from TableList into @execstmnt , @tablename
while @@fetch_status <> -1 
begin -- while
	exec(@execstmnt)
	fetch next from TableList into @execstmnt ,@tablename
end -- while
close TableList
deallocate TableList
