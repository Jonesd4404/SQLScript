--BS-MailFlow-SQL
--VisNetic Mailflow permissions 09/24/2018 6:57

--======================================================================================
--==== IMPORTANT: Before executing these scripts check the  details to ensure they  ====
--==== are valid. For instance when crossing domains                                ====
--======================================================================================

/*No certificates found*/
/*Scripting all database users and schemas
===================================================================================

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\sqladmin2k8') IS NULL

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\Cameron_Reid') IS NULL

IF (SELECT name FROM sys.database_principals WHERE name = 'Cameron_Reid') IS NULL

/*No certificated users found*/
/*Scripting all user schema permissions
===================================================================================*/
/*No database roles found*/
/*No application roles found*/
/*No nested roles found*/
/*Scripting all database and connection GRANTS
===================================================================================*/
/*No database user object GRANTS found*/
/*Scripting all database user role permissions
===================================================================================*/
--Finished!