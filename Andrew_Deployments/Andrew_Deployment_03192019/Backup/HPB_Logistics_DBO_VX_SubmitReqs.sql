USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[VX_SubmitReqs]    Script Date: 3/19/2019 9:12:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Joey B.>
-- Create date: <10/24/2012>
-- Description:	<Submit Requisitions>
-- =============================================
CREATE PROCEDURE [dbo].[VX_SubmitReqs] 
	@user varchar(20), @inHouseOnly bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

----testing.........
	--declare @user varchar(20),@inHouseOnly bit
	--set @user = 'jblalock'
	--set @inHouseOnly = 0
----endtesting........

declare @rVal int
set @rVal = 0
declare @err int
set @err = 0
Begin Transaction VX_ReqSubmit

----get reqs for Submission....
	create table #reqTmp (rowid int identity(1,1), reqNo char(6), poNo char(6), vendID varchar(20))
	insert into #reqTmp
	select distinct RequisitionNo, PONumber, VendorID
	from VX_Reorder_Control src inner join VX_Locations l on src.StoreNo = l.LocationNo
	where LockedBy = @user and Locked = 'Y' and RequisitionNo is not null and PONumber is not null and Status = 20 and Active = 'Y'
		and exists(select itemcode from VX_Requisition_Dtl where RequisitionNo = src.RequisitionNo and RequestedQty > 0)

----loop thru and update each req independently to ensure gaps in datetime stamps......
declare @loop int
set @loop = (select MAX(rowID) from #reqTmp)

while @loop > 0
	begin 
		declare @curDT datetime
		set @curDT = GETDATE()
		declare @curReq char(6)
		declare @curPO char(6)
		declare @curVend varchar(20)
		select @curReq = reqNo, @curPO = poNo, @curVend = vendID from #reqTmp where rowid = @loop
		declare @OrdRefId int
		set @OrdRefId = 0

		------ensure inhouse orders don't go through EDI even if flag doesn't get set correctly coming in.....
		set @inHouseOnly = case when (select InHouseOnly from HPB_EDI..Vendor_SAN_Codes where vendorid=@curVend)=0 then @inHouseOnly else 1 end
		
		----only run this section if orders will be sent EDI......
		if @inHouseOnly=0
		begin
			if (@curVend) = 'IDB&TDISTR'  ----BakerTaylor only.....
				begin 		
			----insert orders into BT bulk tables.....----------------------------------------------
				insert into BakerTaylor..bulkorder_Header (OrderNumber,IssueDateTime,PurposeCode,FillTermsCode,BuyerPartyIDType,BuyerPartyIdentifier,SellerPartyIDType,SellerPartyIdentifier,ShipToPartyIDType,ShipToPartyIdentifier)
				select rh.PONumber,CONVERT(varchar(10),GETDATE(),112),'Original',''/*'FillPartKillRemainder'*/,'SAN',cs.SAN,'SAN','1556150','SAN',cs.SAN + ' ' + cs.Suffix
				from VX_Requisition_Hdr rh inner join VX_Reorder_Control rc on rh.RequisitionNo = rc.RequisitionNo
					inner join BakerTaylor..codes_SAN cs on rc.StoreNo = cs.LocationNo and rc.Warehouse = cs.Warehouse
				where rh.RequisitionNo = @curReq 
				if @@ERROR != 0 set @err = @@ERROR
				
			----get and set OrdRefId from insert.....
				set @OrdRefId = @@identity

				if @@ERROR = 0 and isnull(@OrdRefId,0) <> 0
					and exists (select ordernumber from BakerTaylor..bulkorder_Header where ltrim(rtrim(OrderNumber))=@curPO)
					begin 
						insert into BakerTaylor..bulkorder_ItemDetail (OrderID,LineNumber,ProductIDType,ProductIdentifier,OrderQuantity,LineReferenceTypeCode,LineReferenceNumber,ItemFillTermsCode)
						select @OrdRefId,rd.LineNum,'EAN13',right('0000000000000'+rd.VendorItem,13),rd.RequestedQty,/*right(rd.ItemCode,10),*/'BuyersOrderLineReference',rd.LineNum,case(AllowBackOrder) when 0 then 'FillPartKillRemainder' else 'FillPartBackorderRemainderShipAsAvailable' end
						from VX_Requisition_Dtl rd with(nolock) inner join VX_Reorder_Control rc on rd.RequisitionNo = rc.RequisitionNo
						where rd.RequisitionNo = @curReq and rd.RequestedQty > 0
						if @@ERROR != 0 set @err = @@ERROR

					----insert order into audit log.....
						insert into VX_Submit_Audit_Log(RequisitionNo,PONumber,SubmitDate)
						select @curReq,@curPO,GETDATE()
						if @@ERROR != 0 set @err = @@ERROR
					----------------------------------------------------------------------------------------
					----update VX_Reorder_Control status to Submitted for user's locked reqs....
						update VX_Reorder_Control
						set Status = 30
						where RequisitionNo = @curReq
						if @@ERROR != 0 set @err = @@ERROR
						
					----update requisition hdr & dtl statues from VX_Reorder_Control....
						update VX_requisition_hdr
						set status = 30, ordrefid = @OrdRefId
						where requisitionno = @curReq
						if @@ERROR != 0 set @err = @@ERROR

						update VX_requisition_dtl
						set status = 30
						where requisitionno = @curReq
						if @@ERROR != 0 set @err = @@ERROR
					end
				end
			else if @curVend <> 'IDB&TDISTR' and exists(select VendorID from HPB_EDI..Vendor_SAN_Codes where VendorID=@curVend)
				begin
			----insert orders into EDI tables.....----------------------------------------------
				insert into HPB_EDI..[850_PO_Hdr](PONumber,IssueDate,VendorID,ShipToLoc,ShipToSAN,BillToLoc,BillToSAN,ShipFromLoc,ShipFromSAN,TotalLines,TotalQty,InsertDateTime,Processed)
				select rh.PONumber,cast(convert(varchar(8),GETDATE(),112)as datetime),rh.VendorID,hc.LocationNo,hc.SANCode,bt.LocationNo,bt.SANCode,'VEND',vc.SANCode,
					 (select COUNT(Itemcode) from VX_Requisition_Dtl where RequisitionNo=@curReq and RequestedQty>0),rh.ReqQty,GETDATE(),0
				from VX_Requisition_Hdr rh with (nolock) inner join VX_Reorder_Control rc with (nolock) on rh.RequisitionNo=rc.RequisitionNo
					inner join VX_Requisition_Dtl rd with (nolock) on rh.RequisitionNo=rd.RequisitionNo
					inner join HPB_EDI..HPB_SAN_Codes hc with (nolock) on hc.LocationNo=rh.LocationNo
					inner join HPB_EDI..Vendor_SAN_Codes vc with (nolock) on vc.VendorID=rh.VendorID
					left outer join HPB_EDI..HPB_SAN_Codes bt with (nolock) on bt.LocationNo='HPBCA'			
				where rh.RequisitionNo = @curReq
				group by rh.PONumber,rh.VendorID,hc.LocationNo,hc.SANCode,bt.LocationNo,bt.SANCode,vc.VendorID,vc.SANCode,rh.ReqQty
				
				if @@ERROR != 0 set @err = @@ERROR
				
			----get and set OrdRefId from insert.....
				set @OrdRefId = @@identity

				if @@ERROR = 0 and isnull(@OrdRefId,0) <> 0
					and exists (select PONumber from HPB_EDI..[850_PO_Hdr] where ltrim(rtrim(PONumber))=@curPO)
					begin 
						insert into HPB_EDI..[850_PO_Dtl](OrdID,[LineNo],Qty,UOM,UnitPrice,PriceCode,ItemIDCode,ItemIdentifier,ItemFillTerms,XActionCode,FillAmount)
						select @OrdRefId,rd.LineNum,rd.RequestedQty,'UN',rd.Cost,'NT','EN',rd.VendorItem,case(AllowBackOrder) when 0 then 'N' else 'O' end,'0',rd.ExtCost
						from VX_Requisition_Dtl rd with(nolock) inner join VX_Reorder_Control rc on rd.RequisitionNo = rc.RequisitionNo
						where rd.RequisitionNo = @curReq and rd.RequestedQty > 0
						order by rd.LineNum 
						
						if @@ERROR != 0 set @err = @@ERROR

					----insert order into audit log.....
						insert into VX_Submit_Audit_Log(RequisitionNo,PONumber,SubmitDate)
						select @curReq,@curPO,GETDATE()
						if @@ERROR != 0 set @err = @@ERROR
					----------------------------------------------------------------------------------------
					----update VX_Reorder_Control status to Submitted for user's locked reqs....
						update VX_Reorder_Control
						set Status = 30
						where RequisitionNo = @curReq
						if @@ERROR != 0 set @err = @@ERROR
						
					----update requisition hdr & dtl statues from VX_Reorder_Control....
						update VX_requisition_hdr
						set status = 30, ordrefid = @OrdRefId
						where requisitionno = @curReq
						if @@ERROR != 0 set @err = @@ERROR

						update VX_requisition_dtl
						set status = 30
						where requisitionno = @curReq
						if @@ERROR != 0 set @err = @@ERROR
					end			
				end
		end
		else if @inHouseOnly=1
			begin
				----this section only approves the orders and sends them through the system without EDI...				
				----insert order into audit log.....
						insert into VX_Submit_Audit_Log(RequisitionNo,PONumber,SubmitDate,ResponseDate,ProcessedFlag)
						select @curReq,@curPO,GETDATE(),GETDATE(),1
						if @@ERROR != 0 set @err = @@ERROR
					----------------------------------------------------------------------------------------
					----update VX_Reorder_Control status to Submitted for user's locked reqs....
						update VX_Reorder_Control
						set Status = 50
						where RequisitionNo = @curReq
						if @@ERROR != 0 set @err = @@ERROR
						
					----update requisition hdr & dtl statues from VX_Reorder_Control....
						update VX_requisition_hdr
						set status = 50, ordrefid = @OrdRefId, approvedby = @user, approveddate = @curDT
						where requisitionno = @curReq
						if @@ERROR != 0 set @err = @@ERROR

						update VX_requisition_dtl
						set status = 50,ConfirmedQty=RequestedQty, approvedby = @user, approveddate = @curDT
						where requisitionno = @curReq
						if @@ERROR != 0 set @err = @@ERROR
					
					----insert requisition into audit log for move to DIPS....
						insert into VX_requisition_audit_log
						select @curReq,@curPO,GETDATE(),null,0,null,@inHouseOnly						
						if @@ERROR != 0 set @err = @@ERROR
						
					----------check - insert - update any kit items on order......
					if exists(select rd.ItemCode from VX_Requisition_Dtl rd inner join VX_Vendor_Kits vk on rd.ItemCode=vk.ParentItem where rd.PONumber=@curPO)
						 begin
							----insert kit items....
							insert into VX_Requisition_Dtl (requisitionno,LineNum,itemcode,vendoritem,requestedqty,suggestedqty,confirmedqty,canceledqty,backorderqty,requestedby,requesteddate,cost,extcost,status,PONumber,allowbackorder,ShipFrom)
							select rd.RequisitionNo,row_number() over (partition by rd.lineNum order by rd.lineNum)+cast(MAX(rd.LineNum)as int),vk.KitItem,pm.ISBN,vk.KitQty,0,vk.KitQty*rd.RequestedQty,0,0,rd.RequestedBy,GETDATE(),pm.Cost,pm.Cost*(vk.KitQty*rd.RequestedQty),rd.Status,rd.PONumber,0,null
							from HPB_Prime..ProductMaster pm inner join VX_Vendor_Kits vk on pm.ItemCode=vk.KitItem
								inner join VX_Requisition_Dtl rd on vk.ParentItem=rd.ItemCode
							where rd.PONumber=@curPO and rd.ItemCode not in (select distinct KitItem from VX_Vendor_Kits where parentitem=rd.itemcode)
							group by rd.RequisitionNo,rd.LineNum,vk.KitItem,pm.ISBN,vk.KitQty,rd.RequestedBy,vk.KitQty*rd.RequestedQty,pm.Cost,pm.Cost*(vk.KitQty*rd.RequestedQty),rd.Status,rd.PONumber
						
							----update parent item....
							update rd
							set rd.CanceledQty=rd.RequestedQty,rd.ConfirmedQty=0,rd.Comments='KitUpdate'
							from VX_Requisition_Dtl rd inner join VX_Vendor_Kits vk on rd.ItemCode=vk.ParentItem
							where rd.PONumber=@curPO 
						 end
			end
		set @loop = @loop - 1
	end
	
drop table #reqTmp
----Commit or Rollback trans...........
set @rVal = @err
if @rVal=0
	begin
		Commit Transaction VX_ReqSubmit
		return @rVal
	end
else
	begin
		ROLLBACK  Transaction VX_ReqSubmit
		return @rVal
	end
	
END


GO


