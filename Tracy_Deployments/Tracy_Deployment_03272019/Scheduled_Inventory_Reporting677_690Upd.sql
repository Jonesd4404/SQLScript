
/****** Script for SelectTopNRows command from SSMS  ******/
Update [HPB_INV].[dbo].[Scheduled_Inventory_Reporting]
set       Factor =25
  where Inventory_ID in (1141,1142)
  --2019 January Scheduled Inventory
  --19 rows