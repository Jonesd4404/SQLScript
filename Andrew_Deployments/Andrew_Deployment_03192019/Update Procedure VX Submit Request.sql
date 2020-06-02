/*
	=============================================
	Author:			Joey B.
	Create date:	10/24/2012
	Modified:
					03/18/2019 ALB - Added IF statement for inhouse to check baker taylor 

	Description:	Submit Requisitions
	=============================================
*/
ALTER PROCEDURE [dbo].[VX_SubmitReqs] 
	 @user VARCHAR(20)
	,@inHouseOnly BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/* 
	--testing.........
		declare @user varchar(20),@inHouseOnly bit
		set @user = 'jblalock'
		set @inHouseOnly = 0
	--endtesting........
	*/

	DECLARE @rVal INT = 0
	DECLARE @err INT = 0

	BEGIN TRANSACTION VX_ReqSubmit

	----get reqs for Submission....
	CREATE TABLE #reqTmp 
	(	
		 rowid	INT IDENTITY(1,1)
		,reqNo	CHAR(6)
		,poNo	CHAR(6)
		,vendID VARCHAR(20)
	)

	INSERT INTO #reqTmp ( reqNo, poNo, vendID )
		SELECT DISTINCT RequisitionNo, PONumber, VendorID
		FROM VX_Reorder_Control src 
			INNER JOIN VX_Locations l 
				ON src.StoreNo = l.LocationNo
		WHERE LockedBy = @user 
			AND Locked = 'Y' 
			AND RequisitionNo IS NOT NULL 
			AND PONumber IS NOT NULL 
			AND [Status] = 20 
			AND Active = 'Y'
			AND EXISTS(	SELECT ItemCode FROM VX_Requisition_Dtl WHERE RequisitionNo = src.RequisitionNo AND RequestedQty > 0)

	----loop thru and update each req independently to ensure gaps in datetime stamps......
	DECLARE @loop INT
	SET @loop = (SELECT MAX(rowID) FROM #reqTmp)

	WHILE @loop > 0
	BEGIN 
		DECLARE @curDT DATETIME
		SET @curDT = GETDATE()
		DECLARE @curReq char(6)
		DECLARE @curPO char(6)
		DECLARE @curVend varchar(20)
		
		SELECT	@curReq = reqNo
				,@curPO = poNo
				,@curVend = vendID 
		FROM #reqTmp 
		WHERE rowid = @loop

		DECLARE @OrdRefId INT
		SET @OrdRefId = 0

		------ensure inhouse orders don't go through EDI even if flag doesn't get set correctly coming in.....
		-- 2019-03-18 ALB: Added if statement to exclude items not in hpb_edi log. use supplied value
		IF EXISTS(SELECT 1 FROM HPB_EDI.dbo.Vendor_SAN_Codes WHERE vendorid=@curVend)
			SET @inHouseOnly = CASE WHEN (SELECT InHouseOnly FROM HPB_EDI..Vendor_SAN_Codes WHERE vendorid=@curVend)=0 THEN @inHouseOnly ELSE 1 END
	
	----only run this section if orders will be sent EDI......
		IF @inHouseOnly=0
		BEGIN
			IF (@curVend) = 'IDB&TDISTR'  ----BakerTaylor only.....
			BEGIN 		
				----insert orders into BT bulk tables.....----------------------------------------------
				INSERT INTO BakerTaylor..bulkorder_Header (  OrderNumber,IssueDateTime,PurposeCode,FillTermsCode,BuyerPartyIDType,BuyerPartyIdentifier,SellerPartyIDType
															,SellerPartyIdentifier,ShipToPartyIDType,ShipToPartyIdentifier)
					SELECT	 rh.PONumber
							,CONVERT(VARCHAR(10),GETDATE(),112)
							,'Original'
							,''/*'FillPartKillRemainder'*/
							,'SAN'
							,cs.SAN
							,'SAN'
							,'1556150'
							,'SAN'
							,cs.SAN + ' ' + cs.Suffix
					FROM VX_Requisition_Hdr rh 
						INNER JOIN VX_Reorder_Control rc 
							ON rh.RequisitionNo = rc.RequisitionNo
						INNER JOIN BakerTaylor..codes_SAN cs 
							ON rc.StoreNo = cs.LocationNo 
								AND rc.Warehouse = cs.Warehouse
					WHERE rh.RequisitionNo = @curReq 
				IF @@ERROR != 0 SET @err = @@ERROR
			
				----get and set OrdRefId from insert.....
				SET @OrdRefId = @@identity

				IF @@ERROR = 0  AND ISNULL(@OrdRefId,0) <> 0 AND EXISTS (SELECT OrderNumber FROM BakerTaylor..bulkorder_Header WHERE LTRIM(RTRIM(OrderNumber))=@curPO)
				BEGIN 
					INSERT INTO BakerTaylor..bulkorder_ItemDetail (	 OrderID,LineNumber,ProductIDType,ProductIdentifier,OrderQuantity,LineReferenceTypeCode
																	,LineReferenceNumber,ItemFillTermsCode)
						SELECT	 @OrdRefId
								,rd.LineNum
								,'EAN13'
								,RIGHT('0000000000000'+rd.VendorItem,13)
								,rd.RequestedQty
								/*,right(rd.ItemCode,10)*/
								,'BuyersOrderLineReference'
								,rd.LineNum,
								CASE(AllowBackOrder) 
									WHEN 0 THEN 'FillPartKillRemainder' 
									ELSE 'FillPartBackorderRemainderShipAsAvailable' 
								END
						FROM VX_Requisition_Dtl rd WITH(NOLOCK) 
							INNER JOIN VX_Reorder_Control rc 
								ON rd.RequisitionNo = rc.RequisitionNo
						WHERE rd.RequisitionNo = @curReq 
							AND rd.RequestedQty > 0
					IF @@ERROR != 0 SET @err = @@ERROR

					----insert order into audit log.....
					INSERT INTO VX_Submit_Audit_Log ( RequisitionNo,PONumber,SubmitDate )
						SELECT	 @curReq
								,@curPO
								,GETDATE()
					IF @@ERROR != 0 SET @err = @@ERROR
					
					----------------------------------------------------------------------------------------
					----update VX_Reorder_Control status to Submitted for user's locked reqs....
					UPDATE VX_Reorder_Control
						SET [Status] = 30
					WHERE RequisitionNo = @curReq
					IF @@ERROR != 0 SET @err = @@ERROR
								
					----update requisition hdr & dtl statues from VX_Reorder_Control....
					UPDATE VX_requisition_hdr
						SET	 [Status]=30
							,OrdRefID=@OrdRefId
					WHERE RequisitionNo = @curReq
					IF @@ERROR != 0 SET @err = @@ERROR

					UPDATE VX_requisition_dtl
						SET [Status] = 30
					WHERE RequisitionNo = @curReq
					IF @@ERROR != 0 SET @err = @@ERROR
					END
		END
		ELSE IF @curVend <> 'IDB&TDISTR' AND EXISTS(SELECT VendorID FROM HPB_EDI..Vendor_SAN_Codes WHERE VendorID=@curVend)
		BEGIN
			----insert orders into EDI tables.....----------------------------------------------
			INSERT INTO HPB_EDI..[850_PO_Hdr] (	 PONumber,IssueDate,VendorID,ShipToLoc,ShipToSAN,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN,TotalLines,TotalQty
												,InsertDateTime,Processed)
				SELECT	 rh.PONumber
						,CAST(CONVERT(VARCHAR(8),GETDATE(),112) AS DATETIME)
						,rh.VendorID
						,hc.LocationNo
						,hc.SANCode
						,bt.LocationNo
						,bt.SANCode
						,'VEND'
						,vc.SANCode
						,(SELECT COUNT(Itemcode) FROM VX_Requisition_Dtl WHERE RequisitionNo=@curReq AND RequestedQty>0)
						,rh.ReqQty
						,GETDATE()
						,0
				FROM VX_Requisition_Hdr rh WITH (NOLOCK) 
					INNER JOIN VX_Reorder_Control rc WITH (NOLOCK) 
						ON rh.RequisitionNo=rc.RequisitionNo
					INNER JOIN VX_Requisition_Dtl rd WITH (NOLOCK) 
						ON rh.RequisitionNo=rd.RequisitionNo
					INNER JOIN HPB_EDI..HPB_SAN_Codes hc WITH (NOLOCK) 
						ON hc.LocationNo=rh.LocationNo
					INNER JOIN HPB_EDI..Vendor_SAN_Codes vc WITH (NOLOCK) 
						ON vc.VendorID=rh.VendorID
					LEFT OUTER join HPB_EDI..HPB_SAN_Codes bt WITH (NOLOCK) 
						ON bt.LocationNo='HPBCA'			
				WHERE rh.RequisitionNo = @curReq
				GROUP BY rh.PONumber,rh.VendorID,hc.LocationNo,hc.SANCode,bt.LocationNo,bt.SANCode,vc.VendorID,vc.SANCode,rh.ReqQty			
			IF @@ERROR != 0 SET @err = @@ERROR
			
			----get and set OrdRefId from insert.....
			SET @OrdRefId = @@identity

			IF @@ERROR = 0 AND ISNULL(@OrdRefId,0) <> 0 AND EXISTS (SELECT PONumber FROM HPB_EDI..[850_PO_Hdr] WHERE LTRIM(RTRIM(PONumber))=@curPO)
			BEGIN 
				INSERT INTO HPB_EDI..[850_PO_Dtl] ( OrdID,[LineNo],Qty,UOM,UnitPrice,PriceCode,ItemIDCode,ItemIdentifier,ItemFillTerms,XActionCode,FillAmount )
					SELECT	 @OrdRefId
							,rd.LineNum
							,rd.RequestedQty
							,'UN'
							,rd.Cost
							,'NT'
							,'EN'
							,rd.VendorItem
							,CASE(AllowBackOrder) WHEN 0 
								THEN 'N' 
								ELSE 'O' 
							 END
							,'0'
							,rd.ExtCost
					FROM VX_Requisition_Dtl rd WITH(NOLOCK) 
						INNER JOIN VX_Reorder_Control rc 
							ON rd.RequisitionNo = rc.RequisitionNo
					WHERE rd.RequisitionNo = @curReq 
						AND rd.RequestedQty > 0
					ORDER BY rd.LineNum 
				IF @@ERROR != 0 SET @err = @@ERROR

				----insert order into audit log.....
				INSERT INTO VX_Submit_Audit_Log(RequisitionNo,PONumber,SubmitDate)
					SELECT	 @curReq
							,@curPO
							,GETDATE()
				IF @@ERROR != 0 SET @err = @@ERROR
							
				----------------------------------------------------------------------------------------
				----update VX_Reorder_Control status to Submitted for user's locked reqs....
				UPDATE VX_Reorder_Control
					SET [Status] = 30
				WHERE RequisitionNo = @curReq
				IF @@ERROR != 0 SET @err = @@ERROR
				
				----update requisition hdr & dtl statues from VX_Reorder_Control....
				UPDATE VX_requisition_hdr
					SET	 [Status]= 30
						,ordrefid = @OrdRefId
				WHERE RequisitionNo = @curReq
				IF @@ERROR != 0 SET @err = @@ERROR

				UPDATE VX_requisition_dtl
					SET [Status] = 30
				WHERE RequisitionNo = @curReq
				if @@ERROR != 0 set @err = @@ERROR
			END			
		END
	END
	ELSE IF @inHouseOnly=1
	BEGIN
		----this section only approves the orders and sends them through the system without EDI...				
		----insert order into audit log.....
		INSERT INTO VX_Submit_Audit_Log(RequisitionNo,PONumber,SubmitDate,ResponseDate,ProcessedFlag)
			SELECT	 @curReq
					,@curPO
					,GETDATE()
					,GETDATE()
					,1
		IF @@ERROR != 0 SET @err = @@ERROR
		----------------------------------------------------------------------------------------
		----update VX_Reorder_Control status to Submitted for user's locked reqs....
		UPDATE VX_Reorder_Control
			SET [Status] = 50
			WHERE RequisitionNo = @curReq
		IF @@ERROR != 0 SET @err = @@ERROR
		
		----update requisition hdr & dtl statues from VX_Reorder_Control....
		UPDATE VX_requisition_hdr
			SET  [Status] = 50
				,OrdRefID = @OrdRefId
				,ApprovedBy = @user
				,ApprovedDate = @curDT
		WHERE RequisitionNo = @curReq				
		IF @@ERROR != 0 SET @err = @@ERROR

		UPDATE VX_requisition_dtl
			SET  [Status] = 50
				,ConfirmedQty=RequestedQty
				,ApprovedBy = @user
				,ApprovedDate = @curDT
		WHERE RequisitionNo = @curReq
		IF @@ERROR != 0 SET @err = @@ERROR
		
		----insert requisition into audit log for move to DIPS....
		INSERT INTO VX_Requisition_Audit_Log (RequisitionNo, PONumber, ReqApprovedDate, ProcessedDate, ProcessedFlag, Comments, InHouse)
			SELECT	 @curReq
					,@curPO
					,GETDATE()
					,NULL
					,0
					,NULL
					,@inHouseOnly						
		IF @@ERROR != 0 SET @err = @@ERROR
			
		----------check - insert - update any kit items on order......
		IF EXISTS( SELECT rd.ItemCode FROM VX_Requisition_Dtl rd INNER JOIN VX_Vendor_Kits vk ON rd.ItemCode=vk.ParentItem WHERE rd.PONumber=@curPO)
		BEGIN
			----insert kit items....
			INSERT INTO VX_Requisition_Dtl ( RequisitionNo,LineNum,ItemCode,VendorItem,RequestedQty,SuggestedQty,ConfirmedQty,CanceledQty,BackOrderQty,RequestedBy
											,RequestedDate,Cost,ExtCost,[Status],PONumber,AllowBackOrder,ShipFrom )
				SELECT	 rd.RequisitionNo
						,ROW_NUMBER() OVER (PARTITION BY rd.lineNum ORDER BY rd.lineNum)+CAST(MAX(rd.LineNum) AS INT)
						,vk.KitItem
						,pm.ISBN
						,vk.KitQty
						,0
						,vk.KitQty * rd.RequestedQty
						,0
						,0
						,rd.RequestedBy
						,GETDATE()
						,pm.Cost
						,pm.Cost * (vk.KitQty * rd.RequestedQty)
						,rd.[Status]
						,rd.PONumber
						,0
						,NULL
				FROM HPB_Prime..ProductMaster pm 
					INNER JOIN VX_Vendor_Kits vk 
						ON pm.ItemCode=vk.KitItem
					INNER JOIN VX_Requisition_Dtl rd 
						ON vk.ParentItem=rd.ItemCode
				WHERE rd.PONumber=@curPO 
					AND rd.ItemCode NOT IN (SELECT DISTINCT KitItem FROM VX_Vendor_Kits WHERE parentitem=rd.itemcode)
				GROUP BY rd.RequisitionNo,rd.LineNum,vk.KitItem,pm.ISBN,vk.KitQty,rd.RequestedBy,vk.KitQty * rd.RequestedQty,pm.Cost,pm.Cost *(vk.KitQty * rd.RequestedQty)
						,rd.[Status],rd.PONumber
		
			----update parent item....
			UPDATE rd
				SET	 rd.CanceledQty=rd.RequestedQty
					,rd.ConfirmedQty=0
					,rd.Comments='KitUpdate'
			FROM VX_Requisition_Dtl rd 
				INNER JOIN VX_Vendor_Kits vk 
					ON rd.ItemCode=vk.ParentItem
			WHERE rd.PONumber=@curPO 
		END
	END
	SET @loop = @loop - 1
	END
	
	DROP TABLE #reqTmp
	----Commit or Rollback trans...........
	SET @rVal = @err
	IF @rVal=0
	BEGIN
		COMMIT TRANSACTION VX_ReqSubmit
		RETURN @rVal
	END
	ELSE
	BEGIN
		ROLLBACK  TRANSACTION VX_ReqSubmit
		RETURN @rVal
	END
END