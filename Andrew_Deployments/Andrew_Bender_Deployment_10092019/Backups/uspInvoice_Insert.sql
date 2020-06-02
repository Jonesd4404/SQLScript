USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [CDF].[uspInvoice_Insert]    Script Date: 10/9/2019 10:09:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CDF].[uspInvoice_Insert]
(
	 @fulfillment AS CDF.TypeFulfillment READONLY
	,@invoices AS CDF.TypeInvoices READONLY
	,@ediver TINYINT
)
AS
BEGIN
	DECLARE @mods AS TABLE (id BIGINT, ordernumber VARCHAR(22))
	DECLARE @inst AS TABLE (id BIGINT, linkid BIGINT)
	DECLARE @succ BIT = 0

	BEGIN TRANSACTION insert_inv
	BEGIN TRY
		IF EXISTS( SELECT 1 FROM @Fulfillment f0 INNER JOIN cdf.Fulfillment f1 ON f0.Id = f1.Id )
			UPDATE f				
				SET  LastModifiedDateUTC = ISNULL(f0.LastModifiedDateUTC,GETUTCDATE())
					,LastModifiedUTCOffset = DATEDIFF(MINUTE, GETUTCDATE(), GETDATE())
					,LastTransactionId = f0.LastTransactionId
					,OrderNumber = f0.OrderNumber
					,QuantityBackordered = f0.QuantityBackordered
					,QuantityCancelled = f0.QuantityCancelled
					,QuantityConfirmed = f0.QuantityConfirmed
					,QuantityInvoiced = f0.QuantityInvoiced
					,QuantityOrdered = f0.QuantityOrdered
					,QuantityShipped = f0.QuantityShipped
					,QuantitySlashed = f0.QuantitySlashed
					,RequestedShipMethod = f0.RequestedShipMethod
					,SourceApplication = f0.SourceApplication
					,VendorId = f0.VendorId
			OUTPUT inserted.Id,inserted.OrderNumber INTO @mods(id,ordernumber)
			FROM CDF.Fulfillment f
				INNER JOIN @Fulfillment f0
					ON f.Id = f0.Id
		ELSE
			INSERT INTO cdf.Fulfillment (LastTransactionId, VendorId, SourceApplication, OrderNumber, QuantityOrdered, QuantityConfirmed, QuantityBackordered, QuantityCancelled
										,QuantitySlashed,QuantityShipped, QuantityInvoiced, LastModifiedDateUTC, LastModifiedUTCOffset,RequestedShipMethod)
			OUTPUT inserted.id, inserted.OrderNumber INTO @mods (id, ordernumber)
				SELECT	 f0.LastTransactionId, f0.VendorId, f0.SourceApplication, f0.OrderNumber, f0.QuantityOrdered,f0.QuantityConfirmed, f0.QuantityBackordered,f0.QuantityCancelled
						,f0.QuantitySlashed,f0.QuantityShipped, f0.QuantityInvoiced, f0.LastModifiedDateUTC, f0.LastModifiedUTCOffset,f0.RequestedShipMethod				
				FROM @Fulfillment f0

		INSERT INTO cdf.Invoices ([FulfillmentId], [DateTimeInvoiceRecorded], [InvoiceNumber], [CurrencyCode], [CountryCode], [InvoicePriceList], [InvoiceDiscount], [InvoicePriceNet]
								 ,[InvoicePriceShipping], [InvoicePriceHAndling], [InvoicePriceGiftWrapFee], [InvoiceAmountDue], [DateMetered], [InvoiceTitle], [InvoiceClientOrderNumber]
								 ,[LineItemNumber], [BillOfLadingNumber], [DateTimeInsertedUTC])
		OUTPUT inserted.id, inserted.FulfillmentId into @inst (id, linkid)
			SELECT	 m.id as [FulfillmentId], i.[DateTimeInvoiceRecorded], i.[InvoiceNumber], i.[CurrencyCode], i.[CountryCode],i.[InvoicePriceList], i.[InvoiceDiscount], i.[InvoicePriceNet]
					,i.[InvoicePriceShipping],i.[InvoicePriceHAndling], i.[InvoicePriceGiftWrapFee], i.[InvoiceAmountDue], i.[DateMetered],i.[InvoiceTitle], i.[InvoiceClientOrderNumber]
					,i.[LineItemNumber], i.[BillOfLadingNumber],ISNULL(i.[DateTimeInsertedUTC],GETUTCDATE())
			FROM @invoices i
				INNER JOIN @mods m
					ON i.OrderNumber= m.ordernumber
		IF @@TRANCOUNT > 0 COMMIT TRANSACTION insert_inv
		SET @succ = 1
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION insert_inv
	END CATCH


	IF @succ = 1
		SELECT 'Success' AS Status, m.ordernumber, m.id AS FulfillmentId, i.id AS InvoiceID
		FROM @mods m
			INNER JOIN @inst i
				ON m.id = i.linkid
	ELSE
		SELECT 'Failed' AS Status, m.ordernumber, ISNULL(m.id,-1) AS FulfillmentId, ISNULL(i.id,-1) AS InvoiceID
		FROM @mods m
			LEFT JOIN @inst i
				ON m.id = i.linkid
END

GO

