USE [master] --Script Created for Jay Sager to add his role membership on Sage
GO

/****** Object:  Login [HPB\jsager]    Script Date: 5/5/2017 9:30:16 AM ******/
CREATE LOGIN [HPB\jsager] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]


GO
USE [archHPB_Sales]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager];  

USE [archShelfScan]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [archSips]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [BakerTaylor]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [BuyOffers]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [BUYS]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [Catalog]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [DirectedScanning]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [Gardner]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [Hive]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [HPB_Sales]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [ISIS]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [Monsoon]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [ReportsData]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 

USE [rHPB_Historical]
ALTER ROLE db_datareader ADD MEMBER [HPB\jsager]; 




--Use to Check his RoleMembership after the alter statements above......
USE [BakerTaylor]
SELECT DP1.name AS DatabaseRoleName,   
   isnull (DP2.name, 'No members') AS DatabaseUserName   
 FROM sys.database_role_members AS DRM  
 RIGHT OUTER JOIN sys.database_principals AS DP1  
   ON DRM.role_principal_id = DP1.principal_id  
 LEFT OUTER JOIN sys.database_principals AS DP2  
   ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.type = 'R' AND DP2.name = 'HPB\JSager'
HAVING DatabaseUserName = 'HPB\JSager'
ORDER BY DP1.name; 
HAVING DatabaseUserName = 'HPB\JSager'