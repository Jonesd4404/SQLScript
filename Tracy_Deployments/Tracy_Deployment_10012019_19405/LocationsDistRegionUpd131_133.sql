/****** Script for SelectTopNRows command from SSMS  ******/
--Use ReportsData
Use HPB_db
   
    
      update
 [dbo].[LocationsDist]
 set  Region = 'Southeast'
  where LocationID ='0000000242'  --131 - Mishawaka
  
    update
[dbo].[LocationsDist]
 set  Region = 'Southeast'
  where LocationID ='0000000244' --133 - Nashville
  
    