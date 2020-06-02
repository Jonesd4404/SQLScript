DECLARE @MyDateTime DATETIME
/* Add 5 seconds to current time so
system waits for 5 seconds*/
SET @MyDateTime = DATEADD(s,5,GETDATE())
SELECT GETDATE() CurrentTime
WAITFOR TIME @MyDateTime
SELECT GETDATE() CurrentTime

WAITFOR DELAY '00:00:05' -- 5 seconds
WAITFOR DELAY '00:05:00' -- 5 minutes
WAITFOR DELAY '05:00:00' -- 5 hours
