-- Create Test DB
CREATE DATABASE [myDB] GO
-- Take the Database Offline
ALTER DATABASE [myDB] SET OFFLINE WITH
ROLLBACK IMMEDIATE
GO
-- Take the Database Online
ALTER DATABASE [myDB] SET ONLINE
GO
-- Clean up
DROP DATABASE [myDB] GO

Joyesh let me know if this answe