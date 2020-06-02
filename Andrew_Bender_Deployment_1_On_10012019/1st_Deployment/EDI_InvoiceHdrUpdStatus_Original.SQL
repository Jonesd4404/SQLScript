USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[EDI_InvoiceHdrUpdStatus]    Script Date: 10/1/2019 8:06:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B.>
-- Create date: <C5/30/2013>
-- Description:	<Update BT invoice header status...>
-- =============================================
CREATE PROCEDURE [dbo].[EDI_InvoiceHdrUpdStatus] 
	 @InvoiceID int
	,@VendorID varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @VendorID = 'IDB&TDISTR'
		BEGIN
			UPDATE bh
				SET	 bh.processed = 1
					,bh.processeddate = GETDATE()
			FROM BakerTaylor.dbo.bulkorder_invoice_Header bh
			WHERE bh.InvoiceID = @InvoiceID
		END
	ELSE 
		BEGIN    
			UPDATE IH
				SET	 ih.Processed = 1
					,ih.ProcessedDateTime = GETDATE()
			FROM EDI.Bulk_InvoiceHeader IH
			WHERE ih.InvoiceID = @InvoiceID
		END    
END

GO

