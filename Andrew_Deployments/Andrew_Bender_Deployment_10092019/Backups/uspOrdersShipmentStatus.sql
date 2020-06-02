USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [CDF].[uspOrdersShipmentStatus]    Script Date: 10/9/2019 10:19:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
			SELECT	  fs.[Id], fs.[VendorId], fs.[SourceApplication], fs.[OrderNumber]
					, fs.[QuantityRemaining], fs.[QuantityOrdered], fs.[QuantityConfirmed], fs.[QuantityBackordered], fs.[QuantityCancelled], fs.[QuantitySlashed]
					, fs.[QuantityShipped], fs.[QuantityInvoiced]
					, fs.[LastModifiedDateUTC], fs.[LastModifiedUTCOffset], fs.[LastModifiedDateCentral]
					, fs.[HasOrder], fs.[OrderInsertedUTC] AS OrderInserted		
					, fs.[ShipToName], fs.[ShipToAddress], fs.[ShipToCity], fs.[ShipToState], fs.[ShipToZip], fs.[ShipToCountryCode]
					, fs.[GiftMessage], fs.[MarketingMessage], fs.[OrderProductId] , fs.[OrderProductTypeId], fs.[OrderProductDescription]
					, fs.[SpecialDeliveryInstructions]
					, fs.[HasAcknowledgement], fs.[AcknowledgementInsertedUTC] AS AcknowledgementInserted
					, fs.[HasShipment], fs.[ShipmentInsertedUTC] AS ShipmentInserted
					, fs.[CarrierName], fs.[CarrierType], fs.[PackageNumberTracking], fs.[PackageNumberSecondary], fs.[PackageWeight], fs.[ShipmentNumber]
					, fs.[ShipmentISBNorEAN]
					, fs.[HasInvoice], fs.[InvoiceInsertedUTC] AS InvoiceInserted
					, CAST(CASE WHEN tl.id IS NOT NULL
						   THEN 1 
						   ELSE 0
					  END AS BIT) AS ShipNoticedReceived
					,tl.DateTransmittedUTC AS DateTransmitted
					,tl.Method, tl.Direction, tl.Successful
					,DATEDIFF(MINUTE, tl.DateTransmittedUTC, GETUTCDATE()) AS ShipNotificationAge
			FROM CDF.vueFulfillmentStatus fs
				LEFT JOIN (	select tli.*, ton.OrderNumber, ton.id as TransactionOrderNumberId , case when tlm.TransLogID is not null then 1 else 0 end as Successful
							from edi.TransactionLog tli
								left join edi.TransactionLogOrderNumbers ton
									on tli.id = ton.TransactionLogId
								left join edi.TransactionLogMessages tlm
									on tlm.TransLogID = tli.id
										and tlm.KeyValue ='True'
										and tlm.KeyName = @findkey
						  ) tl
					ON fs.OrderNumber= tl.OrderNumber
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

			SELECT	  fs.[Id], fs.[VendorId], fs.[SourceApplication], fs.[OrderNumber]
					, fs.[QuantityRemaining], fs.[QuantityOrdered], fs.[QuantityConfirmed], fs.[QuantityBackordered], fs.[QuantityCancelled], fs.[QuantitySlashed]
					, fs.[QuantityShipped], fs.[QuantityInvoiced]
					, fs.[LastModifiedDateUTC], fs.[LastModifiedUTCOffset], fs.[LastModifiedDateCentral]
					, fs.[HasOrder], DATEADD(MINUTE, LastModifiedUTCOffset, fs.[OrderInsertedUTC]) AS OrderInserted		
					, fs.[ShipToName], fs.[ShipToAddress], fs.[ShipToCity], fs.[ShipToState], fs.[ShipToZip], fs.[ShipToCountryCode]
					, fs.[GiftMessage], fs.[MarketingMessage], fs.[OrderProductId] , fs.[OrderProductTypeId], fs.[OrderProductDescription]
					, fs.[SpecialDeliveryInstructions]
					, fs.[HasAcknowledgement], DATEADD(MINUTE, LastModifiedUTCOffset, fs.[AcknowledgementInsertedUTC]) AS AcknowledgementInserted
					, fs.[HasShipment], fs.[ShipmentInsertedUTC] AS ShipmentInserted
					, fs.[CarrierName], fs.[CarrierType], fs.[PackageNumberTracking], fs.[PackageNumberSecondary], fs.[PackageWeight], fs.[ShipmentNumber]
					, fs.[ShipmentISBNorEAN]
					, fs.[HasInvoice], DATEADD(MINUTE, fs.LastModifiedUTCOffset, fs.[InvoiceInsertedUTC]) AS InvoiceInserted
					, CAST(CASE WHEN tl.id IS NOT NULL
						   THEN 1 
						   ELSE 0
					  END AS BIT) AS ShipNoticedReceived
					,tl.DateTransmittedUTC, tl.Method, tl.Direction, tl.Successful
			FROM CDF.vueFulfillmentStatus fs
				LEFT JOIN (	select tli.*, ton.OrderNumber, ton.id as TransactionOrderNumberId , case when tlm.TransLogID is not null then 1 else 0 end as Successful
							from edi.TransactionLog tli
								left join edi.TransactionLogOrderNumbers ton
									on tli.id = ton.TransactionLogId
								left join edi.TransactionLogMessages tlm
									on tlm.TransLogID = tli.id
										and tlm.KeyValue ='True'
										and tlm.KeyName = @findkey
						  ) tl
					ON fs.OrderNumber = tl.OrderNumber
						AND tl.DateTransmittedUTC >= @UseDateTime
						AND tl.TransactionTypeId = 4 -- ASN/Ship Notie						
						AND tl.Successful = 1
			WHERE fs.HasOrder = 1
				AND CASE WHEN @WithShipmentOnly =1 
						 THEN CASE WHEN DATEADD(MINUTE, fs.LastModifiedUTCOffset,  tl.DateTransmittedUTC) >= @UseDateTime 
								   THEN 1 
								   ELSE 0
							  END
						ELSE CASE WHEN DATEADD(MINUTE, fs.LastModifiedUTCOffset, fs.LastModifiedDateUTC) >= @UseDateTime
								  THEN 1
								  ELSE 0
							  END
					END = 1
		END		
END

GO

