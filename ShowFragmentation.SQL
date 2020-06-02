SELECT DB_NAME ()+ '    START DATE: '+CONVERT(VARCHAR, GETDATE())
SET NOCOUNT ON 
DECLARE TableList CURSOR FOR 
 SELECT id 
   FROM sysobjects
  WHERE type = 'U'
  ORDER BY id
DECLARE @id int
     
OPEN TableList 
FETCH NEXT FROM TableList INTO @id
WHILE @@FETCH_STATUS <> -1
BEGIN 
   print ''
   print '*************************************************************************'
   print ''
   dbcc showcontig( @id )
   FETCH NEXT FROM TableList INTO @id
END
DEALLOCATE TableList

SELECT 'END DATE:'+CONVERT(VARCHAR,GETDATE())
