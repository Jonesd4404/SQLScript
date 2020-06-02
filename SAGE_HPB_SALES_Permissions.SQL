USE [master]
RESTORE DATABASE [HPB_SALES] 
FROM  DISK = N'G:\DEJ_HPB_SALES_03212018.BAK' 
WITH  FILE = 1,  MOVE N'HPB_SALES_Log' TO N'E:\SQLLogs\HPB_SALES.ldf',  NOUNLOAD,  REPLACE,  STATS = 5

GO



--======================================================================================
--==== IMPORTANT: Before executing these scripts check the  details to ensure they  ====
--==== are valid. For instance when crossing domains                                ====
--======================================================================================

/*No certificates found*/
/*Scripting all database users and schemas
===================================================================================Note: these are the users found in the database, but they may not all be valid, check them first*/IF (SELECT name FROM sys.database_principals WHERE name = 'AutoEmail') IS NULLBEGINCREATE USER [AutoEmail] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [AutoEmail]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\bdupuy') IS NULLBEGINCREATE USER [HPB\bdupuy] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [HPB\bdupuy]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\dgreen') IS NULLBEGINCREATE USER [HPB\dgreen] FOR LOGIN [HPB\dgreen] WITH DEFAULT_SCHEMA = [HPB\dgreen]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\Tracy_Dennis') IS NULLBEGINCREATE USER [HPB\Tracy_Dennis] FOR LOGIN [HPB\TDennis] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'VertexAdmin') IS NULLBEGINCREATE USER [VertexAdmin] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\mthomason') IS NULLBEGINCREATE USER [HPB\mthomason] FOR LOGIN [HPB\mthomason] WITH DEFAULT_SCHEMA = [HPB\mthomason]END

IF (SELECT name FROM sys.database_principals WHERE name = 'ReportReader') IS NULLBEGINCREATE USER [ReportReader] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [ReportReader]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\rfisher') IS NULLBEGINCREATE USER [HPB\rfisher] FOR LOGIN [HPB\rfisher] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\ajorda') IS NULLBEGINCREATE USER [HPB\ajorda] FOR LOGIN [HPB\ajorda] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\BShankle') IS NULLBEGINCREATE USER [HPB\BShankle] FOR LOGIN [HPB\BShankle] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'SICCProc') IS NULLBEGINCREATE USER [SICCProc] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\Anthony_Le') IS NULLBEGINCREATE USER [HPB\Anthony_Le] FOR LOGIN [HPB\ALe] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'isisworker') IS NULLBEGINCREATE USER [isisworker] WITHOUT LOGIN WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\RKeck') IS NULLBEGINCREATE USER [HPB\RKeck] FOR LOGIN [HPB\RKeck] WITH DEFAULT_SCHEMA = [dbo]END

IF (SELECT name FROM sys.database_principals WHERE name = 'HPB\JSager') IS NULLBEGINCREATE USER [HPB\JSager] FOR LOGIN [HPB\jsager] WITH DEFAULT_SCHEMA = [HPB\JSager]END

/*No certificated users found*/
/*Scripting all user schema permissions
===================================================================================*/
/*No database roles found*/
/*No application roles found*/
/*No nested roles found*/
/*Scripting all database and connection GRANTS
===================================================================================*/GRANT CONNECT TO [AutoEmail]GRANT CONNECT TO [HPB\bdupuy]GRANT CONNECT TO [HPB\dgreen]GRANT CONNECT TO [HPB\Tracy_Dennis]GRANT CONNECT TO [VertexAdmin]GRANT CONNECT TO [HPB\mthomason]GRANT CONNECT TO [ReportReader]GRANT CONNECT TO [HPB\rfisher]GRANT CONNECT TO [HPB\ajorda]GRANT SHOWPLAN TO [HPB\ajorda]GRANT CONNECT TO [HPB\BShankle]GRANT CONNECT TO [SICCProc]GRANT CONNECT TO [HPB\Anthony_Le]GRANT CONNECT TO [isisworker]GRANT CONNECT TO [HPB\RKeck]GRANT CONNECT TO [HPB\JSager]
/*Scripting all database user object GRANTS
===================================================================================*/
GRANT EXECUTE ON [dbo].[dt_addtosourcecontrol] TO [public]
GRANT EXECUTE ON [dbo].[dt_addtosourcecontrol_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_adduserobject] TO [public]
GRANT EXECUTE ON [dbo].[dt_adduserobject_vcs] TO [public]
GRANT EXECUTE ON [dbo].[dt_checkinobject] TO [public]
GRANT EXECUTE ON [dbo].[dt_checkinobject_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_checkoutobject] TO [public]
GRANT EXECUTE ON [dbo].[dt_checkoutobject_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_displayoaerror] TO [public]
GRANT EXECUTE ON [dbo].[dt_displayoaerror_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_droppropertiesbyid] TO [public]
GRANT EXECUTE ON [dbo].[dt_dropuserobjectbyid] TO [public]
GRANT EXECUTE ON [dbo].[dt_generateansiname] TO [public]
GRANT EXECUTE ON [dbo].[dt_getobjwithprop] TO [public]
GRANT EXECUTE ON [dbo].[dt_getobjwithprop_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_getpropertiesbyid] TO [public]
GRANT EXECUTE ON [dbo].[dt_getpropertiesbyid_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_getpropertiesbyid_vcs] TO [public]
GRANT EXECUTE ON [dbo].[dt_getpropertiesbyid_vcs_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_isundersourcecontrol] TO [public]
GRANT EXECUTE ON [dbo].[dt_isundersourcecontrol_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_removefromsourcecontrol] TO [public]
GRANT EXECUTE ON [dbo].[dt_setpropertybyid] TO [public]
GRANT EXECUTE ON [dbo].[dt_setpropertybyid_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_validateloginparams] TO [public]
GRANT EXECUTE ON [dbo].[dt_validateloginparams_u] TO [public]
GRANT EXECUTE ON [dbo].[dt_vcsenabled] TO [public]
GRANT EXECUTE ON [dbo].[dt_verstamp006] TO [public]
GRANT EXECUTE ON [dbo].[dt_verstamp007] TO [public]
GRANT EXECUTE ON [dbo].[dt_whocheckedout] TO [public]
GRANT EXECUTE ON [dbo].[dt_whocheckedout_u] TO [public]
GRANT DELETE ON [dbo].[dtproperties] TO [public]
GRANT INSERT ON [dbo].[dtproperties] TO [public]
GRANT REFERENCES ON [dbo].[dtproperties] TO [public]
GRANT SELECT ON [dbo].[dtproperties] TO [public]
GRANT UPDATE ON [dbo].[dtproperties] TO [public]

/*Scripting all database user role permissions
===================================================================================*/EXEC sp_addrolemember 'db_datareader', 'AutoEmail'EXEC sp_addrolemember 'db_datareader', 'HPB\bdupuy'EXEC sp_addrolemember 'db_datareader', 'HPB\dgreen'EXEC sp_addrolemember 'db_datareader', 'HPB\Tracy_Dennis'EXEC sp_addrolemember 'db_datareader', 'VertexAdmin'EXEC sp_addrolemember 'db_datareader', 'HPB\mthomason'EXEC sp_addrolemember 'db_datareader', 'ReportReader'EXEC sp_addrolemember 'db_owner', 'HPB\rfisher'EXEC sp_addrolemember 'db_datareader', 'HPB\ajorda'EXEC sp_addrolemember 'db_datawriter', 'HPB\ajorda'EXEC sp_addrolemember 'db_datareader', 'HPB\BShankle'EXEC sp_addrolemember 'db_datawriter', 'HPB\BShankle'EXEC sp_addrolemember 'db_datareader', 'SICCProc'EXEC sp_addrolemember 'db_owner', 'HPB\Anthony_Le'EXEC sp_addrolemember 'db_datareader', 'isisworker'EXEC sp_addrolemember 'db_datareader', 'HPB\RKeck'EXEC sp_addrolemember 'db_datawriter', 'HPB\RKeck'EXEC sp_addrolemember 'db_datareader', 'HPB\JSager'
--Finished!
