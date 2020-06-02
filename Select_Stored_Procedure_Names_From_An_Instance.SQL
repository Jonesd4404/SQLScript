/*
How to Get List of all Stored Procedures in an MS SQL database.
Solution 1
Hide   Copy Code
*/

select *  from YourDatabaseName.information_schema.routines 
 where routine_type = 'PROCEDURE'
--Solution 2

--Hide   Copy Code
select *   from YourDatabaseName.information_schema.routines 
 where routine_type = 'PROCEDURE' 
   and Left(Routine_Name, 3) NOT IN ('sp_', 'xp_', 'ms_')
--Note: retrun Prodecdure Name Not Start from 'sp_', 'xp_', 'ms_'

--Solution 3
--Hide   Copy Code
SELECT name, type   FROM dbo.sysobjects
 WHERE (type = 'P')
 