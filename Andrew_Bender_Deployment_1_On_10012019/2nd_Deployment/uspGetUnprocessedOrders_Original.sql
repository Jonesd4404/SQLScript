USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [BLK].[uspGetUnprocessedOrders]    Script Date: 10/1/2019 8:16:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [BLK].[uspGetUnprocessedOrders]
AS
BEGIN
	SELECT PONumber
	FROM blk.PurchaseOrderHeader
	WHERE processed = 0
END

GO

