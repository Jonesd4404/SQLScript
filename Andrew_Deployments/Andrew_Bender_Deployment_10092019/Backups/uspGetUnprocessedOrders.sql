USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [BLK].[uspGetUnprocessedOrders]    Script Date: 10/9/2019 10:18:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [BLK].[uspGetUnprocessedOrders]
AS
BEGIN
	SELECT oh.PONumber, oh.VendorID
	FROM blk.PurchaseOrderHeader oh
		INNER JOIN [HPB_EDI].[EDI].[ApplicationMaster] am
			ON oh.[VendorID] = am.[VendorId]
				AND am.[PO__BULK] LIKE 'DX:%'
		LEFT JOIN [BLK].[AcknowledgeHeader] ah
			ON oh.[PONumber] = ah.[PONumber]
		LEFT JOIN [HPB_Logistics].dbo.[VX_Requisition_Hdr] rh	
			ON oh.[PONumber] = rh.[PONumber]		
		INNER JOIN [HPB_Logistics].dbo.[VX_Status] vs
			on rh.[Status] = vs.[StatusCode]
	WHERE ah.[AckId] IS NULL
		AND vs.[StatusName] = 'SUBMITTED' -- 30
		AND oh.[InsertDateTime] > DATEADD(DAY, -7, GETDATE())
END

GO

