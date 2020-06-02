DECLARE 
	@DatabaseName nvarchar(30)
	,@AddUserScript nvarchar(MAX)
	,@AddRoleMemberScript nvarchar(MAX)
	,@SQL nvarchar(MAX)
	,@UserName nvarchar(30);

SET @UserName = 'HPB\jsager' --Replace with the User Name Required
SET @AddUserScript = N'CREATE USER [';
SET @AddRoleMemberScript = N'ALTER ROLE db_datareader ADD MEMBER [';

DECLARE DatabaseList CURSOR LOCAL FAST_FORWARD FOR
	SELECT QUOTENAME(name) AS DatabaseName
	FROM sys.databases
	WHERE name IN('archHPB_Sales', 'archShelfScan', 'archSips', 'BakerTaylor', 'BuyOffers', 'BUYS', 'Catalog', 'DirectedScanning', 'Gardner', 'Hive',
	'HPB_Sales', 'ISIS', 'Monsoon', 'ReportsData', 'rHPB_Historical');

OPEN DatabaseList;
WHILE 1 = 1
BEGIN
	FETCH NEXT FROM DatabaseList INTO @DatabaseName;
	IF @@FETCH_STATUS = -1 BREAK;
	SET @SQL = N'USE ' + @DatabaseName + ' ' + @AddUserScript + @UserName + '];';
	PRINT @SQL;
	--EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE ' + @DatabaseName + ' ' + @AddRoleMemberScript + @UserName + '];';
	PRINT @SQL;
	--EXEC sp_executesql @SQL;
END;
CLOSE DatabaseList;
DEALLOCATE DatabaseList;
GO