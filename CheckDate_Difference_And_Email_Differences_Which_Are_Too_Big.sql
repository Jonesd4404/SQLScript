/****** Script for SelectTopNRows command from SSMS  ******/
USE [rILS_Data]
GO

DECLARE @TableDate DateTime
SET @TableDate =
(SELECT TOP (1) [DateTransferred]
FROM [rILS_Data].[dbo].[Shipment_Header]
ORDER BY DateTransferred DESC)

PRINT 'TableDate'
PRINT @TableDate

DECLARE @CurrentDate DateTime
SET @CurrentDate = GetDate();
PRINT 'CurrentDate'
PRINT @CurrentDate

DECLARE @DateDelta int
--Date Difference
SET @DateDelta = (SELECT DATEDIFF(DAY, @TableDate, @CurrentDate) AS DateDiff)
--SELECT DATEDIFF(year, '2017/08/25', '2011/08/25') AS DateDiff;
PRINT 'Date Difference'
PRINT @DateDelta

IF @DateDelta > 3
BEGIN
   PRINT 'Difference is too big.'
USE msdb
EXEC sp_send_dbmail @profile_name='HPB\SQLADMIN2K14',
@recipients='ITDBA@HPB.com',
@subject='Restore of rILS_Data on SAGE failed as the date delta is too big',
@body='Check the file creation date for rILS_Data.'
END
