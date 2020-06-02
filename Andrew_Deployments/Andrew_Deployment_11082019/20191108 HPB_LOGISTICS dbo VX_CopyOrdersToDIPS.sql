USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[VX_CopyOrdersToDIPS]    Script Date: 11/8/2019 11:04:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Joey B.
-- Create date: 11/12/2012
-- Description:	Copies approved orders to HPB_d
-- =============================================
-- 2019-09-30 Added HPB_EDI.EDI.ApplicationMaster to check for drop shipments.  Add POA type to tmpReqHdr temp table. This will case Order Header to add a "D" to the PO type to push
-- items into store receiving.
-- 2019-11-08 Updated to allow for In-House Orders to move to DIPS
ALTER PROCEDURE [dbo].[VX_CopyOrdersToDIPS] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    DECLARE	 @rVal INT = 0
			,@err  INT = 0
			,@loop INT
	
	DECLARE @tmpReqHdr TABLE (RowID INT identity(1,1),ReqNo CHAR(6),PONo CHAR(6),LocNo CHAR(5),VendID VARCHAR(12),ReqDate DATETIME,ReqBy VARCHAR(30),AprvBy VARCHAR(30),AprvDate DATETIME,ReqQty INT,ReqAmt MONEY, POType VARCHAR(1), InHouse BIT)
	DECLARE @tmpReqDtl TABLE (ReqNo CHAR(6),PONo CHAR(6),ItemCode CHAR(20),VendItemNo VARCHAR(20),LineNum VARCHAR(6),ReqQty INT,ReqBy VARCHAR(30),ReqDate DATETIME,AprvBy VARCHAR(30),AprvDate DATETIME,Cost MONEY,ExtCost MONEY)
	DECLARE @tmpOrdHdr TABLE (PONo CHAR(6),LocNo CHAR(5),POType VARCHAR(1),BuyerID VARCHAR(10),VendorID VARCHAR(10),TermsCode VARCHAR(10),PODate SMALLDATETIME,CancelDate SMALLDATETIME,DueDate SMALLDATETIME,OrdAmt MONEY,Printed BIT,SendPO BIT,SpecInstr VARCHAR(255),Complete BIT,DateComplete BIT,SkeletonCrtFrom VARCHAR(6),CrtFromReq BIT,ShipToName VARCHAR(30),ShipToAddr1 VARCHAR(30),ShipToAddr2 VARCHAR(30),ShipToAddr3 VARCHAR(30))
	DECLARE @tmpOrdDtl TABLE (PONo CHAR(6),POLine CHAR(5),ItemCode CHAR(20),ISBN VARCHAR(13),DistType VARCHAR(1),OrdQty INT,UnitType VARCHAR(3),UnitCost MONEY,ExtLineCost MONEY,SchemeID VARCHAR(20),FileClaimAdj BIT,VouchNo VARCHAR(10),LocNo CHAR(5),Complete BIT, DateComplete SMALLDATETIME,SpecInstr VARCHAR(50),Discount float,RemovedFromRct BIT,QtyCnt INT,QtyPer INT,ExtQty INT,RowAddFrom VARCHAR(20),RowAddBy CHAR(10),RowAddDate DATETIME)
	
	INSERT INTO @tmpReqHdr(ReqNo, PONo, LocNo, VendID, ReqDate, ReqBy, AprvBy, AprvDate, ReqQty, ReqAmt, POType, InHouse)
		SELECT	 srh.RequisitionNo		AS ReqNo
				,srh.PONumber			AS PONo
				,srh.LocationNo			AS LocNo
				,srh.VendorID			AS VendID
				,srh.RequisitionDate	AS ReqDate
				,srh.RequestBy			AS ReqBy
				,srh.ApprovedBy			AS AprvBy
				,srh.ApprovedDate		As AprvDate
				,srh.ReqQty				AS ReqQty
				,srh.ReqAmt				AS ReqAmt
				,CASE WHEN am.PO__BULK IS NOT NULL 
					  THEN 'D' 
					  ELSE '' 
				 END					AS POType
				,am.InHouseOnly			AS InHouse
		FROM dbo.VX_Requisition_Hdr srh 
			INNER JOIN dbo.VX_Requisition_Audit_Log sral 
				ON srh.RequisitionNo = sral.RequisitionNo
			LEFT JOIN HPB_EDI.edi.ApplicationMaster am
				ON srh.VendorID = am.VendorID
					AND ISNULL(am.PO__BULK,'') <> ''
		WHERE sral.ProcessedFlag = 0 
			AND srh.[Status] IN (50,55) 
			AND DATEDIFF(N,sral.ReqApprovedDate,GETDATE())>1 
	
	INSERT INTO @tmpReqDtl (ReqNo ,PONo ,ItemCode ,VendItemNo ,LineNum ,ReqQty ,ReqBy ,ReqDate ,AprvBy ,AprvDate ,Cost ,ExtCost )
		SELECT	 srd.RequisitionNo	AS ReqNo
				,srd.PONumber		AS PONo
				,srd.ItemCode		AS ItemCode
				,srd.VendorItem		AS VendItemNo
				,srd.LineNum		AS LineNum
				,srd.ConfirmedQty	AS ReqQty
				,srd.RequestedBy	AS ReqBy
				,srd.RequestedDate	AS ReqDate
				,srd.ApprovedBy		AS AprvBy
				,srd.ApprovedDate	AS AprvDate
				,srd.Cost			AS Cost
				,srd.ExtCost		AS ExtCost
		FROM dbo.VX_Requisition_Dtl srd 
			INNER JOIN dbo.VX_Requisition_Audit_Log sral 
				ON srd.RequisitionNo = sral.RequisitionNo
		WHERE sral.ProcessedFlag = 0 
			AND srd.[Status] IN (50,55) 
			AND srd.RequestedQty > 0 
			AND DATEDIFF(N,sral.ReqApprovedDate,GETDATE())>1 
	
	SELECT  @loop = MAX(RowID) 
	FROM @tmpReqHdr
	SET @err = @@ERROR
	
	WHILE @loop > 0
		BEGIN
			----DECLARE AND SET current values....
			DECLARE	 @curReq	CHAR(6)
					,@curPO		CHAR(6)
					,@curLoc	CHAR(5)
					,@vendor	VARCHAR(12)
					,@AppDate	DATE
					,@shipID	INT = 0
		
			SELECT	 @curReq = ReqNo
					,@curPO = PONo
					,@curLoc = LocNo
					,@vendor = VendID 
			FROM @tmpReqHdr 
			WHERE RowID = @loop
				
			IF @vendor = 'IDB&TDISTR'
				BEGIN			
					-- Check for ship notice to UPDATE order...IF exists process else SET to 55 AND check later....
					SELECT @shipID = sh.ShipID 
					FROM BakerTaylor.dbo.bulkorder_shipnotice_Header sh 
						INNER JOIN BakerTaylor.dbo.bulkorder_shipnotice_ItemDetail sd 
							ON sh.ShipID=sd.ShipID	
					WHERE sd.BuyersOrderReference = @curPO 
						AND (sh.IssueDateTime < CAST(GETDATE() AS DATE) 
						OR EXISTS(SELECT ASNRefNumber FROM BakerTaylor.dbo.bulkorder_invoice_Header WHERE ASNRefNumber=sh.ASNNumber))				
				END
			ELSE IF @vendor <> 'IDB&TDISTR'
				BEGIN
					IF EXISTS(	SELECT 1
								FROM @tmpReqHdr rh
								WHERE rh.PONo = @curPO
									AND rh.InHouse = 1)
						BEGIN
							-- Create a Fake ShipId for in house orders; we do not receive acknowledgements for these
							SELECT @shipID = CAST(LEFT(RIGHT(REPLACE(CAST(CAST(GETDATE() AS DATE) AS VARCHAR(10)),'-', ''),6),4) +  CAST(FLOOR(RAND()*9999)+ 10 AS VARCHAR(50)) AS INT)
						END
					ELSE
						SELECT @shipID = ah.AckID 
						FROM [HPB_EDI].[blk].[AcknowledgeHeader] ah 
							INNER JOIN [HPB_EDI].[BLK].[AcknowledgeDetail] ad 
								ON ah.AckID=ad.AckID 							
							WHERE ah.PONumber=@curPO					

					IF LTRIM(RTRIM(@shipID))='' BEGIN SET @shipID=0 END
					/*
						IF @shipID <> 0 ----used for ASN updating only........
							BEGIN
								UPDATE rd 
									SET rd.ConfirmedQty=isnull(ad.ShipQty,0),rd.CanceledQty=CASE WHEN ISNULL(ad.ShipQty,0)=0 THEN rd.ConfirmedQty ELSE rd.CanceledQty END,
										rd.ExtCost=isnull(ad.ShipQty,0)*rd.Cost
								FROM VX_Requisition_Dtl rd 
									INNER JOIN [HPB_EDI].[BLK].[ShipmentHeader] ah on rd.PONumber=ah.PONumber
									INNER JOIN [HPB_EDI].[BLK].[ShipmentDetail] ad on ah.ShipID=ad.ShipID AND rd.VendorItem=ad.ItemIdentifier
								WHERE rd.PONumber=@curPO
						
								UPDATE rh
									SET rh.ReqQty=(SELECT SUM(ConfirmedQty) FROM VX_Requisition_Dtl WHERE PONumber=@curPO),
										rh.ReqAmt=(SELECT SUM(ExtCost) FROM VX_Requisition_Dtl WHERE PONumber=@curPO)
								FROM VX_Requisition_Hdr rh 
								WHERE rh.PONumber=@curPO
						
								UPDATE rd
									SET  rd.ReqQty=isnull(ad.ShipQty,0),rd.ExtCost=isnull(ad.ShipQty,0)*rd.Cost
								FROM @tmpReqDtl rd 
									INNER JOIN [HPB_EDI].[BLK].[ShipmentHeader] ah ON rd.PONo=ah.PONumber
									INNER JOIN [HPB_EDI].[BLK].[ShipmentDetail] ad ON ah.ShipID=ad.ShipID AND rd.VendItemNo=ad.ItemIdentifier
								WHERE rd.PONo=@curPO	
						
								UPDATE rh
									SET rh.ReqQty=(SELECT SUM(ReqQty) FROM @tmpReqDtl WHERE PONo=@curPO),
										rh.ReqAmt=(SELECT SUM(ExtCost) FROM @tmpReqDtl WHERE PONo=@curPO)
								FROM @tmpReqHdr rh 
								WHERE rh.PONo=@curPO						
							END				
					*/
				END
					
			----IF exists then add any backordered items to the order......		
			IF @shipID <> 0
				BEGIN
					IF EXISTS(	SELECT sh.ShipID FROM BakerTaylor.dbo.bulkorder_shipnotice_Header sh INNER JOIN BakerTaylor.dbo.bulkorder_shipnotice_ItemDetail sd ON sh.ShipID=sd.ShipID
								WHERE sd.BuyersOrderReference <> @curPO 
									AND sh.ShipID IN (	SELECT DISTINCT sh.ShipID 
														FROM BakerTaylor.dbo.bulkorder_shipnotice_Header sh 
														INNER JOIN BakerTaylor..bulkorder_shipnotice_ItemDetail sd ON sh.ShipID=sd.ShipID	
														WHERE sd.BuyersOrderReference = @curPO)) 
														AND @vendor = 'IDB&TDISTR'
						BEGIN
							-- Add backorderd items to @tmpReqDtl.....
							INSERT INTO @tmpReqDtl (ReqNo ,PONo ,ItemCode ,VendItemNo ,LineNum ,ReqQty ,ReqBy ,ReqDate ,AprvBy ,AprvDate ,Cost ,ExtCost )
								SELECT	 @curReq									AS ReqNo	
										,@curPO										AS PONo
										,r.ItemCode									AS ItemCode
										,r.VendorItem								AS VendItemNo
										,(	SELECT MAX(CAST(LineNum AS INT))+1 
											FROM @tmpReqDtl 
											WHERE PONo=@curPO)						AS LineNum
										,sd.ShippedQuantity							AS ReqQty
										,r.RequestedBy								AS ReqBy
										,r.RequestedDate							AS ReqDate
										,r.ApprovedBy								AS AprvBy
										,r.ApprovedDate								AS AprvDate
										,r.Cost										AS Cost
										,sd.ShippedQuantity*r.Cost					AS ExtCost
								FROM BakerTaylor.dbo.bulkorder_shipnotice_Header sh 
										INNER JOIN BakerTaylor.dbo.bulkorder_shipnotice_ItemDetail sd 
											ON sh.ShipID=sd.ShipID
										INNER JOIN BakerTaylor.dbo.codes_SAN c WITH(NOLOCK)
											ON sh.ShipToPartyIdentifier=c.SAN+' '+c.Suffix
										INNER JOIN [HPB_Prime].[dbo].[Locations] l WITH(NOLOCK) 
											ON l.LocationNo=c.LocationNo
										INNER JOIN (	SELECT rh.LocationNo,rd.ItemCode,rd.VendorItem,rd.PONumber,rd.RequestedBy,rd.RequestedDate,rd.ApprovedBy,rd.ApprovedDate,rd.Cost 
														FROM VX_Requisition_Dtl rd 
															INNER JOIN VX_Requisition_Hdr rh ON rd.PONumber=rh.PONumber) r
											ON sd.BuyersOrderReference=r.PONumber 
												AND sd.ProductIdentifier=r.VendorItem 
												AND r.LocationNo=l.LocationNo
								WHERE sd.BuyersOrderReference<>@curPO 
									AND sd.ProductIdentifier NOT IN (r.VendorItem) 
									AND sh.ShipID IN (	SELECT DISTINCT sh.ShipID FROM BakerTaylor.dbo.bulkorder_shipnotice_Header sh 
														INNER JOIN BakerTaylor.dbo.bulkorder_shipnotice_ItemDetail sd ON sh.ShipID=sd.ShipID	
														WHERE sd.BuyersOrderReference = @curPO)

								UPDATE rh
									SET rh.ReqQty = (SELECT SUM(ReqQty)  FROM @tmpReqDtl WHERE PONo=@curPO), 
										rh.ReqAmt = (SELECT SUM(ExtCost) FROM @tmpReqDtl WHERE PONo=@curPO) 
								FROM @tmpReqHdr rh 
								WHERE rh.PONo = @curPO
						END
							
					-------------------------Add any updates for non BT vendors here............................................
					
					------------------------------------------------------------------------------------------------------------
					
					DELETE FROM @tmpOrdHdr
					DELETE FROM @tmpOrdDtl

					-- Build Order temp tables based on Req tables........
					INSERT INTO @tmpOrdHdr (PONo ,LocNo ,POType ,BuyerID ,VendorID ,TermsCode ,PODate ,CancelDate ,DueDate ,OrdAmt ,Printed ,SendPO ,SpecInstr ,Complete ,DateComplete ,SkeletonCrtFrom ,CrtFromReq ,ShipToName ,ShipToAddr1 ,ShipToAddr2 ,ShipToAddr3 )
						SELECT	 rh.PONo							AS PONo
								,rh.LocNo							AS LocNO
								,ISNULL(rh.POType,'')				AS POType
								,'KBEVERLY'							AS BuyerID
								,rh.VendID							AS VendorID
								,vm.TermsCode						AS TermsCode
								,CAST(GETDATE() AS SMALLDATETIME)	AS PODate
								,NULL								AS CancelDate
								,NULL								AS DueDate
								,rh.ReqAmt							AS OrdAmt
								,0									AS Printed
								,1									AS SendPO
								,''									AS SpecInstr
								,0									AS Complete
								,null								AS DateComplete
								,rh.PONo							AS SkeletonCrtFrom 
								,0									AS CrtFromReq 
								,l.MailToName						AS ShipToName
								,l.MailToAddress1					AS ShipToAddr1
								,l.MailToAddress2					AS ShipToAddr2
								,l.MailToAddress3					AS ShipToAddr3
						FROM @tmpReqHdr rh 
							INNER JOIN [HPB_Prime].[dbo].[VendorMaster] vm 
								ON rh.VendID = vm.VendorID
							INNER JOIN [HPB_Prime].[dbo].[Locations] l 
								ON rh.LocNo = l.LocationNo
						WHERE rh.PONo=@curPO
					
					INSERT INTO @tmpOrdDtl(PONo ,POLine ,ItemCode ,ISBN ,DistType ,OrdQty ,UnitType ,UnitCost ,ExtLineCost ,SchemeID ,FileClaimAdj ,VouchNo ,LocNo ,Complete , DateComplete ,SpecInstr ,Discount ,RemovedFromRct ,QtyCnt ,QtyPer ,ExtQty ,RowAddFrom ,RowAddBy ,RowAddDate )
						SELECT	 rd.PONo			AS PONo
								,RIGHT(REPLICATE('0',5) + CAST( ROW_NUMBER() OVER (PARTITION BY rh.LocNo ORDER BY rh.LocNo) AS VARCHAR(5) ),5) AS POLine
								,rd.ItemCode as ItemCode
								,rd.VendItemNo		AS ISBN
								,'T'				AS DistType
								,rd.ReqQty			AS OrdQty
								,'EA'				AS UnitType
								,rd.Cost			AS UnitCost
								,rd.ExtCost			AS ExtLineCost
								,pmd.SchemeID		AS SchemaID
								,0					AS FileClaimAdj
								,NULL				AS VounchNo
								,rh.LocNo			AS LocNo
								,0					AS Complete
								,NULL				AS DateComplete
								,''					AS SpecInstr
								,0					AS Discount
								,0					AS RemovedFromRct
								,NULL				AS QtyCnt
								,0					AS QtyPer
								,rd.ReqQty			AS ExtQty
								,'Vendor Exchange'	AS RowAddFrom
								,'DISTADMIN'		AS RowAddBy
								,GETDATE()			AS RowAddDate
						FROM @tmpReqDtl rd 
							INNER JOIN @tmpReqHdr rh 
								ON rd.ReqNo = rh.ReqNo
							INNER JOIN [HPB_Prime].[dbo].[VendorMaster] vm 
								ON rh.VendID = vm.VendorID
							INNER JOIN [HPB_Prime].[dbo].[ProductMaster] pm 
								ON rd.ItemCode = pm.ItemCode
							INNER JOIN [HPB_Prime].[dbo].[ProductMasterDist] pmd 
								ON pm.ItemCode = pmd.ItemCode
						WHERE rd.PONo=@curPO
			
					-- Check IF any other location/vendor requisitions exist that have not been consolidated
					IF NOT EXISTS(	SELECT requisitionno FROM OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader
									WHERE requisitionno = @curReq AND ponumber = @curPO AND locationno = @curLoc AND vendorid = @vendor)
						BEGIN
							----INSERT requisition header AND details....
							INSERT INTO OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader ([RequisitionNo], [LocationNo], [RequestBy], [VendorID], [RequisitionDate], [ApprovedBy], [DateApprovedDisapproved], [PONumber], [LastDateVoided], [LastDateVoidedBy], [Comments])
								SELECT	 ReqNo								AS [RequisitionNo]
										,LocNo								AS [LocationNo]
										,ReqBy								AS [RequestBy]
										,VendID								AS [VendorID]
										,ReqDate							AS [RequisitionDate] 
										,AprvBy								AS [ApprovedBy] 
										,CAST(AprvDate AS SMALLDATETIME)	AS [DateApprovedDisapproved] 
										,PONo								AS [PONumber] 
										,NULL								AS [LastDateVoided] 
										,NULL								AS [LastDateVoidedBy] 
										,NULL								AS [Comments]
								FROM @tmpReqHdr
								WHERE ReqNo = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END
							
							INSERT INTO OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitiondetail ([RequisitionNo], [ItemCode], [ItemRequestDate], [RequestedQtyToOrder], [UnitType], [Approved], [ApprovedBy], [ApprovedQtyToOrder], [DateApprovedDisapproved], [PONumber])
								SELECT	 ReqNo								AS [RequisitionNo]
										,ItemCode							AS [ItemCode]
										,ReqDate							AS [ItemRequestDate]
										,ReqQty								AS [RequestedQtyToOrder]
										,NULL								AS [UnitType]
										,1									AS [Approved]
										,AprvBy								AS [ApprovedBy]
										,ReqQty								AS [ApprovedQtyToOrder]
										,CAST(AprvDate AS SMALLDATETIME)	AS [DateApprovedDisapproved]
										,PONo								AS [PONumber]
								FROM @tmpReqDtl
								WHERE ReqNo = @curReq 
									AND ReqQty<>0
							IF @err = 0 BEGIN SET @err = @@ERROR END
							
							----INSERT order header AND details....					
						INSERT INTO OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.orderheader ([PONumber],[LocationNo], [POType], [BuyerID], [VendorID], [TermsCode], [PODate], [CancelDate], [DueDate], [OrderAmount], [Printed], [SendPO], [SpecInstructions], [Complete], [DateComplete], [SkeletonCreatedFrom], [CreatedFromRequisition], [ShipToName], [ShipToAddress1], [ShipToAddress2], [ShipToAddress3])
								SELECT	 PONo								AS [PONumber]
										,LocNo								AS [LocationNo]
										,POType								AS [POType]
										,BuyerID							AS [BuyerID]
										,VendorID							AS [VendorID]
										,TermsCode							AS [TermsCode]
										,PODate								AS [PODate] 
										,CancelDate							AS [CancelDate] 
										,DueDate							AS [DueDate] 
										,OrdAmt								AS [OrderAmount] 
										,Printed							AS [Printed] 
										,SendPO								AS [SendPO] 
										,SpecInstr							AS [SpecInstructions] 
										,Complete							AS [Complete] 
										,DateComplete						AS [DateComplete] 
										,SkeletonCrtFrom					AS [SkeletonCreatedFrom] 
										,CrtFromReq							AS [CreatedFromRequisition] 
										,ShipToName							AS [ShipToName]
										,ShipToAddr1						AS [ShipToAddress1] 
										,ShipToAddr2						AS [ShipToAddress2] 
										,ShipToAddr3						AS [ShipToAddress3]
								FROM @tmpOrdHdr
								WHERE PONo = @curPO
							IF @err = 0 BEGIN SET @err = @@ERROR END
							
						INSERT INTO OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.orderdetail ([PONumber], [POLine], [ItemCode], [ISBN], [DistributionType], [OrderQty], [UnitType], [UnitCost], [ExtendedLineCost], [SchemeID], [FileClaimAdjustment], [VoucherNo], [LocationNo], [Complete], [DateComplete], [SpecialInstructions], [Discount], [RemovedFromReceiver], [QtyCounted], [QtyPer], [ExtendedQty], [RowAddedFrom], [RowAddedByUser], [RowAddedDate])
								SELECT	 PONo								AS [PONumber]
										,POLine								AS [POLine]
										,ItemCode							AS [ItemCode]
										,ISBN								AS [ISBN]
										,DistType							AS [DistributionType]
										,OrdQty								AS [OrderQty]
										,UnitType							AS [UnitType]
										,UnitCost							AS [UnitCost]
										,ExtLineCost						AS [ExtendedLineCost]
										,SchemeID							AS [SchemeID]
										,FileClaimAdj						AS [FileClaimAdjustment]
										,VouchNo							AS [VoucherNo]
										,LocNo								AS [LocationNo]
										,Complete							AS [Complete]   
										,DateComplete						AS [DateComplete]
										,SpecInstr							AS [SpecialInstructions] 
										,Discount							AS [Discount] 
										,RemovedFromRct						AS [RemovedFromReceiver]
										,QtyCnt								AS [QtyCounted]
										,QtyPer								AS [QtyPer]
										,ExtQty								AS [ExtendeQty]
										,RowAddFrom							AS [RowAddedFrom]
										,RowAddBy							AS [RowAddedByUser]
										,RowAddDate							AS [RowAddedDate]
								FROM @tmpOrdDtl	
								WHERE PONo = @curPO AND OrdQty<>0
							IF @err = 0 BEGIN SET @err = @@ERROR END
											
							-- UPDATE STOC_Reorder_Control status to approved for user's locked reqs....
							UPDATE VX_Reorder_Control
								SET [Status] = 60
							WHERE RequisitionNo = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END

							-- UPDATE requisition hdr & dtl statues FROM STOC_Reorder_Control....
							UPDATE VX_Requisition_Hdr
								SET [Status] = 60
							WHERE requisitionno = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END

							UPDATE VX_Requisition_Dtl
								SET [Status] = 60
							WHERE requisitionno = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END
							
							UPDATE [HPB_EDI].[BLK].[ShipmentHeader]
								SET	 Processed=1
									,ProcessedDateTime=GETDATE()
							WHERE PONumber=@curPO
							IF @err = 0 BEGIN SET @err = @@ERROR END
							
							-- UPDATE audit log....
							UPDATE dbo.VX_Requisition_Audit_Log
								SET	 processeddate = GETDATE()
									,processedflag = 1
									,Comments = NULL
							WHERE requisitionno = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END
						END
					ELSE
						BEGIN
							UPDATE dbo.VX_Requisition_Audit_Log
								SET Comments = 'duplicate order copy failure'
							WHERE RequisitionNo = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END
						END
				END			
			ELSE
				BEGIN
					IF (SELECT [Status] FROM VX_Reorder_Control WHERE RequisitionNo=@curReq) <> 55
						BEGIN
							-- UPDATE STOC_Reorder_Control status to approved for user's locked reqs
							UPDATE VX_Reorder_Control
								SET [Status] = 55
							WHERE RequisitionNo = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END

							----UPDATE requisition hdr & dtl statues FROM STOC_Reorder_Control....
							UPDATE VX_Requisition_Hdr
								SET [Status] = 55
							WHERE requisitionno = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END

							UPDATE VX_Requisition_Dtl
								SET [Status] = 55
							WHERE requisitionno = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END
							
							UPDATE vx_requisition_audit_log
								SET Comments = 'awaiting ship confirmation'
							WHERE RequisitionNo = @curReq
							IF @err = 0 BEGIN SET @err = @@ERROR END
						END
				END
			SET @loop = @loop - 1
		END
	SET @rVal = @err
	RETURN @rVal	
END
GO


