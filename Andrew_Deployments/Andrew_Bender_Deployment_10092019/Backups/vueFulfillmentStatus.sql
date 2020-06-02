USE [HPB_EDI]
GO

/****** Object:  View [CDF].[vueFulfillmentStatus]    Script Date: 10/9/2019 10:21:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
			-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
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
			-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
			,CAST(CASE WHEN a.Id IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasAcknowledgement
			,a.DateTimeInsertedUTC AS AcknowledgementInsertedUTC 
			,a.DateAcknowledgementRecorded 
			,a.AcknowledgementStatusCode
			,CodesPOA.CodeDescription as POAStatusCode
			,a.VendorAcknowledgeMessage
			-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
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
			-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
			,CAST(CASE WHEN i.FulfillmentId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasInvoice
			,i.DateTimeInsertedUTC AS InvoiceInsertedUTC
			,i.DateTimeInvoiceRecorded
			,i.InvoiceNumber
			,i.InvoiceAmountDue
			-- ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬						
	FROM CDF.Fulfillment f
		LEFT JOIN CDF.Orders o
			ON f.Id = o.FulfillmentId
		LEFT JOIN CDF.Acknowledgements a
			ON f.Id = a.FulfillmentId
		LEFT JOIN CDF.Shipments s
			ON f.Id = s.FulfillmentId
		LEFT JOIN (	SELECT  i0.FulfillmentId,min(i0.DateTimeInvoiceRecorded) as DateTimeInvoiceRecorded, b.InvoiceNumber, SUM(i0.InvoicePriceList) as InvoicePriceList
							,SUM(i0.Invoicediscount) as InvoiceDiscount,SUM(i0.InvoicePriceNet) as IvnvoicePriceNet, SUM(i0.InvoicePriceShipping) as InvoicePriceShipping
							,SUM(i0.invoicePriceHandling) as InvoicePriceHandling,SUM(i0.InvoicePriceGiftWrapFee) as InvoicePriceGiftWrapFee, SUM(i0.InvoiceAmountDue) as InvoiceAmountDue
							,MIN(i0.DateTimeInsertedUTC) as DateTimeInsertedUTC
							,i0.InvoiceClientOrderNumber			
					FROM cdf.Invoices i0
						LEFT JOIN  (SELECT i1.*
									FROM cdf.invoices i1
										LEFT JOIN MetaData.InvoiceTypes it
											ON i1.InvoiceTitle = it.InvoiceType
									WHERE it.Id IS NULL) b
							ON i0.FulfillmentId = b.FulfillmentId
					GROUP BY i0.FulfillmentId, i0.InvoiceClientOrderNumber, b.InvoiceNumber ) i
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

