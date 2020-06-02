
--****************************************
SELECT name, recovery_model_desc  
   FROM sys.databases  
      WHERE name = 'model' ;  
GO  

--*****************************************
USE master ;  
ALTER DATABASE model SET RECOVERY FULL ; 

--******** SQL 2000 ************************
SELECT * 
   FROM dbo.sysdatabases  
      WHERE name = 'HPB_ir' ;  
GO  