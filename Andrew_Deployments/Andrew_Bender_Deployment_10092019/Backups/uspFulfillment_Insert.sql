USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [CDF].[uspFulfillment_Insert]    Script Date: 10/9/2019 10:11:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [CDF].[uspFulfillment_Insert] (@Fulfillment AS dbo.TypeListString250 readonly)
AS
BEGIN
	DECLARE @mods AS TABLE 
	(
		id BIGINT
		,ordernumber VARCHAR(22)
	)

	IF EXISTS (SELECT 1 FROM @Fulfillment f0 INNER JOIN cdf.Fulfillment f1 ON f0.Strings = f1.Id )
	BEGIN
		UPDATE f
		SET	 LastModifiedDateUTC = ISNULL(f0.strings, GETUTCDATE())
			,LastModifiedUTCOffset = DATEDIFF(minute, getutcdate(), getdate())
			,LastTransactionId = f0.Strings
			,OrderNumber = f0.Strings
			,QuantityBackordered = f0.Strings
			,QuantityCancelled = f0.Strings
			,QuantityConfirmed = f0.Strings
			,QuantityInvoiced = f0.Strings
			,QuantityOrdered = f0.Strings
			,QuantityShipped = f0.Strings
			,QuantitySlashed = f0.Strings
			,RequestedShipMethod = f0.Strings
			,SourceApplication = f0.Strings
			,VendorId = f0.Strings
		OUTPUT inserted.Id
			,inserted.OrderNumber
		INTO @mods(id, ordernumber)
		FROM CDF.Fulfillment f
			INNER JOIN @Fulfillment f0
				ON f.Id = f0.Strings
	END
	ELSE
	BEGIN
		INSERT INTO cdf.Fulfillment (LastTransactionId,VendorId,SourceApplication,OrderNumber,QuantityOrdered,QuantityConfirmed,QuantityBackordered,QuantityCancelled
									,QuantitySlashed,QuantityShipped,QuantityInvoiced,LastModifiedDateUTC,LastModifiedUTCOffset,RequestedShipMethod)
		OUTPUT inserted.id INTO @mods(id)
		SELECT f0.strings AS LastTransactionId
			,f0.strings AS VendorId
			,f0.strings AS SourceApplication
			,f0.strings AS OrderNumber
			,f0.strings AS QuantityOrdered
			,f0.strings AS QuantityConfirmed
			,f0.strings AS QuantityBackordered
			,f0.strings AS QuantityCancelled
			,f0.strings AS QuantitySlashed
			,f0.strings AS QuantityShipped
			,f0.strings AS QuantityInvoiced
			,f0.strings AS LastModifiedDateUTC
			,f0.strings AS LastModifiedUTCOffset
			,f0.strings AS RequestedShipMethod
		FROM @Fulfillment f0
	END

	SELECT	 id
			,ordernumber
	FROM @mods
END

GO

