USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_connections_check]    Script Date: 2/10/2019 6:50:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--ALTER PROCEDURE [dbo].[sp_connections_check]
--    @loginame     sysname = NULL,
--    @hostname     varchar(50) = NULL,
--    @programname  varchar(150) = NULL
--as
---------------------------------------------------------------------
if (object_id('tempdb..#tb1_sysprocesscount2') is not null)
            drop table #tb1_sysprocesscount2

if (object_id('tempdb..#DEJ_TEST') is not null)
            drop table #DEJ_TEST

if (object_id('tempdb..#DEJ_TEST_FULL') is not null)
            drop table #DEJ_TEST_FULL

DECLARE  @loginame sysname;
DECLARE  @hostname     varchar(50);
DECLARE  @programname  varchar(150);
DECLARE  @NUMBEROFCONNECTIONS int;

SELECT

  spid
 ,status
 ,sid
 ,hostname
 ,program_name
 ,cmd
 ,cpu
 ,physical_io
 ,blocked
 ,EC.client_net_address
 ,dbid
 ,convert(sysname, rtrim(loginame))
		as loginname
 ,spid as 'spid_sort'

 ,  substring( convert(varchar,last_batch,111) ,6  ,5 ) + ' '
  + substring( convert(varchar,last_batch,113) ,13 ,8 )
	   as 'last_batch_char'

	  INTO    #tb1_sysprocesscount2
	  from master.dbo.sysprocesses SP   (nolock)
	  join sys.dm_exec_connections EC
	  on SP.SPID = EC.session_id

	  --SELECT hostname, client_net_address FROM #tb1_sysprocesscount2

	  --ORDER BY SPID DESC
	  --SELECT * FROM #tb1_sysprocesscount2
	  --ORDER BY SPID DESC
	  --SELECT * FROM sys.dm_exec_connections
	  --ORDER BY session_id DESC



--------Screen out any rows?

IF (@loginame IN ('active'))
   DELETE #tb1_sysprocesscount2
         where   lower(status)  = 'sleeping'
         and     upper(cmd)    IN (
                     'AWAITING COMMAND'
                    ,'MIRROR HANDLER'
                    ,'LAZY WRITER'
                    ,'CHECKPOINT SLEEP'
                    ,'RA MANAGER'
                                  )

         and     blocked       = 0

--------Allows filtering by login name - this used to work in sp_who
--------Modified by DK - 07/22/2008.  Epicor DBA.
IF (@loginame IS NOT NULL)
  BEGIN
    DELETE #tb1_sysprocesscount2
    WHERE loginname <> @loginame AND loginname = 'sa'
  END

  SELECT * INTO #DEJ_TEST_FULL FROM #tb1_sysprocesscount2

  SELECT * INTO #DEJ_TEST FROM #tb1_sysprocesscount2
  WHERE loginname <> 'HPB\jblalock' AND loginname <> 'HPB\DJones2' AND loginname <> 'sa' AND loginname <> 'manh' AND loginname <> 'HPB\sqladmin2k12' AND loginname <> 'DJones2' AND loginname <> 'HPB\admdjones' AND loginname <> 'NT AUTHORITY\SYSTEM'
  --WHERE loginname <> 'ilsreader' AND loginname <> 'HPB\fhernandez' AND loginname <> 'HPB\jblalock' AND loginname <> 'HPB\DJones2' AND loginname <> 'sa' AND loginname <> 'manh' AND loginname <> 'HPB\sqladmin2k12' AND loginname <> 'DJones2' AND loginname <> 'HPB\admdjones' AND loginname <> 'NT AUTHORITY\SYSTEM'

  --SELECT loginname, client_net_address FROM #DEJ_TEST
  --SELECT COUNT(*) AS NUMBER_OF_CONNECTIONS FROM #DEJ_TEST

  SET @NUMBEROFCONNECTIONS = (SELECT COUNT(*) FROM #DEJ_TEST)

  IF @NUMBEROFCONNECTIONS = 0
  BEGIN
        --SELECT 'SAFE TO REBOOT' FROM #DEJ_TEST
		--WHERE loginname = 'Chico' 
		--SELECT 'Safe to Reboot' AS Reboot_Status,Loginname, 'IP' AS IP from #tb1_sysprocesscount2
		--group by loginname 
		--SELECT 'Safe to Reboot' AS Reboot_Status,Loginname, client_net_address AS IP from #tb1_sysprocesscount2
		--group by loginname 
		SELECT 'Safe to Reboot' AS Reboot_Status,Loginname, client_net_address AS IP from #DEJ_TEST_FULL
		--SELECT 'Safe to Reboot' AS SAFE_TO_REBOOT, 'OK to Reboot' AS Login, 'is still connected' AS Connection FROM #DEJ_TEST
		--PRINT 'SAFE TO REBOOT'
  END

  IF @NUMBEROFCONNECTIONS <> 0
  BEGIN
        --SELECT 'DO NOT REBOOT' FROM #DEJ_TEST
		--WHERE loginname = 'Chico' 
		---SELECT 'Do Not Reboot ' AS NOT_SAFE_TO_REBOOT ,loginname, ' is connected' AS Connected FROM #DEJ_TEST
		---Good--SELECT 'Not Safe to Reboot' AS Reboot_Status,Loginname, client_net_address AS IP from #tb1_sysprocesscount2
		SELECT 'Do Not Reboot' AS Reboot_Status,Loginname, client_net_address AS IP from #DEJ_TEST
		WHERE loginname IN(SELECT loginname from #DEJ_TEST)
		

		--group by loginname 
		--SELECT 'Not Safe to Reboot' AS Reboot_Status,Loginname, spid FROM sys.dm_exec_connections
		---WHERE loginname IN(SELECT loginname from #DEJ_TEST)
		---group by loginname
  END

  -------
IF (@hostname IS NOT NULL)
   BEGIN
    DELETE #tb1_sysprocesscount2
    WHERE hostname <> @hostname
  END


--select 
--   loginname, 
--   CASE hostname WHEN '' THEN @@servername ELSE hostname END HostName, 
--   count(*) AS ConnectionCount 
--from 
--   #tb1_sysprocesscount2
--   WHERE hostname not in('sa','HPB\DJones2')
--group by
--   loginname, 
----   hostname
--   CASE hostname WHEN '' THEN @@servername ELSE hostname END
--order by
--   ConnectionCount desc

--if (object_id('tempdb..#tb1_sysprocesscount') is not null)
--            drop table #tb1_sysprocesscount
--GO


--USE [master]
--GO

--DECLARE	@return_value int

--EXEC	@return_value = [dbo].[sp_connections]

--SELECT	'Return Value' = @return_value

--GO


/*
sa
HPB\DJones2
HPB\sqladmin2k12
HPB\sqladmin2k8
manh









*/