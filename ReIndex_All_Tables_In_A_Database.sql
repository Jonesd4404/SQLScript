--From SQL-Server_Performance.com
-- http://www.sql-server-performance.com/dbcc_commands.asp
-- DBCC reindex all tables in a database
-- Script to automatically reindex all tables in a database 
-- The script will automatically reindex every index in every table 
-- of any database you select, and provide a fillfactor of 90%.
-- You can substitute any number you want for the 90 in the above script. 


--USE DatabaseName --Enter the name of the database you want to reindex 

USE DBAAdmin
DECLARE @TableName varchar(255) 

DECLARE TableCursor CURSOR FOR 
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'base table' 

OPEN TableCursor 

FETCH NEXT FROM TableCursor INTO @TableName 
WHILE @@FETCH_STATUS = 0 
BEGIN 
PRINT 'Reindexing ' + @TableName 
--DBCC DBREINDEX(@TableName,' ',98) 
FETCH NEXT FROM TableCursor INTO @TableName 
END 

CLOSE TableCursor 

DEALLOCATE TableCursor

