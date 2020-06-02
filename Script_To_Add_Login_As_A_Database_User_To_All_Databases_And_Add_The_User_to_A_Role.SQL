DECLARE 
	@DatabaseName nvarchar(30)
	,@AddUserScript nvarchar(MAX)
	,@AddRoleMemberScript nvarchar(MAX)
	,@SQL nvarchar(MAX);

SET @AddUserScript = N'CREATE USER [SomeLogin];';
SET @AddRoleMemberScript = N'ALTER ROLE db_datareader ADD MEMBER [SomeLogin];';

DECLARE DatabaseList CURSOR LOCAL FAST_FORWARD FOR
	SELECT QUOTENAME(name) AS DatabaseName
	FROM sys.databases
	WHERE name NOT IN('master', 'model', 'msdb');

OPEN DatabaseList;
WHILE 1 = 1
BEGIN
	FETCH NEXT FROM DatabaseList INTO @DatabaseName;
	IF @@FETCH_STATUS = -1 BREAK;
	SET @SQL = N'USE ' + @DatabaseName + ' ' + @AddUserScript;
	PRINT @SQL;
	EXEC sp_executesql @SQL;
	PRINT @SQL;
	SET @SQL = N'USE ' + @DatabaseName + ' ' + @AddRoleMemberScript;
	EXEC sp_executesql @SQL;
END;
CLOSE DatabaseList;
DEALLOCATE DatabaseList;
GO