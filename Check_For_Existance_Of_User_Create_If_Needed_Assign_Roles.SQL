USE [Reports]
GO

IF DATABASE_PRINCIPAL_ID('HPB\admtgriffin') IS NULL
BEGIN
    CREATE USER [HPB\admtgriffin] 
    FOR LOGIN [HPB\admtgriffin] WITH DEFAULT_SCHEMA=[dbo]
END




USE [Reports]
GO
EXEC sp_addrolemember N'db_datareader', N'HPB\admtgriffin'
GO
USE [Reports]
GO
EXEC sp_addrolemember N'db_datawriter', N'HPB\admtgriffin'
GO

USE [ReportsData]
GO

IF DATABASE_PRINCIPAL_ID('HPB\admtgriffin') IS NULL
BEGIN
    CREATE USER [HPB\admtgriffin] 
    FOR LOGIN [HPB\admtgriffin] WITH DEFAULT_SCHEMA=[dbo]
END

USE [ReportsData]
GO
EXEC sp_addrolemember N'db_datareader', N'HPB\admtgriffin'
GO
USE [ReportsData]
GO
EXEC sp_addrolemember N'db_datawriter', N'HPB\admtgriffin'
GO

USE [rILS_Data]
GO
IF DATABASE_PRINCIPAL_ID('HPB\admtgriffin') IS NULL
BEGIN
    CREATE USER [HPB\admtgriffin] 
    FOR LOGIN [HPB\admtgriffin] WITH DEFAULT_SCHEMA=[dbo]
END

USE [rILS_Data]
GO
EXEC sp_addrolemember N'db_datawriter', N'HPB\admtgriffin'
USE [rILS_Data]
GO
EXEC sp_addrolemember N'db_datareader', N'HPB\admtgriffin'
GO

USE [Reports]
GO
IF DATABASE_PRINCIPAL_ID('HPB\Trey_Griffin') IS NULL
BEGIN
    CREATE USER [HPB\Trey_Griffin] 
    FOR LOGIN [HPB\Trey_Griffin] WITH DEFAULT_SCHEMA=[dbo]
END

USE [Reports]
GO
EXEC sp_addrolemember N'db_datareader', N'HPB\Trey_Griffin'
GO
USE [Reports]
GO
EXEC sp_addrolemember N'db_datawriter', N'HPB\Trey_Griffin'
GO
USE [ReportsData]
GO
IF DATABASE_PRINCIPAL_ID('HPB\Trey_Griffin') IS NULL
BEGIN
    CREATE USER [HPB\Trey_Griffin] 
    FOR LOGIN [HPB\Trey_Griffin] WITH DEFAULT_SCHEMA=[dbo]
END
USE [ReportsData]
GO
EXEC sp_addrolemember N'db_datareader', N'HPB\Trey_Griffin'
GO
USE [ReportsData]
GO
EXEC sp_addrolemember N'db_datawriter', N'HPB\Trey_Griffin'
GO

USE [rILS_Data]
GO
IF DATABASE_PRINCIPAL_ID('HPB\Trey_Griffin') IS NULL
BEGIN
    CREATE USER [HPB\Trey_Griffin] 
    FOR LOGIN [HPB\Trey_Griffin] WITH DEFAULT_SCHEMA=[dbo]
END

EXEC sp_addrolemember N'db_datawriter', N'HPB\Trey_Griffin'
GO
USE [rILS_Data]
GO
EXEC sp_addrolemember N'db_datareader', N'HPB\Trey_Griffin'
GO
