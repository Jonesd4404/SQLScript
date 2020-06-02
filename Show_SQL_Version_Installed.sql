--Show SQL version installed......

SELECT SERVERPROPERTY('productversion'), 
       SERVERPROPERTY ('productlevel'), 
       SERVERPROPERTY ('edition')

Select @@Version