SELECT @@servername

--•	Get the current name of the SQL Server instance for later comparison.
SELECT @@servername
--•	Remove server from the list of known remote and linked servers on the local instance of SQL Server.
EXEC master.dbo.sp_dropserver [ROBIN-SQL]
--•	Define the name of the local instance of SQL Server.
EXEC master.dbo.sp_addserver [Robin-SQL-TEST], local
--•	You have to restart the MSSQL service at this step.
--•	Get the new name of the SQL Server instance for comparison. SELECT @@servername

sp_helpserver