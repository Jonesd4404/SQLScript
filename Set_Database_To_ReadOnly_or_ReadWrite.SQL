--Make Database Read Only

USE [master]
GO
ALTER DATABASE [TESTDB] SET READ_ONLY WITH NO_WAIT
GO

--Make Database Read/Write
USE [master]
GO
ALTER DATABASE [TESTDB] SET READ_WRITE WITH NO_WAIT
GO