USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [dbo].[RPT_Get_InvoiceDtls]    Script Date: 10/1/2019 9:01:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Joey B.
-- Create date: 4/8/14
-- Description:	Get EDI invoices details for reporting
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Get_InvoiceDtls] 
	@ParamString VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM interfering WITH SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	/*
		TESTING:
			declare @ParamString VARCHAR(50)
			set @ParamString = '215993 | 0952543566'
	*/

	declare	 @PONo VARCHAR(8)
			,@InvoiceNo VARCHAR(12)
			,@z10 VARCHAR(10) = '0'

	SELECT	 @PONo = LTRIM(RTRIM(LEFT(@ParamString,CHARINDEX('|',@ParamString,0)-1)))
			,@InvoiceNo = LTRIM(RTRIM(RIGHT(@ParamString,LEN(@ParamString)-CHARINDEX('|',@ParamString,0))))

	/*
		SELECT h.InvoiceNo,CONVERT(VARCHAR(12), CAST(h.IssueDate AS DATETIME), 107)[IssueDateTime],h.ReferenceNo,h.ShipToSAN,h.TotalPayable,ISNULL('000000000000','Not Rcvd')[SR_ShipmentNo],
			h.PONumber,h.ShipToLoc,ISNULL('00000000000000000000','NA')[ItemCode],ISNULL('','')[ItemDescription],d.ItemIdentifier,d.InvoiceQty,ISNULL(2,0)[ReceivedQuantity],
			CAST(ISNULL(d.UnitPrice,rd.Cost)AS MONEY)[UnitPrice],d.DiscountCode,d.DiscountPct,CAST(ISNULL(d.UnitPrice,rd.Cost) AS MONEY)*CAST(ISNULL(d.InvoiceQty,0) AS INT) [ExtendedPrice],l.Name,l.MailToAddress1,l.MailToAddress2,l.MailToAddress3
			,'000000000000'+' | %' [ParamPO],'000000000000'+' | '+'00000000000000000000' [ParamItem],ISNULL((SELECT SUM(chargeamt) FROM  dbo.[810_Inv_Charges] WHERE h.PONumber=PONumber AND h.InvoiceNo=InvoiceNo),0)[AddCharges]
		FROM dbo.[810_Inv_Hdr] h WITH(NOLOCK) INNER JOIN dbo.[810_Inv_Dtl] d WITH(NOLOCK) ON h.InvoiceID=d.InvoiceID
			INNER JOIN dbo.HPB_SAN_Codes st WITH(NOLOCK) ON st.SANCode=h.ShipToSAN
			INNER JOIN [$(HPB_Prime)].[dbo].[Locations] l WITH(NOLOCK) ON l.LocationNo=st.LocationNo
			--LEFT OUTER JOIN [$(HPB_Prime)].[dbo].[ProductMaster] pm WITH(NOLOCK) ON pm.ItemCode=sr.ItemCode
			LEFT OUTER JOIN Logistics_VXRequisitionDtl rd WITH(NOLOCK) ON rd.PONumber=h.PONumber AND rd.VendorItem=d.ItemIdentifier
			--LEFT OUTER JOIN [$(HPB_Prime)].[dbo].[ProductMaster] pm2 WITH(NOLOCK) ON pm2.ItemCode=rd.ItemCode
		WHERE h.InvoiceNo = @InvoiceNo
		ORDER BY d.[LineNo]
	 */ 	 

	-- Get received items for PO
	SELECT srh.ShipmentNo,srh.LocationNo,srd.ItemCode,srd.Qty,pm.ISBN 
	INTO #sr
	FROM StoreReceiving.dbo.SR_Header srh 
		INNER JOIN StoreReceiving.dbo.SR_Detail srd 
			ON srh.BatchID=srd.BatchID
		INNER JOIN [HPB_Prime].[dbo].[ProductMaster] pm 
			ON srd.ItemCode=pm.ItemCode
	WHERE srh.ShipmentNo=RIGHT(@z10+@PONo,10)
	ORDER BY srh.ShipmentNo,srh.LocationNo,srd.ItemCode

	-- Get the EDI invoice
	SELECT	 h.InvoiceNo
			,CONVERT(VARCHAR(12)
			,CAST(h.IssueDate AS DATETIME), 107) AS [IssueDateTime]
			,h.ReferenceNo
			,h.ShipToSAN
			,h.TotalPayable
			,ISNULL(sr.ShipmentNo,'Not Rcvd') AS [SR_ShipmentNo]
			,h.PONumber
			,h.ShipToLoc
			,ISNULL(sr.ItemCode,'NA') AS [ItemCode]
			,COALESCE(pm2.Title,pm.Title) AS [ItemDescription]
			,d.ItemIdentifier
			,d.InvoiceQty
			,ISNULL(sr.Qty,0) AS [ReceivedQuantity]
			,CAST(COALESCE(d.UnitPrice,rd.Cost) AS MONEY) AS [UnitPrice]
			,d.DiscountCode
			,d.DiscountPct
			,CAST(COALESCE(d.UnitPrice,rd.Cost) AS MONEY)*CAST(COALESCE(d.InvoiceQty,0) AS INT) AS [ExtendedPrice]
			,l.[Name]
			,l.MailToAddress1
			,l.MailToAddress2
			,l.MailToAddress3
	INTO #edi
	FROM dbo.[810_Inv_Hdr] h
		INNER JOIN dbo.[810_Inv_Dtl] d 
			ON h.InvoiceID=d.InvoiceID
		INNER JOIN dbo.HPB_SAN_Codes st 
			ON st.SANCode=h.ShipToSAN
		INNER JOIN [HPB_Prime].[dbo].[Locations] l 
			ON l.LocationNo=st.LocationNo
		LEFT OUTER JOIN #sr sr 
			ON sr.ShipmentNo=RIGHT(@z10+h.PONumber,10) 
				AND sr.LocationNo=st.LocationNo 
				AND sr.ISBN=d.ItemIdentifier 
		LEFT OUTER JOIN [HPB_Prime].[dbo].[ProductMaster] pm 
			ON pm.ItemCode=sr.ItemCode
		LEFT OUTER JOIN HPB_Logistics.dbo.VX_Requisition_Dtl rd 
			ON rd.PONumber=h.PONumber 
				AND rd.VendorItem=d.ItemIdentifier
		LEFT OUTER JOIN [HPB_Prime].[dbo].[ProductMaster] pm2 
			ON pm2.ItemCode=rd.ItemCode
	WHERE h.InvoiceNo = @InvoiceNo 
		AND h.PONumber=@PONo
	ORDER BY d.[LineNo]

	----added this section to include any items received that were not part of the actual ORDER.  
	INSERT INTO #edi
		SELECT	 h.InvoiceNo
				,CONVERT(VARCHAR(12)
				,CAST(h.IssueDate AS DATETIME), 107) AS [IssueDateTime]
				,h.ReferenceNo
				,h.ShipToSAN
				,h.TotalPayable
				,ISNULL(sr.ShipmentNo,'Not Rcvd') AS [SR_ShipmentNo]
				,h.PONumber
				,h.ShipToLoc
				,ISNULL(sr.ItemCode,'NA') AS [ItemCode]
				,COALESCE(pm2.Title,pm1.Title) AS [ItemDescription]
				,ISNULL(sr.isbn,d.ItemIdentifier)
				,d.InvoiceQty
				,ISNULL(sr.Qty,0) AS [ReceivedQuantity]
				,CAST(COALESCE(d.UnitPrice,rd.Cost) AS MONEY) AS [UnitPrice]
				,d.DiscountCode
				,d.DiscountPct
				,CAST(COALESCE(d.UnitPrice,rd.Cost) AS MONEY)*CAST(COALESCE(d.InvoiceQty,0) AS INT) AS [ExtendedPrice]
				,l.[Name]
				,l.MailToAddress1
				,l.MailToAddress2
				,l.MailToAddress3
		FROM dbo.[810_Inv_Hdr] h 
			INNER JOIN dbo.[810_Inv_Dtl] d 
				ON h.InvoiceID=d.InvoiceID
			INNER JOIN dbo.HPB_SAN_Codes st 
				ON st.SANCode=h.ShipToSAN
			INNER JOIN [HPB_Prime].[dbo].[Locations] l 
				ON l.LocationNo=st.LocationNo
			LEFT OUTER JOIN HPB_Logistics.dbo.VX_Requisition_Dtl rd 
				ON rd.PONumber=h.PONumber AND rd.VendorItem=d.ItemIdentifier
			LEFT OUTER JOIN HPB_Logistics.dbo.VX_Vendor_Kits vk 
				ON vk.ParentItem = rd.ItemCode
			LEFT OUTER JOIN #sr sr 
				ON sr.ShipmentNo=RIGHT(REPLICATE('0',10)+h.PONumber,10) 
					AND sr.LocationNo=st.LocationNo 
					AND sr.ItemCode=ISNULL(vk.KitItem,rd.ItemCode)
			LEFT OUTER JOIN [HPB_Prime].[dbo].[ProductMaster] pm1 
				ON pm1.ItemCode=sr.ItemCode
			LEFT OUTER JOIN [HPB_Prime].[dbo].[ProductMaster] pm2 
				ON pm2.ItemCode=rd.ItemCode
		WHERE h.InvoiceNo = @InvoiceNo 
			AND h.PONumber=@PONo 
			AND sr.ItemCode NOT IN (SELECT ItemCode FROM #edi WHERE SR_ShipmentNo=sr.ShipmentNo GROUP BY ItemCode)
		ORDER BY d.[LineNo]
	
	-- Get any duplicate items FROM backorders
	CREATE TABLE #ediItems(ID INT IDENTITY(1,1),POnumber VARCHAR(10),Item VARCHAR(20),Qty BIGINT)
	--
	INSERT INTO #ediItems
		SELECT b.PONumber,b.ItemCode,b.InvoiceQty
		FROM #edi b
		WHERE b.sr_shipmentno<>'Not Rcvd' 
			AND b.PONumber<>@PONo 
			AND b.ItemCode=(SELECT itemcode FROM #edi WHERE PONumber=@PONo AND ItemCode=b.ItemCode)
		GROUP BY b.PONumber,b.itemcode,b.InvoiceQty
		ORDER BY b.itemcode,b.PONumber desc

	-- Loop thru back-ordered items AND sync received quantities
	DECLARE	 @loop INT
			,@lastQty BIGINT
			,@lastItem VARCHAR(20)

	SELECT	 @loop = (SELECT MAX(ID) FROM #ediItems)
			,@lastQty = 0

	WHILE ISNULL(@loop,0) > 0
		BEGIN
			DECLARE	 @curPO VARCHAR(10)
					,@itemcode VARCHAR(20)
					,@invQty BIGINT
					,@rctQty BIGINT
			
			SELECT	 @curPO=POnumber
					,@itemcode=Item
					,@invQty=Qty 
			FROM #ediItems 
			WHERE ID=@loop
			
			SELECT @rctQty=Qty 
			FROM #sr 
			WHERE itemcode=@itemcode
			
			IF @lastItem<>@itemcode BEGIN SET @lastQty=0 end
			IF @rctQty-@lastQty>@invQty
				BEGIN
					UPDATE #edi 
						SET ReceivedQuantity = @invQty
					WHERE PONumber=@curPO 
						AND ItemCode=@itemcode
					
					UPDATE #edi 
						SET ReceivedQuantity = ReceivedQuantity-@invQty
					WHERE PONumber=@PONo 
						AND ItemCode=@itemcode 
				END
			IF @rctQty-@lastQty<=@invQty
				BEGIN
					UPDATE #edi 
						SET receivedquantity = CASE WHEN @rctQty-@lastQty < 0 THEN 0 ELSE @rctQty-@lastQty END
					WHERE PONumber=@curPO AND itemcode=@itemcode					
					UPDATE #edi 
					SET receivedquantity = 0
					WHERE PONumber=@PONo 
						AND itemcode=@itemcode 
				END			
			SET @lastQty=@invQty
			SET @loop = @loop - 1
		END

	SELECT DISTINCT b.InvoiceNo,CONVERT(VARCHAR(12),CAST(b.IssueDateTime AS DATETIME),107) AS [IssueDateTime],b.ReferenceNo,b.ShipToSAN
			,CAST(b.TotalPayable AS DECIMAL(12,4)) AS [TotalPayable],b.sr_ShipmentNo AS [SR_ShipmentNo],b.PONumber,b.ShipToLoc
			,ISNULL(RIGHT(b.ItemCode,8),'NA') AS [ItemCode],b.ItemDescription,b.ItemIdentifier,b.InvoiceQty
			,ISNULL(b.ReceivedQuantity,0) AS [ReceivedQuantity],CAST(b.UnitPrice AS decimal(12,2))[UnitPrice]
			,CAST(b.DiscountPct AS DECIMAL(12,2)) AS [DiscountPercentage],CAST(b.ExtendedPrice AS DECIMAL(12,2)) AS [ExtendedPrice]
			,b.[Name],b.MailToAddress1,b.MailToAddress2,b.MailToAddress3,b.sr_ShipmentNo+' | %' [ParamPO],b.sr_ShipmentNo+' | '+b.ItemCode AS [ParamItem]
			,ISNULL((SELECT SUM(chargeamt) FROM dbo.[810_Inv_Charges] WHERE b.PONumber=PONumber AND b.InvoiceNo=InvoiceNo),0)[AddCharges]
	FROM #edi b 
	ORDER BY b.itemdescription,b.PONumber

	DROP TABLE #sr
	DROP TABLE #edi
	DROP TABLE #ediItems
END

GO

