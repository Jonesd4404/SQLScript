CREATE PROCEDURE edi.RPT_WebOrdersCanceled
AS
BEGIN
	SELECT	 orderstatus.id
			,orderstatus.OrderNumber
			,orderstatus.OrderProductId
			,orderstatus.OrderProductDescription
			,orderstatus.ShipToName
			,orderstatus.hasPO
			,Canceled
			,CAST(orderstatus.DatePO AS VARCHAR(10)) AS DatePO
			,orderstatus.hasPOA
			,CAST(orderstatus.DatePOA AS VARCHAR(10)) AS DatePOA
			,orderstatus.POAStatusCode
			,c.CodeDescription AS Reason
	FROM (	SELECT	 f.id
					,f.OrderNumber
					,o.OrderProductId
					,o.OrderProductDescription
					,o.ShipToName
					,CASE 
						WHEN o.id IS NULL
							THEN 0
						ELSE 1
						END AS hasPO
					,CAST(o.DateOrderRecorded AS DATE) AS DatePO
					,CASE  WHEN a.id IS NULL THEN 0 ELSE 1 END AS hasPOA
					,CAST(a.DateAcknowledgementRecorded AS DATE) AS DatePOA
					,a.AcknowledgementStatusCode AS POAStatusCode
					,CASE WHEN a.AcknowledgementStatusCode = '00' THEN 0 ELSE 1 END AS Canceled
			FROM cdf.Fulfillment f
				INNER JOIN cdf.Orders o
					ON f.id = o.FulfillmentId
				INNER JOIN cdf.Acknowledgements a
					ON f.id = a.FulfillmentId ) orderstatus
		INNER JOIN MetaData.Codes c
			ON c.CodeTypeId = 44 -- poa status
				AND c.code = orderstatus.POAStatusCode
	WHERE Canceled = 1
	ORDER BY datepo ASC
END
GO

CREATE PROCEDURE edi.RPT_WebOrdersOpen
AS
BEGIN
	SELECT	 orderstatus.id
			,orderstatus.OrderNumber
			,orderstatus.OrderProductId
			,orderstatus.OrderProductDescription
			,orderstatus.ShipToName
			,orderstatus.hasPO
			,Canceled
			,cast(orderstatus.DatePO AS VARCHAR(10)) AS DatePO
			,orderstatus.hasPOA
			,cast(orderstatus.DatePOA AS VARCHAR(10)) AS DatePOA
			,orderstatus.POAStatusCode
			,orderstatus.hasASN
			,CASE WHEN canceled = 0 THEN CAST(orderstatus.DateASN AS VARCHAR(10))		 ELSE 'N/A' END AS DateASN
			,CASE WHEN canceled = 0 THEN CAST(orderstatus.DateShipped AS VARCHAR(10))	 ELSE 'N/A' END AS DateShipped
			,orderstatus.hasINV
			,CASE WHEN canceled = 0 THEN CAST(orderstatus.DateINV AS VARCHAR(10))		 ELSE 'N/A' END AS DateINV
			,CASE  WHEN canceled = 0 THEN cast(orderstatus.DateOfInvoice AS VARCHAR(10)) ELSE 'N/A' END AS DateOfInvoice
			,DATEDIFF(DAY, orderstatus.DatePO, GETDATE()) AS DaysSinceOrder
			,CASE WHEN canceled = 0 THEN CAST(DATEDIFF(DAY, orderstatus.DatePO, orderstatus.DateASN) AS VARCHAR(10)) ELSE 'N/A' END AS DaysToShip
			,CASE WHEN canceled = 0 THEN CAST(DATEDIFF(DAY, orderstatus.DatePO, orderstatus.DateINV) AS VARCHAR(10)) ELSE 'N/A' END AS DateToInvoice
	FROM (	SELECT	 f.id
					,f.OrderNumber
					,o.OrderProductId
					,o.OrderProductDescription
					,o.ShipToName
			,CASE WHEN o.id IS NULL THEN 0 ELSE 1 END AS hasPO
			,CAST(o.DateOrderRecorded AS DATE) AS DatePO
			,CASE WHEN a.id IS NULL THEN 0 ELSE 1 END AS hasPOA
			,CAST(a.DateAcknowledgementRecorded AS DATE) AS DatePOA
			,a.AcknowledgementStatusCode AS POAStatusCode
			,CASE WHEN a.AcknowledgementStatusCode = '00' THEN 0 ELSE 1 END AS Canceled
			,CASE  WHEN s.id IS NULL THEN 0 ELSE 1 END AS hasASN
			,CAST(s.DateTimeShipmentRecorded AS DATE) AS DateASN
			,CAST(s.DateOrderShipped AS DATE) AS DateShipped
			,CASE WHEN i.id IS NULL THEN 0 ELSE 1 END AS hasINV
			,CAST(i.DateTimeInvoiceRecorded AS DATE) AS DateINV
			,CAST(i.DateMetered AS DATE) AS DateOfInvoice
		FROM cdf.Fulfillment f
			LEFT JOIN cdf.Orders o
				ON f.id = o.FulfillmentId
			LEFT JOIN cdf.Acknowledgements a
				ON f.id = a.FulfillmentId
			LEFT JOIN cdf.Shipments s
				ON f.id = s.FulfillmentId
			LEFT JOIN (	SELECT ii.*
						FROM cdf.Invoices ii
						INNER JOIN (	SELECT	 MIN(Id) AS minid
												,FulfillmentId
										FROM cdf.Invoices
										GROUP BY FulfillmentId ) iii
							ON iii.minid = ii.Id ) i
				ON f.id = i.FulfillmentId ) orderstatus
	WHERE (hasPO + hasPOA + hasASN + hasINV) < 4
		AND Canceled = 0
	ORDER BY datepo ASC
END