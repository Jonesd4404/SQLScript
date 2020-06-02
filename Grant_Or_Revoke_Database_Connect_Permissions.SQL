USE [HPB_SALES]
SELECT name, hasdbaccess FROM sys.sysusers WHERE name = 'HPB\JSager'

USE [HPB_SALES]
GRANT CONNECT TO [HPB\JSager]

USE [HPB_SALES]
REVOKE CONNECT FROM [HPB\JSager]