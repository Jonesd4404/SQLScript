--*************** Begin of Differential Restores ***************
/*
RESTORE DATABASE [HPB_db] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\HPB_DB.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 1
GO
*/

RESTORE DATABASE [BT] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\BT_DIF.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [DBAALERTS] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\DBAALERTS_DIF.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [HPB_iR] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\HPB_ir_DIF.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [HPB_iRL] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\HPB_iRL_DIF.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [HPB_Receiving] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\HPB_Receiving_DIF.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [rILS] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\rILS_DIF.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 1
GO


--******************Begin of Full Restore ****************************
/*
RESTORE DATABASE [HPB_db] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\HPB_DB.bak' 
WITH  FILE = 1, NORECOVERY, NOUNLOAD,  REPLACE,  STATS = 1
GO
*/

RESTORE DATABASE [BT] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\BT_DIF.bak' 
WITH  FILE = 1, NORECOVERY, NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [DBAALERTS] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\DBAALERTS_DIF.bak' 
WITH  FILE = 1, NORECOVERY, NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [HPB_iR] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\HPB_ir_DIF.bak' 
WITH  FILE = 1,  NORECOVERY, NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [HPB_iRL] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\HPB_iRL_DIF.bak' 
WITH  FILE = 1, NORECOVERY, NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [HPB_Receiving] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\HPB_Receiving_DIF.bak' 
WITH  FILE = 1, NORECOVERY, NOUNLOAD,  REPLACE,  STATS = 1
GO

RESTORE DATABASE [rILS] 
FROM  DISK = N'\\loblolly\sequoia_Transfer\rILS_DIF.bak' 
WITH  FILE = 1, NORECOVERY, NOUNLOAD,  REPLACE,  STATS = 1
GO