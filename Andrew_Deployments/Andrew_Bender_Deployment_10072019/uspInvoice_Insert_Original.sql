USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [BLK].[uspInvoice_Insert]    Script Date: 10/7/2019 1:32:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [BLK].[uspInvoice_Insert]
(
	 @header AS BLK.TypeInvoiceHeader READONLY
	,@detail AS BLK.TypeInvoiceDetail READONLY
	,@ediver AS TINYINT
)
AS
BEGIN
	DECLARE  @success BIT = 0
			,@message  VARCHAR(2500)
	CREATE TABLE #inserted (id INT, po VARCHAR(22))
	
	BEGIN TRANSACTION invoice_insert
	BEGIN TRY
		INSERT INTO blk.InvoiceHeader ([PONumber], [InvoiceNo], [IssueDate], [VendorId], [ReferenceNo], [ShipToLoc], [ShipToSAN], [BillToLoc], [BillToSAN], [ShipFromLoc], [ShipFromSAN], [TotalLines], [TotalQuantity], [TotalPayable], [CurrencyCode], [InsertDateTime], [Processed], [ProcessedDateTime], [InvoiceACKSent], [InvoiceAckNo], [GSNo], [EDISourceTypeId])
			OUTPUT inserted.invoiceid, inserted.ponumber INTO #inserted(id, po)
			SELECT [PONumber], [InvoiceNo], [IssueDate], [VendorId], [ReferenceNo], [ShipToLoc], [ShipToSAN], [BillToLoc], [BillToSAN], [ShipFromLoc], [ShipFromSAN], [TotalLines], [TotalQuantity], [TotalPayable], [CurrencyCode], [InsertDateTime], [Processed], [ProcessedDateTime], [InvoiceACKSent], [InvoiceAckNo], [GSNo], @ediver
			FROM @header

		IF EXISTS(SELECT 1 FROM @detail d INNER JOIN #inserted i ON d.[ponumber] = i.po)
			BEGIN
				-- must have both header and detail data to be a valid record
				INSERT INTO blk.InvoiceDetail ([InvoiceId], [LineNo], [ItemIdCode], [ItemIdentifier], [ItemDesc], [InvoiceQty], [UnitPrice], [DiscountPrice], [DiscountCode], [DiscountPct], [RetailPrice])
					SELECT i.id, [LineNo], [ItemIdCode], [ItemIdentifier], [ItemDesc], [InvoiceQty], [UnitPrice], [DiscountPrice], [DiscountCode], [DiscountPct], [RetailPrice]
					FROM @detail d
						INNER JOIN #inserted i		
							 ON LTRIM(RTRIM(d.[ponumber])) =  LTRIM(RTRIM(i.po))
				SET @success = 1
			END
		ELSE
			BEGIN
				SELECT	 @success = 0
						,@message = 'Could not get detail data'			
			END	
	END TRY
	BEGIN CATCH		
		SELECT	 @success = 0
				,@message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ' ' +  ERROR_MESSAGE()
	END CATCH

	IF @success = 1
		COMMIT TRANSACTION invoice_insert
	ELSE
		BEGIN
			ROLLBACK TRANSACTION invoice_insert
			INSERT INTO Logging.SQLMessages(ProcedureName, ErrorMessage) VALUES ('uspInvoice_Insert', @message)
		END
	SELECT @success AS [Successful]
END

GO


