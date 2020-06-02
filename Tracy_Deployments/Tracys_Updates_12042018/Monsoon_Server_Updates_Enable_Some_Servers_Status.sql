  /****** Script for SelectTopNRows command from SSMS  ******/
begin transaction;
update [Monsoon].[dbo].[MonsoonServers]
set status ='A'
  where ServerID =13;

  --select *
  --from  [Monsoon].[dbo].[MonsoonServers]
  --  where ServerID =13;
  --commit transaction;