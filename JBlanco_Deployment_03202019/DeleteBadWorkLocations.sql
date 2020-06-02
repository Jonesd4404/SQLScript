use [ILS]
GO

-- Please delete these entries from ILS.[dbo].[Location_Inventory] from server WMSSQLCluster

DELETE Location_Inventory WHERE INTERNAL_LOCATION_INV IN (28578374, 29269961, 29574927)