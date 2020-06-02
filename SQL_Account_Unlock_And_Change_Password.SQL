ALTER LOGIN ReportReader WITH PASSWORD = '5xodus@5xodus' UNLOCK



--This is a little hacky but it will unlock the login w/o the password

 

Alter login [test1] with CHECK_POLICY = OFF

go

Alter login [test1] with CHECK_POLICY = ON

go