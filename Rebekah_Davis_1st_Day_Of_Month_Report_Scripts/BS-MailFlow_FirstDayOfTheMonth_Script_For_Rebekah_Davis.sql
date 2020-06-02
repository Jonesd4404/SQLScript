--BS-MAILFLOW_VisNetic_MailFlow Script to generate Excel file and email to Rebekah Davis
--Needs to be run on 1st day of each month for the previous month.


DECLARE @datestart DATETIME,@datestop DATETIME,@tbname VARCHAR(50), @STMT VARCHAR(MAX),@bodyHtml NVARCHAR(MAX), 
@mailSubject NVARCHAR(MAX), @RtnCode INT, @Separateur varchar(1)

SET @Datestart = (select CONVERT(varchar,dateadd(d,-(day(dateadd(m,-1,getdate()-2))),dateadd(m,-1,getdate()-1)),106))
SET @Datestop = (select CONVERT(varchar,dateadd(d,-(day(getdate())),getdate()),106))
SET @Datestop = dateadd(d,1,@Datestop)

SELECT tb.Name AS 'TicketBox',t.TicketID,t.Subject,t.DateCreated,tc.Description AS 'TicketCategory', CASE WHEN tn.Note IS NOT NULL THEN tn.Note ELSE '' END AS 'NOTE', CASE WHEN tn.Note IS NOT NULL THEN a.Name ELSE '' END AS 'Agent'
INTO #TEMPTABLE
FROM TicketBoxes tb
INNER JOIN Tickets t ON t.TicketBoxID=tb.TicketBoxID INNER JOIN TicketCategories tc ON t.TicketCategoryID=tc.TicketCategoryID
LEFT OUTER JOIN TicketNotes tn ON tn.TicketID=t.TicketID LEFT OUTER JOIN Agents a ON tn.AgentID=a.AgentID WHERE t.TicketStateID=1 AND t.IsDeleted=0 AND t.DateCreated >= @datestart AND t.DateCreated <= @datestop ORDER BY t.DateCreated

SELECT * FROM #TEMPTABLE
WHERE DateCreated > '2018-06-30 23:59:37.000'

SET @STMT = 'SELECT * FROM #TEMPTABLE'
SET @bodyHTML ='Monthly Report'
SET @mailSubject ='Monthly TicketBoxes Report'

 EXEC  @RtnCode = sp_send_dbmail
      @profile_name = 'SQL2K8_BS-MAILFLOW-SQL_Mail',
      @query_result_separator=@Separateur,
      @recipients = 'DJones2@HPB.com', 
      @subject = @mailSubject,
      @query = @STMT,      
      @Attach_Query_result_as_file = 0

    IF @RtnCode <> 0
      RAISERROR('Error.', 16, 1)
END