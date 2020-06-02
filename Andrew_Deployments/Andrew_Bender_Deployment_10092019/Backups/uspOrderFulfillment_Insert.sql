USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [CDF].[uspOrderFulfillment_Insert]    Script Date: 10/9/2019 10:19:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [CDF].[uspOrderFulfillment_Insert]
(
	@orders as CDF.TypeOrderFulfillment READONLY
)
AS
BEGIN
	DECLARE @Success BIT = 0
	DECLARE @ids AS TABLE (id INT, ordernumber VARCHAR(25))
	DECLARE @DTUTC DATETIME 
			,@DT DATETIME 

	SELECT @DTUTC = GETUTCDATE(), @DT = GETDATE()

	BEGIN TRANSACTION cdf_orderfulfillment_insert
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM @orders o INNER JOIN cdf.Fulfillment f on o.Id = f.Id)
			BEGIN
				UPDATE f				
				SET  LastModifiedDateUTC = ISNULL(@DTUTC,GETUTCDATE())
					,LastModifiedUTCOffset = DATEDIFF(MINUTE, GETUTCDATE(), GETDATE())
					,LastTransactionId = o.LastTransactionId
					,OrderNumber = o.OrderNumber
					,QuantityBackordered = 0
					,QuantityCancelled = 0
					,QuantityConfirmed = 0
					,QuantityInvoiced = 0
					,QuantityOrdered = o.QuanityOrdered
					,QuantityShipped = 0
					,QuantitySlashed = 0
					,RequestedShipMethod = o.TransportMethod
					,SourceApplication = o.SourceApplication
					,VendorId = o.VendorId
				OUTPUT inserted.Id,inserted.OrderNumber INTO @ids(id,ordernumber)
				FROM CDF.Fulfillment f
					INNER JOIN @orders o
						ON f.Id = o.Id
			END
		ELSE
			BEGIN
				INSERT INTO cdf.Fulfillment ([LastTransactionId], [VendorId], [SourceApplication], [OrderNumber], [QuantityOrdered], [QuantityConfirmed], [QuantityBackordered], [QuantityCancelled], [QuantitySlashed], [QuantityShipped], [QuantityInvoiced], [LastModifiedDateUTC], [LastModifiedUTCOffset], [RequestedShipMethod],[ReferenceNumber] )
				OUTPUT inserted.Id, inserted.OrderNumber INTO @ids (id, ordernumber)
					SELECT ISNULL(o.[LastTransactionId],0), o.[VendorId], o.[SourceApplication], o.[OrderNumber], o.[QuanityOrdered], 0, 0, 0, 0, 0, 0, @DTUTC, DATEDIFF(MINUTE, @DTUTC, @DT), o.[TransportMethod], o.ReferenceNumber
					FROM @orders o
			END
		
		INSERT into cdf.Orders ([FulfillmentId], [DateOrderRecorded], [OrderStatusId], [AllowBackorder], [AllowDistributionSplits], [OrderProductTypeId], [OrderProductId], [OrderProductDescription], [PromotionCode], [VendorOrderType], [OrderTaxSales], [OrderTaxFreight], [BillToName], [BillToPhone], [BillToAddress], [BillToCity], [BillToState], [BillToZip], [BillToCountryCode], [ShipToName], [ShipToPhone], [ShipToAddress], [ShipToCity], [ShipToState], [ShipToZip], [ShipToCountryCode], [GiftWrap], [GiftWrapFee], [SuppressPrice], [GiftMessage], [SpecialDeliveryInstructions], [MarketingMessage], [ImprintBook], [ImprintIndexCode], [ImprintText], [ImprintFont], [ImprintColor], [ImprintPosition], [OrderUnitPrice], [DateTimeInsertedUTC], [GreenLight],[DistributionCenterOverride])
		SELECT i.id, o.[DateOrderRecorded], o.[OrderStatusId], o.[AllowBackorder], o.[AllowDistriubtionSplits], o.[OrderProductType], o.[OrderProduct], o.[OrderProductDescription], o.[PromotionCode], o.[VendorOrderType], o.[OrderTaxSales], o.[OrderTaxFreight], o.[BillToName], o.[BillToPhone], o.[BillToAddress], o.[BillToCity], o.[BillToState], o.[BillToZip], o.[BillToCountryCode], o.[ShipToName], o.[ShipToPhone], o.[ShipToAddress], o.[ShipToCity], o.[ShipToState], o.[ShipToZip], o.[ShipToCountryCode], o.[GiftWrap], o.[GiftWrapFee], o.[SuppressPrice], o.[GiftMessage], o.[SpecialDeliveryInstructions], o.[MarketingMessage], o.[ImprintBook], o.[ImprintIndexCode], o.[ImprintText], o.[ImprintFont], o.[ImprintColor], o.[ImprintPosition], o.[OrderUnitPrice], @DTUTC, o.[GreenLight], o.[DistributionCenterOverride]
		FROM @ids i
			INNER JOIN @orders o
				ON o.OrderNumber = i.ordernumber
		SET @Success = 1
	
		COMMIT TRANSACTION cdf_orderfulfillment_insert
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION cdf_orderfulfillment_insert
		SET @Success = 0		
	END CATCH

	IF @Success =1
		SELECT i.Id, i.OrderNumber
		FROM @ids i
	ELSE
		SELECT -1 AS ID, '' AS OrderNumber
END

GO

