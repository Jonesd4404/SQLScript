/******************************************
Script By: Aasim Abdullah 
For : http://connectsql.blogspot.com
Purpose: To detect long running sessions,
			send complete information through mail about such sessions
			and killing session, which are acceding given limit of execution time.
******************************************/

---BusyProcess Detection
SET NOCOUNT ON

-- Table variable to hold InputBuffer data
DECLARE @Inputbuffer TABLE
    (
      EventType NVARCHAR(30) NULL,
      Parameters INT NULL,
      EventInfo NVARCHAR(4000) NULL
    )
-- Table variable to hold running processes information
DECLARE @BusyProcess TABLE
    (
      SPID INT,
      Status VARCHAR(100),
      Login VARCHAR(100),
      HostName VARCHAR(100),
      DBName VARCHAR(100),
      Command VARCHAR(200),
      CPUTime INT,
      DiskIO INT,
      LastBatch DATETIME,
      ProgramName VARCHAR(200),
      EventInfo NVARCHAR(4000), -- extra column to hold actual stored procedure or batch call text
      EventTime INT   -- time in minutes, a process is running
    )
-- Insert all running processes information to table variable
INSERT  @BusyProcess
        ( SPID, Status, Login, HostName,  DBName, Command, CPUTime,
          DiskIO, LastBatch, ProgramName )
    
        SELECT spid,status,loginame,hostname,DB_NAME(dbid),cmd,cpu,physical_io,last_batch,program_name 
        FROM SYS.SYSPROCESSES
        WHERE 
			1 = CASE WHEN Status IN ( 'RUNNABLE', 'SUSPENDED' ) THEN 1
			--Transactions that are open not yet committed or rolledback
						WHEN Status = 'SLEEPING' AND open_tran  > 0 THEN 1 
						ELSE 0 END
			AND cmd NOT LIKE 'BACKUP%'						
            
-- Cursor to add actuall Procedure or Batch statement for each process
DECLARE cur_BusyProcess Cursor
    FOR SELECT  SPID
        FROM    @BusyProcess

OPEN cur_BusyProcess 
DECLARE @SPID INT     

Fetch NEXT FROM cur_BusyProcess INTO @SPID
While ( @@FETCH_STATUS <> -1 )
    BEGIN

        INSERT  @Inputbuffer
                EXEC ( 'DBCC INPUTBUFFER(' + @SPID + ')'
                    ) 

        UPDATE  @BusyProcess
        SET     EventInfo = I.EventInfo,
                EventTime = DATEDIFF(MI,LastBatch,GETDATE())
        FROM    @BusyProcess b
                CROSS JOIN @Inputbuffer i
        WHERE   B.SPID = @SPID


        DELETE  FROM @Inputbuffer

        FETCH NEXT FROM cur_BusyProcess INTO @SPID
    END
CLOSE cur_BusyProcess
DEALLOCATE cur_BusyProcess

-- Create html mail 
IF EXISTS(SELECT 1
						FROM  @BusyProcess I
						WHERE   EventInfo NOT LIKE '---BusyProcess Detection%'
						AND EventTime >= 3
						)
BEGIN
	Declare @Body varchar(max), @TableHead varchar(1000), @TableTail varchar(1000)
	Set NoCount On;


	Set @TableTail = '</table></body></html>';
	Set @TableHead = '<html><head>' +
					  '<style>' +
					  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:11pt;} ' +
					  '</style>' +
					  '</head>' +
					  '<body><table cellpadding=0 cellspacing=0 border=0>' +
					  '<tr><td align=center bgcolor=#E6E6FA><b>ROW ID</b></td>' +
					  '<td align=center bgcolor=#E6E6FA><b>SPID</b></td>' +
					  '<td align=center bgcolor=#E6E6FA><b>Event Info</b></td>' +
					  '<td align=center bgcolor=#E6E6FA><b>Login</b></td>'+
					  '<td align=center bgcolor=#E6E6FA><b>DBName</b></td>'+
					  '<td align=center bgcolor=#E6E6FA><b>Command</b></td>'+
					  '<td align=center bgcolor=#E6E6FA><b>CPUTime</b></td>'+
					  '<td align=center bgcolor=#E6E6FA><b>DiskIO</b></td>'+
					  '<td align=center bgcolor=#E6E6FA><b>LastBatch</b></td>'+
					  '<td align=center bgcolor=#E6E6FA><b>EventTime</b></td></tr>';

	Select @Body = (SELECT td= row_number()over(order by I.SPID ),'',		
							td=I.SPID,'',
							td= I.EventInfo,'',		
							td= MAX(I.Login),'',
							td= I.DBName,'',
							td= I.Command,'',
							td= SUM(I.CpuTime),'',
							td= SUM(I.DiskIO),'',
							td= I.LastBatch,'',		
							td= I.EventTime,''
							FROM  @BusyProcess I
							WHERE   EventInfo NOT LIKE '---BusyProcess Detection%'
							--AND EventTime >= 3
							GROUP BY SPID, EventInfo, DBName, Command, LastBatch, EventTime
							--HAVING MAX(Login) = 'CureMD'
							For XML raw('tr'), Elements
							)

	-- Replace the entity codes and row numbers
	Set @Body = Replace(@Body, '_x0020_', space(1))
	Set @Body = Replace(@Body, '_x003D_', '=')
	Set @Body = Replace(@Body, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#C6CFFF>')
	Set @Body = Replace(@Body, '<TRRow>0</TRRow>', '')


	Select @Body = @TableHead + @Body + @TableTail
	-- Send mail to DBA Team
	EXEC msdb.dbo.sp_send_dbmail @recipients='Dale_Jones@halfpricebooks.com', -- change mail address accordingly
		@subject = 'Blocking Session Detected', 
		@profile_name = 'SQL2K14_PCMS-SQL-N', -- Change profile name accordingly
		@body = @Body,
		@body_format = 'HTML' ;

	--DECLARE @QKILLsp VARCHAR(1000)

	--SET @QKILLsp= (SELECT DISTINCT '  KILL '+ CONVERT(VARCHAR,SPID)
	--						FROM  @BusyProcess I
	--						WHERE   EventInfo NOT LIKE '---BusyProcess Detection%'
	--						AND EventTime >= 360 -- Transactions Running for 360 minutes or more
	--						for XML path('')
	--						)
								
	--EXEC(@QKILLsp) 

END