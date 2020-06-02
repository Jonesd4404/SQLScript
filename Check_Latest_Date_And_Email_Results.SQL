/****** Script for SelectTopNRows command from SSMS  ******/
USE [rHPB_Historical]
GO

DECLARE @TDEJ DateTime;

SET @TDEJ = 
(SELECT 
      MAX([EndDate])
      
  FROM [rHPB_Historical].[dbo].[SalesHeaderHistory_Recent])

  PRINT @TDEJ

  USE msdb
--GO
EXEC sp_send_dbmail @profile_name='HPB\SQLADMIN2K14',
@recipients='DJones2@HalfPriceBooks.com',
@subject='Test message',
@body= @TDEJ;


  USE msdb
GO
EXEC sp_send_dbmail @profile_name='HPB\SQLADMIN2K14',
@recipients='DJones2.HalfPriceBooks.com',
@subject='Test message',
@body='This is the body of the test message.
Congrates Database Mail Received By you Successfully.'