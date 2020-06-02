USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [CDF].[uspAcknowledge_Insert]    Script Date: 10/9/2019 10:10:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CDF].[uspAcknowledge_Insert]
(
	 @fulfillment AS CDF.TypeFulfillment READONLY
	,@acknowledgement AS CDF.TypeAcknowledgements READONLY
	,@ediver TINYINT
)
AS
BEGIN 
	DECLARE @mods AS TABLE (id BIGINT, ordernumber VARCHAR(22))
	DECLARE @inst AS TABLE (id BIGINT, linkid BIGINT)
	DECLARE @succ BIT = 0




	BEGIN TRANSACTION insert_ack
	BEGIN TRY
		IF EXISTS( SELECT 1 FROM @Fulfillment f0 INNER JOIN cdf.Fulfillment f1 ON f0.Id = f1.Id )
			UPDATE f				
				SET  LastModifiedDateUTC = GETUTCDATE()
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
			BEGIN
				INSERT INTO cdf.Fulfillment (LastTransactionId, VendorId, SourceApplication, OrderNumber, QuantityOrdered, QuantityConfirmed, QuantityBackordered, QuantityCancelled
											,QuantitySlashed,QuantityShipped, QuantityInvoiced, LastModifiedDateUTC, LastModifiedUTCOffset,RequestedShipMethod)
				OUTPUT inserted.id INTO @mods (id)
					SELECT	 f0.LastTransactionId, f0.VendorId, f0.SourceApplication, f0.OrderNumber, f0.QuantityOrdered ,f0.QuantityConfirmed, f0.QuantityBackordered,f0.QuantityCancelled
							,f0.QuantitySlashed,f0.QuantityShipped, f0.QuantityInvoiced, f0.LastModifiedDateUTC, DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()) ,f0.RequestedShipMethod				
					FROM @Fulfillment f0
			END

		INSERT INTO cdf.Acknowledgements ([FulfillmentId], [DateAcknowledgementRecorded], [AcknowledgementNumber], [DatePurchaseOrder], [DateOrderCancellation], [AcknowledgementId]
										, [VendorReferenceNumberType], [VendorReferenceNumber], [TerminalOrderControl], [POStatus], [VendorAcknowledgeMessage], [ModifiedShipToName]
										, [ModifiedShipToAddress], [ModifiedShipToCity], [ModifiedShipToState], [ModifiedShipToZip], [ModdifiedShipToCountry], [AcknowledgementStatusCode]
										, [AcknowledgementDistributionCenter]
										, [DateAvailable]
										, [DistrbutionInventory], [Publisher], [Title], [Author], [BindingCode], [QuantityPredicted]
										, [PriceNet], [PriceDiscountedList], [DateTimeInsertedUTC])
		OUTPUT inserted.id, inserted.FulfillmentId into @inst (id, linkid)
			SELECT	 m.id, a.[DateAcknowledgementRecorded], a.[AcknowledgementNumber], a.[DatePurchaseOrder],a.[DateOrderCancellation], a.[AcknowledgementId]
					,a.[VendorReferenceNumberType], a.[VendorReferenceNumber] ,a.[TerminalOrderControl], LEFT(a.[POStatus],1), a.[VendorAcknowledgeMessage], a.[ModifiedShipToName]
					,a.[ModifiedShipToAddress], a.[ModifiedShipToCity], a.[ModifiedShipToState], a.[ModifiedShipToZip],a.[ModdifiedShipToCountry], a.[AcknowledgementStatusCode]
					,LEFT(a.[AcknowledgementDistributionCenter],1)
					,CASE WHEN ISDATE(a.[DateAvailable]) = 1 THEN CAST(CAST(a.[DateAvailable] AS DATE) AS VARCHAR(10)) ELSE a.[DateAvailable] END
					,a.[DistrbutionInventory], a.[Publisher], a.[Title], a.[Author], LEFT(a.[BindingCode],1),a.[QuantityPredicted]
					, a.[PriceNet], a.[PriceDiscountedList], ISNULL(a.[DateTimeInsertedUTC],GETUTCDATE())
			FROM @acknowledgement  a
				INNER JOIN @mods m
					ON a.OrderNumber = m.ordernumber

		UPDATE f
			SET QuantityConfirmed = a.QuantityPredicted
		FROM cdf.Fulfillment f
			INNER JOIN @mods m
				ON f.OrderNumber = m.ordernumber 
			INNER JOIN @acknowledgement a
				ON a.OrderNumber = m.ordernumber

			IF @@TRANCOUNT > 0 COMMIT TRANSACTION insert_ack
			SET @succ = 1
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION insert_ack
	END CATCH

	IF @succ = 1
		SELECT 'Success' AS [Status], m.OrderNumber, m.id AS FulfillmentId, i.id AS AcknowledgeId
		FROM @mods m
			INNER JOIN @inst i
				ON m.id = i.linkid
	ELSE
		SELECT 'FAIL' As Status, '' AS ordernumnber, -1 AS FulfillmentId, -1 AS AcknowledgeId
END

GO

