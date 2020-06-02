Make Database Read Only
1
2
3
4
USE [master]
GO
ALTER DATABASE [TESTDB] SET READ_ONLY WITH NO_WAIT
GO
Make Database Read/Write
1
2
3
4
USE [master]
GO
ALTER DATABASE [TESTDB] SET READ_WRITE WITH NO_WAIT
GO