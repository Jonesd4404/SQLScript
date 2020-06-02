/****** Script for SelectTopNRows command from SSMS  ******/
--DB on WitchHazel

SELECT TOP (1000) [GLOBALCONFIGID]
      ,[CATEGORY]
      ,[PARAMETER]
      ,[PARAMVALUE]
      ,[DESCRIPTION]
  FROM [servicedesk].[dbo].[GlobalConfig]
  WHERE DESCRIPTION LIKE '%DOMAIN%'
  ORDER BY Category


  SELECT *
  INTO [servicedesk].[dbo].[GlobalConfig_03122019_DEJ_BACKUP]
  FROM [servicedesk].[dbo].[GlobalConfig]

  SELECT * FROM [servicedesk].[dbo].[GlobalConfig]
  WHERE GLOBALCONFIGID = 201

  BEGIN TRAN
  UPDATE [servicedesk].[dbo].[GlobalConfig]
  SET PARAMVALUE = 'false'
  WHERE GLOBALCONFIGID = 201
  --ROLLBACK TRAN
  --COMMIT TRAN

