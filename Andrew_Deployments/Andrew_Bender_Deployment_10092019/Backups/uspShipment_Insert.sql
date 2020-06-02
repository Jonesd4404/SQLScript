USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [CDF].[uspShipment_Insert]    Script Date: 10/9/2019 10:10:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CDF].[uspShipment_Insert]
(
	 @fulfillment AS CDF.TypeFulfillment READONLY
	,@shipment AS CDF.TypeShipments READONLY
	,@ediver TINYINT
)
AS
BEGIN
	DECLARE @mods AS TABLE (id BIGINT, ordernumber VARCHAR(22))
	DECLARE @inst AS TABLE (id BIGINT, linkid BIGINT)
	DECLARE @succ BIT = 0

	BEGIN TRANSACTION insert_asn
	BEGIN TRY
		IF EXISTS( SELECT 1 FROM @Fulfillment f0 INNER JOIN cdf.Fulfillment f1 ON f0.Id = f1.Id )
			UPDATE f				
				SET  LastModifiedDateUTC = ISNULL(f0.LastModifiedDateUTC, GETUTCDATE())
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
			OUTPUT inserted.Id,inserted.OrderNumber into @mods(id,ordernumber)
			FROM CDF.Fulfillment f
				INNER JOIN @fulfillment f0
					ON f.Id = f0.id
		ELSE
			INSERT INTO CDF.Fulfillment (LastTransactionId, VendorId, SourceApplication, OrderNumber, QuantityOrdered, QuantityConfirmed, QuantityBackordered, QuantityCancelled
										,QuantitySlashed,QuantityShipped, QuantityInvoiced, LastModifiedDateUTC, LastModifiedUTCOffset,RequestedShipMethod)
			OUTPUT inserted.id, inserted.OrderNumber INTO @mods (id, ordernumber)
				SELECT	 f0.LastTransactionId, f0.VendorId, f0.SourceApplication, f0.OrderNumber, f0.QuantityOrdered,f0.QuantityConfirmed, f0.QuantityBackordered,f0.QuantityCancelled
						,f0.QuantitySlashed,f0.QuantityShipped, f0.QuantityInvoiced, f0.LastModifiedDateUTC, f0.LastModifiedUTCOffset,f0.RequestedShipMethod				
				FROM @Fulfillment f0

		INSERT INTO cdf.Shipments ([FulfillmentId], [DateTimeShipmentRecorded], [ShipmentNumber], [ShipmentSubtotal], [ShipmentDiscount], [ShipmentTaxSales], [ShipmentFees]
								  ,[ShipmentFreight], [ShipmentTotal], [DateOrderShipped], [CustomerOrderReference], [CarrierType], [CarrierName], [PackageNumberTracking], [PackageNumberSecondary]
								  ,[ShipmentPriceList], [ShipmentPriceNet], [PackageWeight], [ReasonCode], [ShipmentISBNorEAN], [DateTimeInsertedUTC], [WarehouseCode])
		OUTPUT inserted.id, inserted.FulfillmentId into @inst (id, linkid)
			SELECT	 m.id, s.[DateTimeShipmentRecorded], s.[ShipmentNumber], s.[ShipmentSubtotal],s.[ShipmentDiscount], s.[ShipmentTaxSales], s.[ShipmentFees]
					,s.[ShipmentFreight], s.[ShipmentTotal],s.[DateOrderShipped], s.[CustomerOrderReference], s.[CarrierType], s.[CarrierName],s.[PackageNumberTracking], s.[PackageNumberSecondary]
					,s.[ShipmentPriceList], s.[ShipmentPriceNet],s.[PackageWeight], s.[ReasonCode], s.[ShipmentISBNorEAN], s.[DateTimeInsertedUTC], s.[WarehouseCode]			
			FROM @shipment s
				INNER JOIN @mods m
					ON s.OrderNumber = m.ordernumber

		UPDATE f
			SET	 QuantityShipped = ISNULL(s.QuantityShipped,0)
				,QuantitySlashed = ISNULL(s.QuantitySlashed,0)
		FROM cdf.Fulfillment f
			INNER JOIN @mods m
				ON f.OrderNumber = m.ordernumber 
			INNER JOIN @shipment s
				ON s.OrderNumber = m.ordernumber

		IF @@TRANCOUNT > 0 COMMIT TRANSACTION insert_asn
		SET @succ = 1
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION insert_asn
	END CATCH


	IF @succ = 1
		SELECT 'Success' AS Status, m.OrderNumber, m.id as FulfillmentId, i.id AS ShipmentsId
		FROM @mods m
			INNER JOIN @inst i
				ON m.id = i.linkid
	ELSE
		SELECT 'FAILED' AS Status, m.OrderNumber, -1 as FullfilmentId, -1 as ShipmentsId
		FROM @mods m

END

GO

