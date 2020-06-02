USE [ReportsData]

INSERT INTO RDA_InventoryProductClass
SELECT DISTINCT 
	ItemType_Description [Type_Description],
	ProductType,
	'Frontline'
FROM [HPB_INV].[dbo].[Scheduled_Inventory_Reporting] sir
WHERE ItemType_Description = 'Distribution'
	AND ProductType LIKE '%F'

INSERT INTO RDA_InventoryProductClass
SELECT DISTINCT 
	ItemType_Description [Type_Description],
	ProductType,
	'New'
FROM [HPB_INV].[dbo].[Scheduled_Inventory_Reporting] sir
WHERE ItemType_Description = 'Distribution'
	AND ProductType NOT LIKE '%F'
  
INSERT INTO RDA_InventoryProductClass
SELECT DISTINCT 
	ItemType_Description [Type_Description],
	ProductType,
	'Used'
FROM [HPB_INV].[dbo].[Scheduled_Inventory_Reporting] sir
WHERE ItemType_Description IN ('Sips', 'Product Type')

--The following values are necessary to address an error in particular inventories where some items are counted as both "Used" and "Distribution"
INSERT INTO RDA_InventoryProductClass (Category, Type_Description, ProductType)
VALUES 
	('Used', 'Distribution', 'PB'),
	('Used', 'Distribution', 'BCD'),
	('Used', 'Distribution', 'DVD'),
	('Used', 'Distribution', 'MG')


