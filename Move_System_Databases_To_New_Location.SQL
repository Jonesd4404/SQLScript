/*
To Move system database files follow these steps:
Log in as sa user in SSMS
Take a backup of the user created database for safety.
Kill all sessions connected to the Server from SSMS.
Execute the following command to check the current file location of system databases:*/
USE master;

SELECT * FROM sys.master_files;
--Identify the path and note the current path of the files.
--Use TSQL to change the file path for all database except master:
ALTER DATABASE database_name MODIFY FILE ( NAME = logical_name , FILENAME = 'new_path\os_file_name' )
--Eg:
ALTER DATABASE tempdb
MODIFY FILE ( NAME = tempdev
, FILENAME = "DestinationPath\tempdb.mdf");

ALTER DATABASE tempdb
MODIFY FILE ( NAME = templog
, FILENAME = "DestinationPath\templog.ldf");

ALTER DATABASE model
MODIFY FILE ( NAME = modeldev
, FILENAME = "DestinationPath\model.mdf");

ALTER DATABASE model
MODIFY FILE ( NAME = modellog
, FILENAME = "DestinationPath\modellog.ldf");

ALTER DATABASE msdb
    MODIFY FILE ( NAME = MSDBData
, FILENAME = "DestinationPath\msdbdata.mdf");

ALTER DATABASE msdb
    MODIFY FILE ( NAME = MSDBLog
, FILENAME = "DestinationPath\msdblog.ldf");

/*
Now the file location has been changed.
Make sure to move both ldf and mdf files
In SSMS right click the Server and select properties . Inside properties go to Database Settings . Change the database default locations for Data and Log to the destination path. Log off from the server.
Eg : change C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\ to E:\projects\DataBaseFiles\MSSQL\DATA\
Stop the instance of SQL Server.
Copy the file or files to the new location. Use Robocopy to move the files in order to copy the acccess permissions to the destination folder. Open cmd and run as administrator and use the following command:
robocopy /sec sourceFolder destinationFolder
It's better to go to the source location to run the command. Delete other files other than system database files which are copied. Eg:
 robocopy /sec .\DATA E:\projects\DataBaseFiles\MSSQL\DATA\
(Here we are moving all system database files to new location.)
From the Start menu, point to All Programs, point to Microsoft SQL Server, point to Configuration Tools, and then click SQL Server Configuration Manager.
Perform the follwing steps in SQL Server Configuration Manager:
In the SQL Server Services node, right-click the instance of SQL Server (for example, SQL Server (MSSQLSERVER)) and choose Properties.. In the SQL Server (instance_name) Properties dialog box, click the Startup Parameters tab. In the Existing parameters box, select the –d parameter to move the master data file. Click Update to save the change. In the Specify a startup parameter box, change the parameter to the new path of the master database. In the Existing parameters box, select the –l parameter to move the master log file. Click Update to save the change. In the Specify a startup parameter box, change the parameter to the new path of the master database.
The parameter value for the data file must follow the -d parameter and the value for the log file must follow the -l parameter. The following example shows the parameter values for the default location of the master data file.
-dC:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\master.mdf
-lC:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\mastlog.ldf
If the planned relocation for the master data file is E:\SQLData, the parameter values would be changed as follows:
-dE:\projects\DataBaseFiles\MSSQL\DATA\master.mdf
-lE:\projects\DataBaseFiles\MSSQL\DATA\mastlog.ldf
Stop the instance of SQL Server by right-clicking the instance name and choosing Stop. Restart the instance of SQL Server.
Log in as sa user in SSMS and verify the location of the database files by executing the following query: */
USE master;

    SELECT * FROM sys.master_files;
--All done.