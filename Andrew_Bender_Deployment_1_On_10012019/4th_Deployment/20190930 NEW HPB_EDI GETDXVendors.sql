CREATE PROCEDURE EDI.uspGetDXVendors
(
	@type varchar(10) = 'PO'
)
AS
BEGIN
	IF @type = 'PO'
		SELECT VendorId
		FROM EDI.ApplicationMaster
		WHERE PO__BULK LIKE 'DX:%'
		GROUP BY VendorId
	IF @type = 'POA'
		SELECT VendorId
		FROM EDI.ApplicationMaster
		WHERE POA_BULK LIKE 'DX:%'
		GROUP BY VendorId
	IF @type = 'ASN'
		SELECT VendorId
		FROM EDI.ApplicationMaster
		WHERE ASN_BULK LIKE 'DX:%'
		GROUP BY VendorId
	IF @type = 'INV'
		SELECT VendorId
		FROM EDI.ApplicationMaster
		WHERE INV_BULK LIKE 'DX:%'
		GROUP BY VendorId
END