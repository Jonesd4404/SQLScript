
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--------------------------------------------------------------Process BakerTaylor updates.......................................................
	
	----create and fill temp table with pending response updates......
	create table #response(rowid int identity(1,1), poNo char(6))

	insert into #response
		select distinct h.OrderResponseNumber
		from BakerTaylor..bulkorder_response_Header h
			inner join BakerTaylor.dbo.bulkorder_response_ItemDetail d
				on h.ResponseID = d.ResponseID
		where DocReferenceNumber = '282267'


	----loop thru and update each order with response....
	declare @loop int
	set @loop = (select MAX(rowID) from #response)

	while @loop > 0
	begin 
		declare @curPO char(6)
		select @curPO=poNo from #response where rowid=@loop
	
		----update requisition header and detail....
		update rd
			set	 rd.ConfirmedQty=isnull(id.QuantityShipping,0)
				,rd.CanceledQty=case when isnull(id.QuantityShipping,0)=0 and isnull(id.QuantityBackordered,0)=0 then rd.RequestedQty else case when isnull(id.QuantityCanceled,0)=0 and isnull(id.QuantityBackordered,0)=0 then rd.RequestedQty-isnull(id.QuantityShipping,0) else isnull(id.QuantityCanceled,0) end end
				,rd.BackOrderQty=isnull(id.QuantityBackordered,0)
				,rd.Status = case when cast(isnull(id.QuantityShipping,0)AS int)=0 and cast(isnull(id.QuantityCanceled,0)AS int)<>0 then 99
							when cast(isnull(id.QuantityShipping,0)AS int)=0 and cast(isnull(id.QuantityBackordered,0)AS int)=0 then 99
							when cast(isnull(id.QuantityBackordered,0)AS int)<>0 then 98
							else 40 end			
			,rd.ShipFrom=isnull(id.LocationShippingFrom,'')
			,rd.Comments=isnull(id.LineStatusDescription,'')
			,rd.ExtCost=isnull(id.QuantityShipping,0)*rd.Cost
		from VX_Requisition_Dtl rd inner join BakerTaylor..bulkorder_response_Header hd on rd.PONumber=hd.OrderResponseNumber
			inner join BakerTaylor..bulkorder_response_ItemDetail id on hd.ResponseID=id.ResponseID and id.ProductIdentifier = rd.VendorItem
		where rd.PONumber=@curPO and rd.RequestedQty <> 0
		/*replicate edi for copying code */

		----insert any backordered qty into backorderlog....
		insert into VX_BackOrder_Log
			select rh.VendorID,rh.LocationNo,rd.PONumber,rd.ItemCode,rd.BackOrderQty,GETDATE(),rd.Comments
			from VX_Requisition_Dtl rd inner join VX_Requisition_Hdr rh on rd.PONumber=rh.PONumber
			where rd.PONumber=@curPO and isnull(rd.BackOrderQty,0) <> 0
		
		----delete remaining items that were removed from the order.....
		delete from VX_Requisition_Dtl 
		where PONumber=@curPO and Status = 30 and RequestedQty = 0
		
		------check - insert - update any kit items on order......
		if exists(select rd.ItemCode from VX_Requisition_Dtl rd inner join VX_Vendor_Kits vk on rd.ItemCode=vk.ParentItem where rd.PONumber=@curPO)
			 begin
				----update any existing kit items on orders...
				update rd
					set rd.RequestedQty=rd.RequestedQty+isnull((select KitQty*RequestedQty from VX_Requisition_Dtl inner join VX_Vendor_Kits on ItemCode=ParentItem where RequisitionNo=rd.RequisitionNo and ItemCode=vk.ParentItem and KitItem=isnull(vk.KitItem,vk.ParentItem)),0),
						rd.ExtCost=rd.ExtCost+isnull((select KitQty*RequestedQty from VX_Requisition_Dtl inner join VX_Vendor_Kits on ItemCode=ParentItem where RequisitionNo=rd.RequisitionNo and ItemCode=vk.ParentItem and KitItem=isnull(vk.KitItem,vk.ParentItem))*pm.Cost,0),
						rd.ConfirmedQty=rd.ConfirmedQty+isnull((select KitQty*RequestedQty from VX_Requisition_Dtl inner join VX_Vendor_Kits on ItemCode=ParentItem where RequisitionNo=rd.RequisitionNo and ItemCode=vk.ParentItem and KitItem=isnull(vk.KitItem,vk.ParentItem)),0)
				from HPB_Prime..ProductMaster pm inner join VX_Vendor_Kits vk on pm.ItemCode=vk.KitItem
					inner join VX_Requisition_Dtl rd on vk.KitItem=rd.ItemCode
				where rd.PONumber=@curPO and vk.KitItem in (select ItemCode from VX_Requisition_Dtl where RequisitionNo=rd.RequisitionNo)
		
				----insert kit items....
				insert into VX_Requisition_Dtl (requisitionno,LineNum,itemcode,vendoritem,requestedqty,suggestedqty,confirmedqty,canceledqty,backorderqty,requestedby,requesteddate,cost,extcost,status,PONumber,allowbackorder,ShipFrom,Comments)
					select distinct rd.RequisitionNo,right(vk.KitItem,4),vk.KitItem,pm.ISBN,vk.KitQty,0,vk.KitQty*rd.RequestedQty,0,0,rd.RequestedBy,GETDATE(),pm.Cost,pm.Cost*(vk.KitQty*rd.RequestedQty),rd.Status,rd.PONumber,0,'VEND','AddKitItem'
					from HPB_Prime..ProductMaster pm inner join VX_Vendor_Kits vk on pm.ItemCode=vk.KitItem
						inner join VX_Requisition_Dtl rd on vk.ParentItem=rd.ItemCode
					where rd.PONumber=@curPO and rd.ItemCode not in (select distinct KitItem from VX_Vendor_Kits where parentitem=rd.itemcode) 
							and vk.KitItem not in (select ItemCode from VX_Requisition_Dtl where RequisitionNo=rd.RequisitionNo)
					group by rd.RequisitionNo,rd.LineNum,vk.KitItem,pm.ISBN,vk.KitQty,rd.RequestedBy,vk.KitQty*rd.RequestedQty,pm.Cost,pm.Cost*(vk.KitQty*rd.RequestedQty),rd.Status,rd.PONumber,right(rd.itemcode,4)
			
				----update parent item....
				update rd
					set rd.CanceledQty=rd.RequestedQty,rd.ConfirmedQty=0,rd.Status=99,rd.Comments='KitUpdate'
				from VX_Requisition_Dtl rd inner join VX_Vendor_Kits vk on rd.ItemCode=vk.ParentItem
				where rd.PONumber=@curPO 
			 end
		
		update rh
			set rh.Status=40, 
				rh.ReqQty=(select SUM(isnull(ConfirmedQty,0)) from VX_Requisition_Dtl where PONumber = @curPO),
				rh.ReqAmt=(select SUM(isnull(ExtCost,0)) from VX_Requisition_Dtl where PONumber = @curPO)
		from VX_Requisition_Hdr rh inner join BakerTaylor..bulkorder_response_Header hd on rh.PONumber=hd.OrderResponseNumber
			inner join BakerTaylor..bulkorder_response_ItemDetail id on hd.ResponseID=id.ResponseID
		where rh.PONumber=@curPO
			
		----update reorder control table and audit log....
		update VX_Reorder_Control
		set Status=40
		where PONumber=@curPO
		
		update VX_Submit_Audit_Log
		set ProcessedFlag=1,ResponseDate=GETDATE()
		where PONumber=@curPO
		
		set @loop = @loop - 1
	end
	
	
		