CREATE PROCEDURE cdf.uspVerifyPOA
(
	@venid VARCHAR(25)
)
AS
BEGIN
	SELECT f.OrderNumber, a.DateTimeInsertedUTC, poa.BatchId, tlpoa.[Filename]
	FROM cdf.Fulfillment f
		INNER JOIN CDF.Acknowledgements a
			ON f.id = a.FulfillmentId
		INNER JOIN importCDFL.PurchaseAcknowledgement_R40_LineItem poa
			ON LTRIM(RTRIM(f.OrderNumber)) = LTRIM(RTRIM(poa.PONumber))
		INNER JOIN EDI.TransactionLog tlpoa
			ON tlpoa.id = poa.BatchId
				AND RTRIM(tlpoa.[Filename]) LIKE '%.fbc'
	WHERE f.VendorId = @venid
END
GO
GRANT EXECUTE ON CDF.uspVerifyPOA TO AppDXUser
GO
CREATE PROCEDURE BLK.uspVerifyPOA
(
	@venid VARCHAR(25)
)
AS
BEGIN
	SELECT ah.PONumber, poain.id, poain.[Filename] 
	FROM BLK.AcknowledgeHeader ah 
		INNER JOIN (    SELECT tlpoa.id, tlpoa.[Filename], tlpoa.vendorid, popoa.PONumber 
						FROM EDI.TransactionLog tlpoa 
							INNER JOIN ImportBBV3.PurchaseAcknowledgement_R40_LineItem popoa
								ON tlpoa.id = popoa.BatchId 
						WHERE RTRIM(tlpoa.[Filename]) LIKE '%.fbc'
						GROUP BY tlpoa.id, tlpoa.[Filename], tlpoa.vendorid, popoa.PONumber ) poain 
			ON ah.PONumber = poain.PONumber 
				AND ah.VendorId = poain.VendorId 
	WHERE ah.VendorID = @venid
END
GO
GRANT EXECUTE ON BLK.uspVerifyPOA TO AppDXUser
GO
CREATE PROCEDURE CDF.uspVerifyASN
(
	@venid VARCHAR(25)
)
AS
BEGIN
	SELECT f.OrderNumber, s.DateTimeInsertedUTC, asn.BatchId, tlasn.[Filename]
	FROM cdf.Fulfillment f
		INNER JOIN CDF.Shipments s
			on f.id = s.FulfillmentId
		INNER JOIN importCDFL.ShipNotice_OD_OrderDetailRecord asn
			ON LTRIM(RTRIM(f.OrderNumber)) = LTRIM(RTRIM(asn.ClientOrderID))
		INNER JOIN EDI.TransactionLog tlasn
			ON tlasn.id = asn.BatchId
				AND RTRIM(tlasn.[Filename]) LIKE '%.pbs'
	WHERE f.VendorId = @venid
END
GO
GRANT EXECUTE ON CDF.uspVerifyASN TO AppDXUser
GO
CREATE PROCEDURE BLK.uspVerifyASN
(
	@venid VARCHAR(25)
)
AS
BEGIN
	SELECT sh.PONumber, sh.IssueDate, sh.VendorId, sh.InsertDateTime, asnin.id, asnin.[Filename]
	FROM BLK.ShipmentHeader sh
		INNER JOIN (    SELECT tlasn.id, tlasn.[Filename], tlasn.vendorid, poasn.PONumber 
						FROM EDI.TransactionLog tlasn 
							INNER JOIN ImportBBV3.ShipNotice_OR_ASNShipment poasn 
								ON tlasn.id = poasn.BatchId 
						WHERE RTRIM(tlasn.[Filename]) LIKE '%.pbs' 
						GROUP BY tlasn.id, tlasn.[Filename], tlasn.vendorid, poasn.PONumber ) asnin 
			ON sh.PONumber = asnin.PONumber 
				AND sh.VendorId = asnin.VendorId 
	WHERE sh.VendorID = @venid
END
GO
GRANT EXECUTE ON BLK.uspVerifyASN TO AppDXUser
GO
CREATE PROCEDURE CDF.uspVerifyINV
(
	@venid VARCHAR(25)
)
AS
BEGIN
	SELECT f.OrderNumber, i.DateTimeInsertedUTC, inv.BatchId, tlinv.[Filename]
	FROM CDF.Fulfillment f
		INNER JOIN cdf.Invoices i
			ON f.id = i.FulfillmentId
		INNER JOIN importCDFL.Invoice_R48_DetailTotal inv
			ON LTRIM(RTRIM(f.OrderNumber)) = LTRIM(RTRIM(inv.ClientOrderID))
		INNER JOIN EDI.TransactionLog tlinv
			ON tlinv.id = inv.BatchId
				AND RTRIM(tlinv.[Filename]) LIKE '%.bin'
	WHERE f.VendorId = @venid
END
GO
GRANT EXECUTE ON CDF.uspVerifyASN TO AppDXUser
GO
CREATE PROCEDURE BLK.uspVerifyINV
(
	@venid VARCHAR(25)
)
AS
BEGIN
	SELECT ih.PONumber, ih.IssueDate, ih.VendorId, ih.InsertDateTime, asnin.id, asnin.[Filename]
	FROM BLK.InvoiceHeader ih
		INNER JOIN (    SELECT tlinv.id, tlinv.[Filename], tlinv.vendorid, poinv.PONumber
						FROM EDI.TransactionLog tlinv
							INNER JOIN ImportBBV3.Invoice_R45_InvoiceDetail poinv
								ON tlinv.id = poinv.BatchId
						WHERE RTRIM(tlinv.[Filename]) LIKE '%.bin'
						GROUP by tlinv.id, tlinv.[Filename], tlinv.vendorid, poinv.PONumber ) asnin
			ON ih.PONumber = asnin.PONumber
				AND ih.VendorId = asnin.VendorId
	WHERE ih.VendorID = @venid
END
GO
GRANT EXECUTE ON BLK.uspVerifyINV TO AppDXUser