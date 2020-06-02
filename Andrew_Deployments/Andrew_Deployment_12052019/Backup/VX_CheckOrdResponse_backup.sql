USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[VX_CheckOrdResponse]    Script Date: 12/5/2019 1:35:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
	=============================================
	Author:			Joey B.
	
	Create date:	11/7/2012
	Description:	Check for order response AND update requisitions
	=============================================
	Change History
	2012-11-07 JB		Procedure created
	2019-01-29 JB & ALB	Added altrun code for issues WHERE acknowlegements are not returned.  Allows manual run using
						po table instead of acknowledgement table.  VendorX could be upated to run using either the
						bt or edi parameter instead of the default blank (normal run) parameter
*/
CREATE  PROCEDURE [dbo].[VX_CheckOrdResponse] 
(
	@runAlt VARCHAR(3) = '' 
	-- runalt expected values are either bt = baker/taylor or edi ; uses a po table instead of an acknoweldgement table
)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--------------------------------------------------------------Process BakerTaylor updates-------------------------------------------------------
	
	-- Create AND fill temp table with pending response updates
	CREATE TABLE #response(rowid INT identity(1,1), poNo char(6))
	
	IF @runAlt = ''
		BEGIN
			INSERT INTO #response
				SELECT DISTINCT bh.OrderResponseNumber 
				FROM BakerTaylor.dbo.bulkorder_response_Header bh 
					INNER JOIN BakerTaylor.dbo.bulkorder_response_ItemDetail bd 
						ON bh.ResponseID = bd.ResponseID
					INNER JOIN dbo.VX_Submit_Audit_Log vx 
						ON bh.OrderResponseNumber = vx.PONumber
				WHERE vx.ProcessedFlag = 0
		END
	ELSE IF @runAlt='bt'
		BEGIN
			-- run alterative query because something is wrong
			INSERT INTO #response
				SELECT DISTINCT bh.OrderNumber
				FROM BakerTaylor.dbo.bulkorder_Header bh
					INNER JOIN BakerTaylor.dbo.bulkorder_ItemDetail bd
						ON bh.OrderID = bd.OrderID
					INNER JOIN VX_Submit_Audit_Log vx 
						ON bh.OrderNumber = vx.PONumber
				WHERE vx.ProcessedFlag = 0
		END

	-- Loop thru AND update each order with response
	DECLARE @loop INT
	SET @loop = (SELECT MAX(rowID) FROM #response)

	WHILE @loop > 0
	BEGIN 
		DECLARE @curPO CHAR(6)
		SELECT @curPO=poNo FROM #response WHERE rowid=@loop
	
		-- Update requisition header AND detail
		UPDATE rd
			SET rd.ConfirmedQty=ISNULL(id.QuantityShipping,0),
				rd.CanceledQty=CASE WHEN ISNULL(id.QuantityShipping,0)=0 AND ISNULL(id.QuantityBackordered,0)=0 THEN rd.RequestedQty ELSE CASE WHEN ISNULL(id.QuantityCanceled,0)=0 AND ISNULL(id.QuantityBackordered,0)=0 THEN rd.RequestedQty-ISNULL(id.QuantityShipping,0) ELSE ISNULL(id.QuantityCanceled,0) END END,
				rd.BackOrderQty=ISNULL(id.QuantityBackordered,0),
				rd.[Status] = CASE WHEN CAST(ISNULL(id.QuantityShipping,0)AS INT)=0 AND CAST(ISNULL(id.QuantityCanceled,0)AS INT)<>0 THEN 99
								WHEN CAST(ISNULL(id.QuantityShipping,0)AS INT)=0 AND CAST(ISNULL(id.QuantityBackordered,0)AS INT)=0 THEN 99
								WHEN CAST(ISNULL(id.QuantityBackordered,0)AS INT)<>0 THEN 98
								ELSE 40 END			
				,rd.ShipFrom=ISNULL(id.LocationShippingFrom,'')
				,rd.Comments=ISNULL(id.LineStatusDescription,'')
				,rd.ExtCost=ISNULL(id.QuantityShipping,0)*rd.Cost
		FROM VX_Requisition_Dtl rd 
			INNER JOIN BakerTaylor.dbo.bulkorder_response_Header hd 
				ON rd.PONumber=hd.OrderResponseNumber
			INNER JOIN BakerTaylor.dbo.bulkorder_response_ItemDetail id 
				ON hd.ResponseID=id.ResponseID 
					AND id.ProductIdentifier = rd.VendorItem
		WHERE rd.PONumber=@curPO 
			AND rd.RequestedQty <> 0
		
		-- new code for Ingram and other DX Vendors
		UPDATE rd
			SET rd.ConfirmedQty=ISNULL(ak.QuantityShipped,0),
				rd.CanceledQty=CASE WHEN ISNULL(ak.QuantityShipped,0)=0 AND ISNULL(ak.QuantityBackordered,0)=0 THEN rd.RequestedQty ELSE CASE WHEN ISNULL(ak.QuantityCancelled,0)=0 AND ISNULL(ak.QuantityBackordered,0)=0 THEN rd.RequestedQty-ISNULL(ak.QuantityShipped,0) ELSE ISNULL(ak.QuantityCancelled,0) END END,
				rd.BackOrderQty=ISNULL(ak.QuantityBackordered,0),
				rd.[Status] = CASE WHEN CAST(ISNULL(ak.QuantityShipped,0)AS INT)=0 AND CAST(ISNULL(ak.QuantityCancelled,0)AS INT)<>0 THEN 99
								WHEN CAST(ISNULL(ak.QuantityShipped,0)AS INT)=0 AND CAST(ISNULL(ak.QuantityBackordered,0)AS INT)=0 THEN 99
								WHEN CAST(ISNULL(ak.QuantityBackordered,0)AS INT)<>0 THEN 98
								ELSE 40 END			
				,rd.ShipFrom=''
				,rd.Comments=''
				,rd.ExtCost=ISNULL(ak.QuantityShipped,0)*rd.Cost
		FROM VX_Requisition_Dtl rd 
			INNER JOIN [HPB_EDI].[BLK].[vuAcknowledgements] AK
				ON rd.PONumber=ak.PONumber
					AND rd.VendorItem = ak.ItemIdentifier
					AND ak.QuantityCancelled > 0
			INNER JOIN [HPB_EDI].[BLK].[vuPurchaseOrders] PO
				ON ak.PONumber = po.PONumber
					AND ak.ItemIdentifier = po.ItemIdentifier
					AND Po.PONumber = @curPO -- this can be done to whole set by removing the @curpo restriction and remove from the loop
			INNER JOIN VX_Requisition_Hdr rh
				on rd.RequisitionNo = rh.RequisitionNo
			INNER JOIN HPB_EDI.EDI.ApplicationMaster am
				ON am.VendorId = rh.VendorID
					and am.POA_BULK like 'dx:'
		WHERE rd.RequestedQty <> 0

		-- Code for items to ignore backorders and use requested qty instead due to multiple shipments by vendor and inability of Store Recv'g to handle updates
		UPDATE rd
			SET rd.ConfirmedQty=rd.RequestedQty,
				rd.CanceledQty=0,
				rd.BackOrderQty=0,
				rd.[Status] = 40 
				,rd.ShipFrom=''
				,rd.Comments=''
				,rd.ExtCost=ISNULL(ak.QuantityShipped,0)*rd.Cost
		FROM VX_Requisition_Dtl rd 
			INNER JOIN [HPB_EDI].[BLK].[vuAcknowledgements] AK
				ON rd.PONumber=ak.PONumber
					AND rd.VendorItem = ak.ItemIdentifier
					AND ak.QuantityCancelled > 0
			INNER JOIN [HPB_EDI].[BLK].[vuPurchaseOrders] PO
				ON ak.PONumber = po.PONumber
					AND ak.ItemIdentifier = po.ItemIdentifier
					AND Po.PONumber = @curPO -- this can be done to whole set by removing the @curpo restriction and remove from the loop
			INNER JOIN VX_Requisition_Hdr rh
				on rd.RequisitionNo = rh.RequisitionNo
			INNER JOIN HPB_EDI.EDI.ApplicationMaster am
				ON am.VendorId = rh.VendorID
					and am.POA_BULK like 'hpbedi:%' -- need different flag for this
		WHERE rd.RequestedQty <> 0

		-- INSERT any backordered qty INTO backorderlog
		INSERT INTO VX_BackOrder_Log
			SELECT	 rh.VendorID
					,rh.LocationNo
					,rd.PONumber
					,rd.ItemCode
					,rd.BackOrderQty
					,GETDATE(),rd
					.Comments
			FROM VX_Requisition_Dtl rd 
				INNER JOIN VX_Requisition_Hdr rh 
					ON rd.PONumber=rh.PONumber
			WHERE rd.PONumber=@curPO 
				AND ISNULL(rd.BackOrderQty,0) <> 0
		
		-- Delete remaining items that were removed FROM the order
		delete FROM VX_Requisition_Dtl 
		WHERE PONumber=@curPO AND [Status] = 30 AND RequestedQty = 0
		
		-- Check - INSERT - update any kit items ON order
		if EXISTS(SELECT rd.ItemCode FROM VX_Requisition_Dtl rd INNER JOIN VX_Vendor_Kits vk ON rd.ItemCode=vk.ParentItem WHERE rd.PONumber=@curPO)
			 BEGIN
				-- Update any existing kit items ON orders
				UPDATE rd
					SET rd.RequestedQty=rd.RequestedQty+ISNULL((SELECT KitQty*RequestedQty FROM VX_Requisition_Dtl INNER JOIN VX_Vendor_Kits ON ItemCode=ParentItem WHERE RequisitionNo=rd.RequisitionNo AND ItemCode=vk.ParentItem AND KitItem=ISNULL(vk.KitItem,vk.ParentItem)),0),
						rd.ExtCost=rd.ExtCost+ISNULL((SELECT KitQty*RequestedQty FROM VX_Requisition_Dtl INNER JOIN VX_Vendor_Kits ON ItemCode=ParentItem WHERE RequisitionNo=rd.RequisitionNo AND ItemCode=vk.ParentItem AND KitItem=ISNULL(vk.KitItem,vk.ParentItem))*pm.Cost,0),
						rd.ConfirmedQty=rd.ConfirmedQty+ISNULL((SELECT KitQty*RequestedQty FROM VX_Requisition_Dtl INNER JOIN VX_Vendor_Kits ON ItemCode=ParentItem WHERE RequisitionNo=rd.RequisitionNo AND ItemCode=vk.ParentItem AND KitItem=ISNULL(vk.KitItem,vk.ParentItem)),0)
				FROM [HPB_Prime].[dbo].[ProductMaster] pm 
					INNER JOIN VX_Vendor_Kits vk 
						ON pm.ItemCode=vk.KitItem
					INNER JOIN VX_Requisition_Dtl rd 
						ON vk.KitItem=rd.ItemCode
				WHERE rd.PONumber=@curPO AND vk.KitItem in (SELECT ItemCode FROM VX_Requisition_Dtl WHERE RequisitionNo=rd.RequisitionNo)
		
				-- INSERT kit items
				INSERT INTO VX_Requisition_Dtl (requisitionno,LineNum,itemcode,vendoritem,requestedqty,suggestedqty,confirmedqty,canceledqty,backorderqty,requestedby,requesteddate,cost,extcost,[status],PONumber,allowbackorder,ShipFrom,Comments)
					SELECT DISTINCT	 rd.RequisitionNo
									,RIGHT(vk.KitItem,4)
									,vk.KitItem
									,pm.ISBN
									,vk.KitQty
									,0
									,vk.KitQty*rd.RequestedQty
									,0
									,0
									,rd
									.RequestedBy
									,GETDATE()
									,pm.Cost
									,pm.Cost*(vk.KitQty*rd.RequestedQty)
									,rd.[Status]
									,rd.PONumber
									,0
									,'VEND'
									,'AddKitItem'
					FROM [HPB_Prime].[dbo].[ProductMaster] pm 
						INNER JOIN VX_Vendor_Kits vk 
							ON pm.ItemCode=vk.KitItem
						INNER JOIN VX_Requisition_Dtl rd 
							ON vk.ParentItem=rd.ItemCode
					WHERE rd.PONumber=@curPO 
						AND rd.ItemCode NOT IN (SELECT distinct KitItem FROM VX_Vendor_Kits WHERE parentitem=rd.itemcode) 
						AND vk.KitItem NOT IN (SELECT ItemCode FROM VX_Requisition_Dtl WHERE RequisitionNo=rd.RequisitionNo)
					GROUP BY rd.RequisitionNo,rd.LineNum,vk.KitItem,pm.ISBN,vk.KitQty,rd.RequestedBy,vk.KitQty*rd.RequestedQty,pm.Cost,pm.Cost*(vk.KitQty*rd.RequestedQty)
							,rd.[Status],rd.PONumber,RIGHT(rd.itemcode,4)
			
				-- Update parent item
				UPDATE rd
					SET rd.CanceledQty=rd.RequestedQty,rd.ConfirmedQty=0,rd.[Status]=99,rd.Comments='KitUpdate'
				FROM VX_Requisition_Dtl rd 
					INNER JOIN VX_Vendor_Kits vk 
						ON rd.ItemCode=vk.ParentItem
				WHERE rd.PONumber=@curPO 
			 END
		
		UPDATE rh
			SET rh.[Status]=40, 
				rh.ReqQty=(SELECT SUM(ISNULL(ConfirmedQty,0)) FROM VX_Requisition_Dtl WHERE PONumber = @curPO),
				rh.ReqAmt=(SELECT SUM(ISNULL(ExtCost,0)) FROM VX_Requisition_Dtl WHERE PONumber = @curPO)
		FROM VX_Requisition_Hdr rh 
			INNER JOIN BakerTaylor.dbo.bulkorder_response_Header hd 
				ON rh.PONumber=hd.OrderResponseNumber
			INNER JOIN BakerTaylor.dbo.bulkorder_response_ItemDetail id 
				ON hd.ResponseID=id.ResponseID
		WHERE rh.PONumber=@curPO
			
		-- Update reorder control table AND audit log
		UPDATE VX_Reorder_Control
			SET [Status]=40
		WHERE PONumber=@curPO
		
		UPDATE VX_Submit_Audit_Log
			SET ProcessedFlag=1,ResponseDate=GETDATE()
		WHERE PONumber=@curPO
		
		SET @loop = @loop - 1
	END
	
	----------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------Process EDI updates-------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------
	
	-- Create AND fill temp table with pending response updates
	CREATE TABLE #EDIresponse(rowid INT identity(1,1), poNo char(6))
	
	IF @runAlt=''
		BEGIN	
			INSERT INTO #EDIresponse (poNo)
				SELECT DISTINCT ah.PONumber 
				FROM [HPB_EDI].[blk].[AcknowledgeHeader] ah 
					INNER JOIN dbo.VX_Submit_Audit_Log vx 
						ON ah.PONumber=vx.PONumber
				WHERE vx.ProcessedFlag = 0
		END
	ELSE if @runAlt='edi'
		BEGIN
			INSERT INTO #EDIresponse (poNo)
				SELECT h.PONumber
				FROM [HPB_EDI].[BLK].[PurchaseOrderHeader] h
					INNER JOIN dbo.VX_Submit_Audit_Log vx 
						ON h.PONumber=vx.PONumber
				WHERE vx.ProcessedFlag = 0
				GROUP BY h.PONumber
		END

	-- Loop thru AND update each order with response
	DECLARE	 @EDIloop INT
	DECLARE @INSERT TABLE ( ackid INT, po INT)

	SET @EDIloop = (SELECT MAX(rowID) FROM #EDIresponse)

	WHILE @EDIloop > 0
	BEGIN 
		DECLARE @EDIcurPO CHAR(6)
		
		SELECT @EDIcurPO=poNo 
		FROM #EDIresponse 
		WHERE rowid=@EDIloop
	
		SELECT @EDIcurPO
		
		-- Update requisition header AND detail. Dummied this up to match what wAS ordered per KBeverly

		IF @runAlt='edi'
			BEGIN

				-- INSERT values INTO 855 table AND 855 manual add table
				INSERT INTO [HPB_EDI].[blk].[AcknowledgeHeader] (	 [PONumber], [IssueDate], [VendorID], [ReferenceNo], [ShipToLoc], [ShipToSAN], [BillToLoc]
															,[BillToSAN], [ShipFromLoc], [ShipFromSAN], [TotalLines], [TotalQuantity], [CurrencyCode]
															,[InsertDateTime], [Processed], [ProcessedDateTime], [ResponseACKSent], [ResponseAckNo],[GSNo])
				OUTPUT INSERTED.AckID, INSERTED.PONumber INTO @INSERT (ackid, po)
					SELECT	 h.PONumber, h.IssueDate, h.VendorID, 'Manual' AS ReferenceNo, h.ShipToLoc, h.ShipToSAN, h.BillToLoc
							,h.BillToSAN, h.ShipFromLoc, h.ShipFromSAN, h.TotalLines, h.TotalQuantity, null AS CurrencyCode
							,GETDATE() AS insertdatetime, 1 AS Processed, GETDATE() AS ProcessedDateTime, 1 AS ResponseAckSent, '0000' AS responseackno,'0000' AS gsno
					FROM [HPB_EDI].[BLK].[PurchaseOrderHeader] h
						INNER JOIN #EDIresponse r
							ON h.PONumber = r.poNo
					WHERE  r.poNo=@EDIcurPO

				INSERT INTO [HPB_EDI].[dbo].[855_Ack_ManualAdd] (AckId, PONumber, Descript)
					SELECT i.ackid, i.po, 'Ack not received FROM vendor-cxreating manual record'
					FROM @INSERT i				

				INSERT INTO [HPB_EDI].[BLK].[AcknowledgeDetail] ([AckID], [LineNo], [LineStatusCode], [ItemStatusCode], [UnitOfMeasure], [QuantityOrdered], [QuantityShipped]
														,[QuantityCancelled], [QuantityBackordered], [UnitPrice], [PriceCode], [CurrencyCode], [ItemIDCode]
														,[ItemIdentifier], [ItemDesc])
					SELECT i.ackid, d.[LineNo], '' AS LineStatusCode , '' AS ItemStatusCode, d.UnitOfMeasure, d.Quantity, d.Quantity AS ShipQty
							,0 AS CancelQty, 0 AS BackOrdQty,d.UnitPrice, d.PriceCode,   null AS CurrencyCode, d.ItemIDcode
							,d.ItemIdentifier, NULL AS itemdesc
					FROM [HPB_EDI].[BLK].[PurchaseOrderHeader] h
						INNER JOIN @INSERT i
							ON i.po = h.PONumber
						INNER JOIN [HPB_EDI].[BLK].[PurchaseOrderDetail] d
							ON h.OrderId = d.OrderId
					WHERE h.PONumber = @EDIcurPO			

					delete FROM @INSERT WHERE po = @EDIcurPO
			END

		-- 2019-09-23: Added the update poa query to update quanitty ordereed and quanity cancelled
		UPDATE poa
			SET	 QuantityOrdered = po.Quantity
				,QuantityCancelled = po.Quantity- poa.QuantityShipped
		FROM HPB_EDI.BLK.vuPurchaseOrders po
			INNER JOIN HPB_EDI.BLK.vuAcknowledgements poa
				ON po.PONumber = poa.PONumber
					AND po.ItemIdentifier = poa.ItemIdentifier
		WHERE po.PONumber=@EDIcurPO 

		UPDATE rd
			SET  ConfirmedQty=ad.QuantityShipped
				,CanceledQty = case when ad.QuantityCancelled > 0 
									then ad.QuantityOrdered - ad.QuantityShipped
									else 0
							   end
				,BackOrderQty= ISNULL(ad.QuantityBackordered,0)
				,[Status] = CASE WHEN CAST(ISNULL(ad.QuantityShipped,0)AS INT)=0 AND CAST(ISNULL(ad.QuantityCancelled,0)AS INT)<>0 THEN 99
									WHEN CAST(ISNULL(ad.QuantityShipped,0)AS INT)=0 AND CAST(ISNULL(ad.QuantityBackordered,0)AS INT)=0 THEN 99
									WHEN CAST(ISNULL(ad.QuantityBackordered,0)AS INT)<>0 THEN 98
									ELSE 40 
							    END			
				,ShipFrom=ISNULL(ah.ShipFromLoc,'')
				,Comments=LEFT(ISNULL(ad.LineStatusCode+'/'+ad.ItemStatusCode,'') + '/' + ad.VendorStatus,100)
				,ExtCost=CASE WHEN ISNULL(ad.QuantityShipped,0)=0 
								 THEN rd.RequestedQty 
								 ELSE ISNULL(ad.QuantityShipped,0) 
							 END * rd.Cost
		FROM VX_Requisition_Dtl rd 
			INNER JOIN [HPB_EDI].[blk].[AcknowledgeHeader] ah
				ON ah.PONumber=rd.PONumber
			INNER JOIN [HPB_EDI].[BLK].[AcknowledgeDetail] ad 
				ON ah.AckID=ad.AckID 
					AND rd.VendorItem=CASE WHEN ad.ItemIDCode='EN' 
											THEN LEFT(ad.ItemIdentifier,13) 
											ELSE ad.ItemIdentifier 
									   END
		WHERE rd.PONumber=@EDIcurPO 
			AND rd.RequestedQty <> 0

		-- 2019-09-23: Added this code to remove zero quantity detail items that are never sent to the vendor and no ack file is ever received
		UPDATE rd
			SET  ConfirmedQty=0
				,CanceledQty = rd.RequestedQty
				,BackOrderQty= 0
				,[Status] = 99
				,ShipFrom=''
				,Comments='Order never sent to vendor, quanity of ' + cast(rd.RequestedQty as varchar(10))
				,ExtCost= 0.00
		FROM HPB_Logistics.dbo.VX_Requisition_Hdr rh
			inner join HPB_Logistics.dbo.VX_Requisition_Dtl rd
				on rh.RequisitionNo = rd.RequisitionNo
			left join hpb_edi.blk.vuPurchaseOrders po
				on rh.PONumber = po.PONumber
					and rd.VendorItem = po.ItemIdentifier
			left join hpb_edi.blk.vuAcknowledgements poa
				on rh.PONumber = poa.PONumber 
					and rd.VendorItem = poa.ItemIdentifier
		WHERE rd.PONumber=@EDIcurPO 
			AND po.PONumber is null and poa.PONumber is null
				and rh.status < 60
					
		-- Check - INSERT - update any kit items ON order
		if EXISTS(SELECT rd.ItemCode FROM VX_Requisition_Dtl rd INNER JOIN VX_Vendor_Kits vk ON rd.ItemCode=vk.ParentItem WHERE rd.PONumber=@EDIcurPO)
			 BEGIN
				-- Update any existing kit items ON orders
				UPDATE rd
					SET	 rd.RequestedQty=rd.RequestedQty+ISNULL((SELECT KitQty*RequestedQty FROM VX_Requisition_Dtl INNER JOIN VX_Vendor_Kits ON ItemCode=ParentItem WHERE RequisitionNo=rd.RequisitionNo AND kititem=rd.itemcode),0)
						,rd.ExtCost=rd.ExtCost+ISNULL((SELECT KitQty*RequestedQty FROM VX_Requisition_Dtl INNER JOIN VX_Vendor_Kits ON ItemCode=ParentItem WHERE RequisitionNo=rd.RequisitionNo AND kititem=rd.itemcode)*pm.Cost,0)
						,rd.ConfirmedQty=rd.ConfirmedQty+ISNULL((SELECT KitQty*RequestedQty FROM VX_Requisition_Dtl INNER JOIN VX_Vendor_Kits ON ItemCode=ParentItem WHERE RequisitionNo=rd.RequisitionNo AND kititem=rd.itemcode),0)
				FROM [HPB_Prime].[dbo].[ProductMaster] pm 
					INNER JOIN VX_Vendor_Kits vk 
						ON pm.ItemCode=vk.KitItem
					INNER JOIN VX_Requisition_Dtl rd 
						ON vk.KitItem=rd.ItemCode
				WHERE rd.PONumber=@EDIcurPO AND vk.KitItem in (SELECT ItemCode FROM VX_Requisition_Dtl WHERE RequisitionNo=rd.RequisitionNo)
		
				-- Insert kit items
				INSERT INTO VX_Requisition_Dtl (requisitionno,LineNum,itemcode,vendoritem,requestedqty,suggestedqty,confirmedqty,canceledqty,backorderqty,requestedby,requesteddate,cost,extcost,[Status],PONumber,allowbackorder,ShipFrom,Comments)
					SELECT DISTINCT 
						 rd.RequisitionNo
						,RIGHT(vk.KitItem,4)
						,vk.KitItem
						,pm.ISBN
						,vk.KitQty
						,0
						,vk.KitQty*rd.RequestedQty
						,0
						,0
						,rd.RequestedBy
						,GETDATE()
						,pm.Cost
						,pm.Cost*(vk.KitQty*rd.RequestedQty)
						,rd.[Status]
						,rd.PONumber
						,0,
						'VEND'
						,'AddKitItem'
					FROM [HPB_Prime].[dbo].[ProductMaster] pm 
						INNER JOIN VX_Vendor_Kits vk 
							ON pm.ItemCode=vk.KitItem
						INNER JOIN VX_Requisition_Dtl rd 
							ON vk.ParentItem=rd.ItemCode
					WHERE rd.PONumber=@EDIcurPO 
						AND rd.ItemCode NOT IN (SELECT distinct KitItem FROM VX_Vendor_Kits WHERE parentitem=rd.itemcode) 
						AND vk.KitItem NOT IN (SELECT ItemCode FROM VX_Requisition_Dtl WHERE RequisitionNo=rd.RequisitionNo)
					GROUP BY rd.RequisitionNo,rd.LineNum,vk.KitItem,pm.ISBN,vk.KitQty,rd.RequestedBy,vk.KitQty*rd.RequestedQty,pm.Cost,pm.Cost*(vk.KitQty*rd.RequestedQty),rd.[Status]
							,rd.PONumber,right(rd.itemcode,4)
			
				-- Update parent item
				UPDATE rd
					SET	 rd.CanceledQty=rd.RequestedQty
						,rd.ConfirmedQty=0
						,rd.[Status]=99
						,rd.Comments='KitUpdate'
				FROM VX_Requisition_Dtl rd 
					INNER JOIN VX_Vendor_Kits vk 
						ON rd.ItemCode=vk.ParentItem
				WHERE rd.PONumber=@EDIcurPO 
			 END
		
		UPDATE rh
			SET rh.[Status]=40,
				rh.ReqQty=(SELECT SUM(ISNULL(ConfirmedQty,0)) FROM VX_Requisition_Dtl WHERE PONumber = @EDIcurPO),
				rh.ReqAmt=(SELECT SUM(ISNULL(ExtCost,0)) FROM VX_Requisition_Dtl WHERE PONumber = @EDIcurPO)
		FROM VX_Requisition_Hdr rh 
			INNER JOIN [HPB_EDI].[blk].[AcknowledgeHeader] ah
				ON ah.PONumber=rh.PONumber
			INNER JOIN [HPB_EDI].[BLK].[AcknowledgeDetail] ad
				ON ad.AckID=ah.AckID
		WHERE rh.PONumber=@EDIcurPO
		
		-- Update reorder control table AND audit log
		UPDATE VX_Reorder_Control
			SET [Status]=40
		WHERE PONumber=@EDIcurPO
		
		UPDATE VX_Submit_Audit_Log
			SET	 ProcessedFlag=1
				,ResponseDate=GETDATE()
		WHERE PONumber=@EDIcurPO
		
		UPDATE [HPB_EDI].[blk].[AcknowledgeHeader]
			SET	 Processed=1
				,ProcessedDateTime=GETDATE()
		WHERE PONumber=@EDIcurPO
		
		SET @EDIloop = @EDIloop - 1
	END
	
		----------------------------------------------------------------------------------------------------------------------------------------
		-- Check AND delete any backorders older than 2 weeks or shipped backorders
		UPDATE bl
			SET bl.VendorID = 'Delete'
		FROM VX_BackOrder_Log bl 
			INNER JOIN VX_Requisition_Dtl rd 
				ON bl.ponumber=rd.PONumber 
					AND bl.itemcode=rd.ItemCode
		WHERE CAST(CONVERT(VARCHAR(10),backorderdate,112)AS DATETIME) < DATEADD(dd,-1,CAST(CONVERT(VARCHAR(10),GETDATE(),112)AS DATETIME))
		 AND (rd.VendorItem IN (SELECT ProductIdentifier FROM BakerTaylor.dbo.bulkorder_shipnotice_ItemDetail WHERE BuyersOrderReference=bl.ponumber AND ProductIdentifier=rd.VendorItem AND ShippedQuantity=bl.backorderqty)
			OR CAST(CONVERT(VARCHAR(10),bl.backorderdate,112)AS DATETIME) < DATEADD(week,-2,CAST(CONVERT(VARCHAR(10),GETDATE(),112)AS DATETIME)))

		DELETE FROM VX_BackOrder_Log WHERE VendorID = 'Delete'
END

GO

