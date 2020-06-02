--BS-MailFlow-SQL
--VisNetic Mailflow permissions 09/24/2018 6:57

--======================================================================================
--==== IMPORTANT: Before executing these scripts check the  details to ensure they  ====
--==== are valid. For instance when crossing domains                                ====
--======================================================================================

/*No certificates found*/
/*Scripting all database users and schemas
===================================================================================Note: these are the users found in the database, but they may not all be valid, check them first*/IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\bsmailflowodbc') IS NULLBEGINCREATE USER [HPB\bsmailflowodbc] FOR LOGIN [HPB\bsmailflowodbc] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\sqladmin2k8') IS NULLBEGINCREATE USER [HPB\sqladmin2k8] FOR LOGIN [HPB\sqladmin2k8] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\Cameron_Reid') IS NULLBEGINCREATE USER [HPB\Cameron_Reid] FOR LOGIN [HPB\Cameron_Reid] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'Cameron_Reid') IS NULLBEGINCREATE USER [Cameron_Reid] FOR LOGIN [Cameron_Reid] WITH DEFAULT_SCHEMA = [dbo]END

/*No certificated users found*/
/*Scripting all user schema permissions
===================================================================================*/
/*No database roles found*/
/*No application roles found*/
/*No nested roles found*/
/*Scripting all database and connection GRANTS
===================================================================================*/GRANT CONNECT TO [HPB\bsmailflowodbc]GRANT CONNECT TO [HPB\sqladmin2k8]GRANT CONNECT TO [HPB\Cameron_Reid]GRANT CONNECT TO [Cameron_Reid]
/*No database user object GRANTS found*/
/*Scripting all database user role permissions
===================================================================================*/EXEC sp_addrolemember 'db_owner', 'HPB\bsmailflowodbc'EXEC sp_addrolemember 'db_datareader', 'HPB\bsmailflowodbc'EXEC sp_addrolemember 'db_datawriter', 'HPB\bsmailflowodbc'EXEC sp_addrolemember 'db_datareader', 'HPB\Cameron_Reid'EXEC sp_addrolemember 'db_datareader', 'Cameron_Reid'
--Finished!
