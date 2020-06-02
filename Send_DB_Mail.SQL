USE msdb
GO
EXEC sp_send_dbmail @profile_name='yourprofilename',
@recipients='test@Example.com',
@subject='Test message',
@body='This is the body of the test message.
Congrates Database Mail Received By you Successfully.'