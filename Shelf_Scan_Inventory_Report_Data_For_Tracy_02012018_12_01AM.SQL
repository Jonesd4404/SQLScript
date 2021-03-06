/****** Script for SelectTopNRows command from SSMS  ******/
BEGIN TRAN

SELECT * INTO [SIPS].[dbo].[ShelfScan_Jan18]
  FROM [SIPS].[dbo].[ShelfScan]

  SELECT * INTO [SIPS].[dbo].[Shelf_Jan18]
  FROM [SIPS].[dbo].[Shelf]

  SELECT * INTO [SIPS].[dbo].[ShelfItemScan_Jan18]
  FROM [SIPS].[dbo].[ShelfItemScan]

  SELECT * INTO [SIPS].[dbo].[ShelfItemCount_Jan18]
  FROM [SIPS].[dbo].[ShelfItemCount]

  SELECT * INTO [SIPS].[dbo].[ShelfHistory_Jan18]
  FROM [SIPS].[dbo].[ShelfHistory]

  SELECT * INTO [SIPS].[dbo].[ShelfItemScanHistory_Jan18]
  FROM [SIPS].[dbo].[ShelfItemScanHistory]

  SELECT * INTO [SIPS].[dbo].[ShelfItemScanHistoryActive_Jan18]
  FROM [SIPS].[dbo].[ShelfItemScanHistoryActive]

  SELECT * INTO [SIPS].[dbo].[ShelfScanHistory_Jan18]
  FROM [SIPS].[dbo].[ShelfScanHistory]

  --COMMIT TRAN
  --ROLLBACK TRAN