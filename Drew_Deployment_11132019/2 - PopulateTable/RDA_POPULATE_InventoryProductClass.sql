USE [ReportsData]

CREATE TABLE #InventoryProductClass (
	Type_Description VARCHAR(20),
	ProductType VARCHAR(4),
	Category VARCHAR(10)
)

INSERT INTO #InventoryProductClass (Type_Description, ProductType, Category)
SELECT DISTINCT 
	ItemType_Description [Type_Description],
	ProductType,
	'Frontline'
FROM [HPB_INV].[dbo].[Scheduled_Inventory_Reporting] sir
WHERE ItemType_Description = 'Distribution'
	AND ProductType LIKE '%F'

INSERT INTO #InventoryProductClass (Type_Description, ProductType, Category)
SELECT DISTINCT 
	ItemType_Description [Type_Description],
	ProductType,
	'New'
FROM [HPB_INV].[dbo].[Scheduled_Inventory_Reporting] sir
WHERE ItemType_Description = 'Distribution'
	AND ProductType NOT LIKE '%F'
  
INSERT INTO #InventoryProductClass (Type_Description, ProductType, Category)
SELECT DISTINCT 
	ItemType_Description [Type_Description],
	ProductType,
	'Used'
FROM [HPB_INV].[dbo].[Scheduled_Inventory_Reporting] sir
WHERE ItemType_Description IN ('Sips', 'Product Type')

ALTER TABLE #InventoryProductClass 
ADD ProductClassID bigint

UPDATE #InventoryProductClass 
	SET ProductClassID = ipc2.ProductClassID
FROM #InventoryProductClass ipc1
	INNER JOIN (
		SELECT 
			ROW_NUMBER () OVER (ORDER BY Category, Type_Description, ProductType) [ProductClassID],
			Type_Description,
			ProductType,
			Category
		FROM #InventoryProductClass) ipc2
			ON ipc1.ProductType = ipc2.ProductType
			AND ipc1.Category = ipc2.Category
			AND ipc1.Type_Description = ipc2.Type_Description

INSERT INTO RDA_InventoryProductClass
SELECT
	ipc.ProductClassID,
	ipc.Category,
	ipc.Type_Description,
	ipc.ProductType
FROM #InventoryProductClass ipc
ORDER BY ipc.ProductClassID

DROP TABLE #InventoryProductClass
