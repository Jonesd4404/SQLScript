select * from tempdb..sysobjects
--for sql-server 2000 and later versions

select * from tempdb.sys.objects
--for sql-server 2005 and later versions




SELECT left(NAME, charindex('_', NAME) - 1)
FROM tempdb..sysobjects
WHERE NAME LIKE '#%'
    AND NAME NOT LIKE '##%'
    AND upper(xtype) = 'U'
    AND NOT object_id('tempdb..' + NAME) IS NULL