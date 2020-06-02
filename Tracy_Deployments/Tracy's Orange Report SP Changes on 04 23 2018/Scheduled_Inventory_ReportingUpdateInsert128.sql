--copy [ZZZ_DEJ_Temp].[dbo].[Scheduled_Inventory_Reporting] from rabbit to Orange 
--It can be added into [ZZZ_DEJ_Temp].[dbo].[Scheduled_Inventory_Reporting_Prod_Insert] --307,895

INSERT INTO 
HPB_INV..Scheduled_Inventory_Reporting (--30419
--ReportsDev..Scheduled_Inventory_Reporting (

--[ZZZ_DEJ_Temp].[dbo].[Scheduled_Inventory_Reporting](   --30419
	External_Report_Item_ID
	,Inventory_ID
	,Inventory_Description
	,StartDate
	,EndDate
	,LocationNo
	,LocationID
	,Factor
	,ScanCount
	,Sips_SubjectKey
	,Sips_SectionName
	,Inventory_SectionID
	,Inventory_SectionName
	,UserName
	,Inventory_ItemType
	,ItemType_Description
	,ProductType
	,Quantity
	,Price
	,Cost
	,ReportInsertDate
	)
select External_Report_Item_ID
	,Inventory_ID
	,Inventory_Description
	,StartDate
	,EndDate
	,LocationNo
	,LocationID
	,Factor
	,ScanCount
	,Sips_SubjectKey
	,Sips_SectionName
	,Inventory_SectionID
	,Inventory_SectionName
	,UserName
	,Inventory_ItemType
	,ItemType_Description
	,ProductType
	,Quantity
	,Price
	,Cost
	,ReportInsertDate
	
FROM 
[ZZZ_DEJ_Temp].[dbo].[Scheduled_Inventory_Reporting] --30419
--[ZZZ_DEJ_Temp].[dbo].[Scheduled_Inventory_Reporting_Prod_Insert] -- 
--[ReportsDEV].[dbo].[Scheduled_Inventory_Reporting] 
--[HPB_INV].[dbo].[Scheduled_Inventory_Reporting] 
 where 
LocationNo ='00128'
		and
 Inventory_Description= '2018 March New Store Inventory' 
