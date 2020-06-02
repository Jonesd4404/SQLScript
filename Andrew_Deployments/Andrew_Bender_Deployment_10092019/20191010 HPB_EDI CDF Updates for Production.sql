DROP PROCEDURE [CDF].[uspInvoice_Insert]
DROP PROCEDURE [CDF].[uspShipment_Insert]
DROP PROCEDURE [CDF].[uspAcknowledge_Insert]
DROP PROCEDURE [CDF].[uspFulfillment_Insert]
DROP TYPE [CDF].[TypeFulfillment]
DROP PROCEDURE [CDF].[uspGetUnprocessedOrders]
DROP PROCEDURE [CDF].[uspOrderFulfillment_Insert]
DROP PROCEDURE [CDF].[uspOrdersShipmentStatus]

DROP VIEW [CDF].[vueFulfillmentStatus]
GO

CREATE TYPE [CDF].[TypeFulfillment] AS TABLE(
	[Id] [bigint] NULL,
	[LastTransactionId] [tinyint] NULL,
	[VendorId] [varchar](20) NULL,
	[SourceApplication] [varchar](20) NULL,
	[OrderNumber] [varchar](22) NULL,
	[QuantityOrdered] [int] NULL,
	[QuantityConfirmed] [int] NULL,
	[QuantityBackordered] [int] NULL,
	[QuantityCancelled] [int] NULL,
	[QuantitySlashed] [int] NULL,
	[QuantityShipped] [int] NULL,
	[QuantityInvoiced] [int] NULL,
	[LastModifiedDateUTC] [datetime2](7) NULL,
	[LastModifiedUTCOffset] [int] NULL,
	[RequestedShipMethod] [char](3) NULL,
	[ReferenceNumber] [varchar](20) NULL
)
GO
/* =================================================================================================================================================== */
CREATE VIEW [CDF].[vueFulfillmentStatus]
AS
	SELECT	 f.Id 
			,f.VendorId 
			,f.SourceApplication 
			,f.OrderNumber 
			,CAST(CASE WHEN f.QuantityOrdered <= (f.QuantityCancelled + f.QuantitySlashed) THEN 1 ELSE 0 END AS BIT) AS OrderCancelled
			,f.QuantityOrdered - (f.QuantityBackordered + f.QuantityCancelled + f.QuantityShipped) AS QuantityRemaining
			,f.QuantityOrdered 
			,f.QuantityConfirmed 
			,f.QuantityBackordered 
			,f.QuantityCancelled 
			,f.QuantitySlashed 
			,f.QuantityShipped 
			,f.QuantityInvoiced
			,f.LastModifiedDateUTC 
			,f.LastModifiedUTCOffset 
			,DATEADD(MINUTE, f.LastModifiedUTCOffset, f.LastModifiedDateUTC) AS LastModifiedDateCentral
			-- 
			,CAST(CASE WHEN o.Id IS NOT NULL THEN 1  ELSE 0 END AS BIT) AS HasOrder
			,o.DateTimeInsertedUTC AS OrderInsertedUTC
			,o.BillToName
			,o.BillToAddress
			,o.BillToCity
			,o.BillToState
			,o.BillToZip
			,o.BillToCountryCode
			,o.ShipToName
			,o.ShipToAddress
			,o.ShipToCity
			,o.ShipToState
			,o.ShipToZip
			,o.ShipToCountryCode
			,o.GiftMessage
			,o.MarketingMessage
			,o.OrderProductId
			,o.OrderProductTypeId
			,o.OrderProductDescription
			,o.SpecialDeliveryInstructions
			-- 
			,CAST(CASE WHEN a.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasAcknowledgement
			,a.DateTimeInsertedUTC AS AcknowledgementInsertedUTC 
			,a.DateAcknowledgementRecorded 
			,a.AcknowledgementStatusCode
			,CodesPOA.CodeDescription as POAStatusCode
			,a.VendorAcknowledgeMessage
			-- 
			,CAST(CASE WHEN s.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasShipment
			,s.DateTimeInsertedUTC AS ShipmentInsertedUTC
			,s.DateTimeShipmentRecorded
			,s.DateOrderShipped
			,s.CarrierName
			,s.CarrierType
			,s.PackageNumberTracking
			,s.PackageNumberSecondary
			,s.PackageWeight
			,s.ShipmentNumber
			,s.ShipmentISBNorEAN
			,s.ReasonCode
			,CodesASN.CodeDescription
			-- 
			,CAST(CASE WHEN i.FulfillmentId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasInvoice
			,i.DateTimeInsertedUTC AS InvoiceInsertedUTC
			,i.DateTimeInvoiceRecorded
			,i.InvoiceNumber
			,i.InvoiceAmountDue
			-- 
	FROM CDF.Fulfillment f
		LEFT JOIN CDF.Orders o
			ON f.Id = o.FulfillmentId
		LEFT JOIN CDF.Acknowledgements a
			ON f.Id = a.FulfillmentId
		LEFT JOIN CDF.Shipments s
			ON f.Id = s.FulfillmentId

		LEFT JOIN (	SELECT  i0.FulfillmentId,MIN(i0.DateTimeInvoiceRecorded) as DateTimeInvoiceRecorded
							,MAX(ISNULL(b.InvoiceNumber,'')) as InvoiceNumber, SUM(i0.InvoicePriceList) as InvoicePriceList
							,SUM(i0.Invoicediscount) as InvoiceDiscount,SUM(i0.InvoicePriceNet) as IvnvoicePriceNet, SUM(i0.InvoicePriceShipping) as InvoicePriceShipping
							,SUM(i0.invoicePriceHandling) as InvoicePriceHandling,SUM(i0.InvoicePriceGiftWrapFee) as InvoicePriceGiftWrapFee, SUM(i0.InvoiceAmountDue) as InvoiceAmountDue
							,MAX(i0.DateTimeInsertedUTC) as DateTimeInsertedUTC
							,MAX(ISNULL(i0.InvoiceClientOrderNumber,'')) as InvoiceClientOrderNumber
					FROM cdf.Invoices i0
						LEFT JOIN  (SELECT i1.InvoiceNumber, i1.InvoiceTitle, i1.InvoiceClientOrderNumber, i1.FulfillmentId
									FROM cdf.invoices i1
										LEFT JOIN MetaData.InvoiceTypes it
											ON LTRIM(RTRIM(i1.InvoiceTitle)) = it.InvoiceType
									WHERE it.Id IS NULL) b
							ON i0.FulfillmentId = b.FulfillmentId
					GROUP BY i0.FulfillmentId ) i
			ON f.Id = i.FulfillmentId
		LEFT JOIN (	SELECT c.*
					FROM metadata.codes c
						INNER JOIN metadata.CodeTypes ct
							on c.CodeTypeId = ct.id
								and ct.CodeType = 'POA Status'
						INNER JOIN MetaData.FileFormats ff
							on ct.FileFormatId = ff.Id
								and ff.FileFormat = 'CDFL'
					) CodesPOA
			ON a.AcknowledgementStatusCode = CodesPOA.Code 
		LEFT JOIN (	SELECT c.*
					FROM metadata.codes c
						INNER JOIN metadata.CodeTypes ct
							on c.CodeTypeId = ct.id
								and ct.CodeType in ('ASN Order and Item Status','ASN Slash/Cancel Quantity Reason Codes','Shipping Options-ASN')
						INNER JOIN MetaData.FileFormats ff
							on ct.FileFormatId = ff.Id
								and ff.FileFormat = 'CDFL'
					) CodesASN
			ON s.ReasonCode = CodesASN.Code
		
GO
/* =================================================================================================================================================== */
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
					,ReferenceNumber = f0.ReferenceNumber
			OUTPUT inserted.Id,inserted.OrderNumber INTO @mods(id,ordernumber)
			FROM CDF.Fulfillment f
				INNER JOIN @Fulfillment f0
					ON f.Id = f0.Id
		ELSE
			BEGIN
				INSERT INTO cdf.Fulfillment (LastTransactionId, VendorId, SourceApplication, OrderNumber, QuantityOrdered, QuantityConfirmed, QuantityBackordered, QuantityCancelled
											,QuantitySlashed,QuantityShipped, QuantityInvoiced, LastModifiedDateUTC, LastModifiedUTCOffset,RequestedShipMethod, ReferenceNumber)
				OUTPUT inserted.id INTO @mods (id)
					SELECT	 f0.LastTransactionId, f0.VendorId, f0.SourceApplication, f0.OrderNumber, f0.QuantityOrdered ,f0.QuantityConfirmed, f0.QuantityBackordered,f0.QuantityCancelled
							,f0.QuantitySlashed,f0.QuantityShipped, f0.QuantityInvoiced, GETUTCDATE(), DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()) ,f0.RequestedShipMethod, f0.ReferenceNumber				
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
					,a.[PriceNet], a.[PriceDiscountedList], CASE WHEN ISNULL(a.[DateTimeInsertedUTC],'1/1/0001') < '1/1/2000' THEN GETUTCDATE() ELSE a.[DateTimeInsertedUTC] END
			FROM @acknowledgement  a
				INNER JOIN @mods m
					ON LTRIM(RTRIM(a.OrderNumber)) = LTRIM(RTRIM(m.ordernumber))

		UPDATE f
			SET QuantityConfirmed = a.QuantityPredicted
		FROM cdf.Fulfillment f
			INNER JOIN @mods m
				ON LTRIM(RTRIM(f.OrderNumber)) = LTRIM(RTRIM(m.ordernumber))
			INNER JOIN @acknowledgement a
				ON LTRIM(RTRIM(a.OrderNumber)) = LTRIM(RTRIM(m.ordernumber))

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
/* =================================================================================================================================================== */
CREATE PROCEDURE [CDF].[uspFulfillment_Insert]
(	
	 @fulfillment AS CDF.TypeFulfillment READONLY
)
AS
BEGIN
	DECLARE @mods AS TABLE (id BIGINT, ordernumber VARCHAR(22))

	IF EXISTS( SELECT 1 FROM @Fulfillment f0 INNER JOIN cdf.Fulfillment f1 ON f0.Id = f1.Id )
		BEGIN
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
					,ReferenceNumber = f0.ReferenceNumber
			OUTPUT inserted.Id,inserted.OrderNumber INTO @mods(id,ordernumber)
			FROM CDF.Fulfillment f
				INNER JOIN @Fulfillment f0
					ON f.Id = f0.Id
		END
	ELSE
		BEGIN
				INSERT INTO cdf.Fulfillment (LastTransactionId, VendorId, SourceApplication, OrderNumber, QuantityOrdered, QuantityConfirmed, QuantityBackordered, QuantityCancelled
											,QuantitySlashed,QuantityShipped, QuantityInvoiced, LastModifiedDateUTC, LastModifiedUTCOffset,RequestedShipMethod, ReferenceNumber)
				OUTPUT inserted.id INTO @mods (id)
					SELECT	 f0.LastTransactionId, f0.VendorId, f0.SourceApplication, f0.OrderNumber, f0.QuantityOrdered ,f0.QuantityConfirmed, f0.QuantityBackordered,f0.QuantityCancelled
							,f0.QuantitySlashed,f0.QuantityShipped, f0.QuantityInvoiced, GETUTCDATE(), DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()) ,f0.RequestedShipMethod, f0.ReferenceNumber				
					FROM @Fulfillment f0
		END

		SELECT id, ordernumber
		FROM @mods
END
GO
/* =================================================================================================================================================== */
CREATE PROCEDURE [CDF].[uspGetUnprocessedOrders]
AS
BEGIN
	SELECT	 f.OrderNumber
			,f.VendorId
	FROM CDF.Fulfillment f 
	WHERE  LastTransactionId = 0
END
GO
/* =================================================================================================================================================== */
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
					,ReferenceNumber = f0.ReferenceNumber
			OUTPUT inserted.Id,inserted.OrderNumber INTO @mods(id,ordernumber)
			FROM CDF.Fulfillment f
				INNER JOIN @Fulfillment f0
					ON f.Id = f0.Id
		ELSE
			INSERT INTO cdf.Fulfillment (LastTransactionId, VendorId, SourceApplication, OrderNumber, QuantityOrdered, QuantityConfirmed, QuantityBackordered, QuantityCancelled
										,QuantitySlashed,QuantityShipped, QuantityInvoiced, LastModifiedDateUTC, LastModifiedUTCOffset,RequestedShipMethod, ReferenceNumber)
			OUTPUT inserted.id, inserted.OrderNumber INTO @mods (id, ordernumber)
				SELECT	 f0.LastTransactionId, f0.VendorId, f0.SourceApplication, f0.OrderNumber, f0.QuantityOrdered,f0.QuantityConfirmed, f0.QuantityBackordered,f0.QuantityCancelled
						,f0.QuantitySlashed,f0.QuantityShipped, f0.QuantityInvoiced, GETUTCDATE(), DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()) ,f0.RequestedShipMethod, f0.ReferenceNumber				
				FROM @Fulfillment f0

		INSERT INTO cdf.Invoices ([FulfillmentId], [DateTimeInvoiceRecorded], [InvoiceNumber], [CurrencyCode], [CountryCode], [InvoicePriceList], [InvoiceDiscount], [InvoicePriceNet]
								 ,[InvoicePriceShipping], [InvoicePriceHAndling], [InvoicePriceGiftWrapFee], [InvoiceAmountDue], [DateMetered], [InvoiceTitle], [InvoiceClientOrderNumber]
								 ,[LineItemNumber], [BillOfLadingNumber], [DateTimeInsertedUTC])
		OUTPUT inserted.id, inserted.FulfillmentId into @inst (id, linkid)
			SELECT	 m.id as [FulfillmentId], i.[DateTimeInvoiceRecorded], i.[InvoiceNumber], i.[CurrencyCode], i.[CountryCode],i.[InvoicePriceList], i.[InvoiceDiscount], i.[InvoicePriceNet]
					,i.[InvoicePriceShipping],i.[InvoicePriceHAndling], i.[InvoicePriceGiftWrapFee], i.[InvoiceAmountDue], i.[DateMetered],i.[InvoiceTitle], i.[InvoiceClientOrderNumber]
					,i.[LineItemNumber], i.[BillOfLadingNumber],CASE WHEN ISNULL(i.[DateTimeInsertedUTC],'1/1/0001') < '1/1/2000' THEN GETUTCDATE() ELSE i.[DateTimeInsertedUTC] END
			FROM @invoices i
				INNER JOIN @mods m
					ON LTRIM(RTRIM(i.OrderNumber))= LTRIM(RTRIM(m.ordernumber))
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
/* =================================================================================================================================================== */
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
					,ReferenceNumber = o.ReferenceNumber
				OUTPUT inserted.Id,inserted.OrderNumber INTO @ids(id,ordernumber)
				FROM CDF.Fulfillment f
					INNER JOIN @orders o
						ON f.Id = o.Id
			END
		ELSE
			BEGIN
				INSERT INTO cdf.Fulfillment ([LastTransactionId], [VendorId], [SourceApplication], [OrderNumber], [QuantityOrdered], [QuantityConfirmed], [QuantityBackordered], [QuantityCancelled], [QuantitySlashed], [QuantityShipped], [QuantityInvoiced], [LastModifiedDateUTC], [LastModifiedUTCOffset], [RequestedShipMethod],[ReferenceNumber])
				OUTPUT inserted.Id, inserted.OrderNumber INTO @ids (id, ordernumber)
					SELECT ISNULL(o.[LastTransactionId],0), o.[VendorId], o.[SourceApplication], o.[OrderNumber], o.[QuanityOrdered], 0, 0, 0, 0, 0, 0, @DTUTC, DATEDIFF(MINUTE, @DTUTC, @DT), o.[TransportMethod], o.ReferenceNumber
					FROM @orders o
			END
		
		INSERT into cdf.Orders ([FulfillmentId], [DateOrderRecorded], [OrderStatusId], [AllowBackorder], [AllowDistributionSplits], [OrderProductTypeId], [OrderProductId], [OrderProductDescription], [PromotionCode], [VendorOrderType], [OrderTaxSales], [OrderTaxFreight], [BillToName], [BillToPhone], [BillToAddress], [BillToCity], [BillToState], [BillToZip], [BillToCountryCode], [ShipToName], [ShipToPhone], [ShipToAddress], [ShipToCity], [ShipToState], [ShipToZip], [ShipToCountryCode], [GiftWrap], [GiftWrapFee], [SuppressPrice], [GiftMessage], [SpecialDeliveryInstructions], [MarketingMessage], [ImprintBook], [ImprintIndexCode], [ImprintText], [ImprintFont], [ImprintColor], [ImprintPosition], [OrderUnitPrice], [DateTimeInsertedUTC], [GreenLight],[DistributionCenterOverride])
		SELECT i.id, o.[DateOrderRecorded], o.[OrderStatusId], o.[AllowBackorder], o.[AllowDistriubtionSplits], o.[OrderProductType], o.[OrderProduct], o.[OrderProductDescription], o.[PromotionCode], o.[VendorOrderType], o.[OrderTaxSales], o.[OrderTaxFreight], o.[BillToName], o.[BillToPhone], o.[BillToAddress], o.[BillToCity], o.[BillToState], o.[BillToZip], o.[BillToCountryCode], o.[ShipToName], o.[ShipToPhone], o.[ShipToAddress], o.[ShipToCity], o.[ShipToState], o.[ShipToZip], o.[ShipToCountryCode], o.[GiftWrap], o.[GiftWrapFee], o.[SuppressPrice], o.[GiftMessage], o.[SpecialDeliveryInstructions], o.[MarketingMessage], o.[ImprintBook], o.[ImprintIndexCode], o.[ImprintText], o.[ImprintFont], o.[ImprintColor], o.[ImprintPosition], o.[OrderUnitPrice], @DTUTC, o.[GreenLight], o.[DistributionCenterOverride]
		FROM @ids i
			INNER JOIN @orders o
				ON LTRIM(RTRIM(o.OrderNumber)) = LTRIM(RTRIM(i.ordernumber))
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
/* =================================================================================================================================================== */
CREATE PROCEDURE [CDF].[uspOrdersShipmentStatus]
(
	 @LastDateTime DATETIME2
	,@IsUTC BIT = 1
	,@WithShipmentOnly BIT = 0
	,@findkey VARCHAR(50) = 'CDFL-ORD-ORDER-CREATE'
)
AS
BEGIN
	DECLARE @UseDateTime DATETIME2

	IF @IsUTC = 1
		BEGIN
			SET @UseDateTime = @LastDateTime
			SELECT	 fs.[Id]
					,fs.[VendorId]
					,fs.[SourceApplication]
					,fs.[OrderNumber]
					,fs.[QuantityRemaining]
					,fs.[QuantityOrdered]
					,fs.[QuantityConfirmed]
					,fs.[QuantityBackordered]
					,fs.[QuantityCancelled]
					,fs.[QuantitySlashed]
					,fs.[QuantityShipped]
					,fs.[QuantityInvoiced]
					,fs.[LastModifiedDateUTC]
					,fs.[LastModifiedUTCOffset]
					,fs.[LastModifiedDateCentral]
					,fs.[HasOrder]
					,fs.[OrderInsertedUTC] AS OrderInserted		
					,fs.[BillToAddress]
					,fs.[BillToCity]
					,fs.[BillToCountryCode]
					,fs.[BillToName]
					,fs.[BillToState]
					,fs.[BillToZip]
					,fs.[ShipToName]
					,fs.[ShipToAddress]
					,fs.[ShipToCity]
					,fs.[ShipToState]
					,fs.[ShipToZip]
					,fs.[ShipToCountryCode]
					,fs.[GiftMessage]
					,fs.[MarketingMessage]
					,fs.[OrderProductId]
					,fs.[OrderProductTypeId]
					,fs.[OrderProductDescription]
					,fs.[SpecialDeliveryInstructions]
					,fs.[HasAcknowledgement]
					,fs.[AcknowledgementInsertedUTC] AS AcknowledgementInserted
					,fs.[HasShipment]
					,fs.[ShipmentInsertedUTC] AS ShipmentInserted
					,fs.[CarrierName]
					,fs.[CarrierType]
					,fs.[PackageNumberTracking]
					,fs.[PackageNumberSecondary]
					,fs.[PackageWeight]
					,fs.[ShipmentNumber]
					,fs.[ShipmentISBNorEAN]
					,fs.[HasInvoice], fs.[InvoiceInsertedUTC] AS InvoiceInserted
					,CAST(CASE WHEN tl.id IS NOT NULL
						   THEN 1 
						   ELSE 0
					 END AS BIT) AS ShipNoticedReceived
					,tl.DateTransmittedUTC AS DateTransmitted
					,tl.Method
					,tl.Direction
					,tl.Successful
					,DATEDIFF(MINUTE, tl.DateTransmittedUTC, GETUTCDATE()) AS ShipNotificationAge
			FROM CDF.vueFulfillmentStatus fs
				LEFT JOIN (	SELECT tli.*, ton.OrderNumber, ton.id AS TransactionOrderNumberId , CASE WHEN tlm.TransLogID IS NOT NULL THEN 1 ELSE 0 END AS Successful
							FROM edi.TransactionLog tli
								LEFT JOIN edi.TransactionLogOrderNumbers ton
									ON tli.id = ton.TransactionLogId
								LEFT JOIN edi.TransactionLogMessages tlm
									ON tlm.TransLogID = tli.id
										AND tlm.KeyValue ='True'
										AND tlm.KeyName = @findkey
						  ) tl
					ON LTRIM(RTRIM(fs.OrderNumber))= LTRIM(RTRIM(tl.OrderNumber))
						AND tl.DateTransmittedUTC >= @UseDateTime
						AND tl.TransactionTypeId = 4 -- ASN/Ship Notie						
						AND tl.Successful = 1
			WHERE fs.HasOrder = 1
				AND CASE WHEN @WithShipmentOnly =1 
						 THEN CASE WHEN tl.DateTransmittedUTC >= @UseDateTime 
								   THEN 1 
								   ELSE 0
							  END
						ELSE CASE WHEN fs.LastModifiedDateUTC >= @UseDateTime
								  THEN 1
								  ELSE 0
							 END
					END = 1
		END
	ELSE
		BEGIN
			SET @UseDateTime = DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()), @LastdateTime)

		SELECT	 fs.[Id]
				,fs.[VendorId]
				,fs.[SourceApplication]
				,fs.[OrderNumber]
				,fs.[QuantityRemaining]
				,fs.[QuantityOrdered]
				,fs.[QuantityConfirmed]
				,fs.[QuantityBackordered]
				,fs.[QuantityCancelled]
				,fs.[QuantitySlashed]
				,fs.[QuantityShipped]
				,fs.[QuantityInvoiced]
				,fs.[LastModifiedDateUTC]
				,fs.[LastModifiedUTCOffset]
				,fs.[LastModifiedDateCentral]
				,fs.[HasOrder]
				,CASE WHEN fs.OrderInsertedUTC IS NOT NULL AND fs.OrderInsertedUTC > CAST('2000-01-01' AS DATETIME2)
					   THEN DATEADD(MINUTE, LastModifiedUTCOffset, fs.[OrderInsertedUTC])
					   ELSE NULL 
				 END AS OrderInserted		
					,fs.[BillToAddress]
					,fs.[BillToCity]
					,fs.[BillToCountryCode]
					,fs.[BillToName]
					,fs.[BillToState]
					,fs.[BillToZip]
				,fs.[ShipToName]
				,fs.[ShipToAddress]
				,fs.[ShipToCity]
				,fs.[ShipToState]
				,fs.[ShipToZip]
				,fs.[ShipToCountryCode]
				,fs.[GiftMessage]
				,fs.[MarketingMessage]
				,fs.[OrderProductId] 
				,fs.[OrderProductTypeId]
				,fs.[OrderProductDescription]
				,fs.[SpecialDeliveryInstructions]
				,fs.[HasAcknowledgement]
				,CASE WHEN fs.[AcknowledgementInsertedUTC] IS NOT NULL AND fs.[AcknowledgementInsertedUTC] > CAST('2000-01-01' AS DATETIME2)
					   THEN DATEADD(MINUTE, LastModifiedUTCOffset, fs.[AcknowledgementInsertedUTC])
					   ELSE NULL
				 END AS AcknowledgementInserted
				,fs.[HasShipment]
				,fs.[ShipmentInsertedUTC] AS ShipmentInserted
				,fs.[CarrierName]
				,fs.[CarrierType]
				,fs.[PackageNumberTracking]
				,fs.[PackageNumberSecondary]
				,fs.[PackageWeight]
				,fs.[ShipmentNumber]
				,fs.[ShipmentISBNorEAN]
				,fs.[HasInvoice]
				,CASE WHEN fs.[InvoiceInsertedUTC] IS NOT NULL AND fs.[InvoiceInsertedUTC]  > CAST('2000-01-01' AS DATETIME2)
					  THEN DATEADD(MINUTE, fs.LastModifiedUTCOffset, fs.[InvoiceInsertedUTC])
					  ELSE NULL
				    END AS InvoiceInserted
				,CAST(CASE WHEN tl.id IS NOT NULL
					   THEN 1 
					   ELSE 0
				 END AS BIT) AS ShipNoticedReceived
				,tl.DateTransmittedUTC
				,tl.Method
				,tl.Direction
				,tl.Successful
			FROM CDF.vueFulfillmentStatus fs
				LEFT JOIN (	SELECT tli.*, ton.OrderNumber, ton.id AS TransactionOrderNumberId , CASE WHEN tlm.TransLogID IS NOT NULL THEN 1 ELSE 0 END AS Successful
							FROM edi.TransactionLog tli
								LEFT JOIN edi.TransactionLogOrderNumbers ton
									ON tli.id = ton.TransactionLogId
								LEFT JOIN edi.TransactionLogMessages tlm
									ON tlm.TransLogID = tli.id
										AND tlm.KeyValue ='True'
										AND tlm.KeyName = @findkey
						  ) tl
					ON LTRIM(RTRIM(fs.OrderNumber)) = LTRIM(RTRIM(tl.OrderNumber))
						AND tl.DateTransmittedUTC >= @UseDateTime
						AND tl.TransactionTypeId = 4 -- ASN/Ship Notie						
						AND tl.Successful = 1
			WHERE fs.HasOrder = 1
				AND CASE WHEN @WithShipmentOnly =1 
						 THEN CASE WHEN fs.[ShipmentInsertedUTC] IS NOT NULL AND fs.[ShipmentInsertedUTC] > CAST('2000-01-01' AS DATETIME2)
						           THEN CASE WHEN DATEADD(MINUTE, fs.LastModifiedUTCOffset, fs.ShipmentInsertedUTC) >= @UseDateTime 
											 THEN 1
											 ELSE 0
										END
									ELSE 0
							   END						
						ELSE CASE WHEN fs.[AcknowledgementInsertedUTC] IS NOT NULL AND fs.[AcknowledgementInsertedUTC] > CAST('2000-01-01' AS DATETIME2)
								  THEN CASE WHEN DATEADD(MINUTE, fs.LastModifiedUTCOffset, fs.AcknowledgementInsertedUTC) >= @UseDateTime
											THEN 1
											ELSE 0
									   END
								  ELSE 0
							END
					END = 1
		END		
END
GO
/* =================================================================================================================================================== */
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
			BEGIN
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
						,ReferenceNumber = f0.ReferenceNumber
				OUTPUT inserted.Id,inserted.OrderNumber into @mods(id,ordernumber)
				FROM CDF.Fulfillment f
					INNER JOIN @fulfillment f0
						ON f.Id = f0.id
			END
		ELSE
			BEGIN
				INSERT INTO CDF.Fulfillment (LastTransactionId, VendorId, SourceApplication, OrderNumber, QuantityOrdered, QuantityConfirmed, QuantityBackordered, QuantityCancelled
											,QuantitySlashed,QuantityShipped, QuantityInvoiced, LastModifiedDateUTC, LastModifiedUTCOffset,RequestedShipMethod, ReferenceNumber)
				OUTPUT inserted.id, inserted.OrderNumber INTO @mods (id, ordernumber)
					SELECT	 f0.LastTransactionId, f0.VendorId, f0.SourceApplication, f0.OrderNumber, f0.QuantityOrdered,f0.QuantityConfirmed, f0.QuantityBackordered,f0.QuantityCancelled
							,f0.QuantitySlashed,f0.QuantityShipped, f0.QuantityInvoiced, GETUTCDATE(), DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()) ,f0.RequestedShipMethod, f0.ReferenceNumber				
					FROM @Fulfillment f0
			END

		INSERT INTO cdf.Shipments ([FulfillmentId], [DateTimeShipmentRecorded], [ShipmentNumber], [ShipmentSubtotal], [ShipmentDiscount], [ShipmentTaxSales], [ShipmentFees]
								  ,[ShipmentFreight], [ShipmentTotal], [DateOrderShipped], [CustomerOrderReference], [CarrierType], [CarrierName], [PackageNumberTracking], [PackageNumberSecondary]
								  ,[ShipmentPriceList], [ShipmentPriceNet], [PackageWeight], [ReasonCode], [ShipmentISBNorEAN], [WarehouseCode], [DateTimeInsertedUTC] )
		OUTPUT inserted.id, inserted.FulfillmentId into @inst (id, linkid)
			SELECT	 m.id, s.[DateTimeShipmentRecorded], s.[ShipmentNumber], s.[ShipmentSubtotal],s.[ShipmentDiscount], s.[ShipmentTaxSales], s.[ShipmentFees]
					,s.[ShipmentFreight], s.[ShipmentTotal],s.[DateOrderShipped], s.[CustomerOrderReference], s.[CarrierType], s.[CarrierName],s.[PackageNumberTracking], s.[PackageNumberSecondary]
					,s.[ShipmentPriceList], s.[ShipmentPriceNet],s.[PackageWeight], s.[ReasonCode], s.[ShipmentISBNorEAN], s.[WarehouseCode], CASE WHEN ISNULL(s.[DateTimeInsertedUTC],'1/1/0001') < '1/1/2000' THEN GETUTCDATE() ELSE s.[DateTimeInsertedUTC] END	
			FROM @shipment s
				INNER JOIN @mods m
					ON LTRIM(RTRIM(s.OrderNumber)) = LTRIM(RTRIM(m.ordernumber))

		UPDATE f
			SET	 QuantityShipped = ISNULL(s.QuantityShipped,0)
				,QuantitySlashed = ISNULL(s.QuantitySlashed,0)
		FROM cdf.Fulfillment f
			INNER JOIN @mods m
				ON LTRIM(RTRIM(f.OrderNumber)) = LTRIM(RTRIM(m.ordernumber))
			INNER JOIN @shipment s
				ON LTRIM(RTRIM(s.OrderNumber)) = LTRIM(RTRIM(m.ordernumber))


		IF @@TRANCOUNT > 0 COMMIT TRANSACTION insert_asn
		SET @succ = 1
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION insert_asn
		SET @succ = 0
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
/* =================================================================================================================================================== */
