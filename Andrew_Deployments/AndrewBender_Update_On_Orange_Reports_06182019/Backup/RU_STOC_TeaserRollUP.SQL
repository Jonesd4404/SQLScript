USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[RU_STOC_TeaserRollup]    Script Date: 6/18/2019 8:05:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey Blalock>
-- Create date: <6/1/2012>
-- Description:	<Rollup all reorderable data for STOC application.....>
-- =============================================
CREATE PROCEDURE [dbo].[RU_STOC_TeaserRollup]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	----run PI check and fill with reorderable items if needed.................
	exec ReportsData..STOC_ProdInv_Failsafe
	/*****************************************************************************************************************************************************************
	***LOCATION FILTERING
	*****************************************************************************************************************************************************************/
		create table #locs(locationno char(5), locationname char(30), locationID char(10))
		begin
			insert #locs
			select locationno, DistrictCode, locationid --[name]
			from reportsdata..locations with(nolock)
			where retailstore = 'y' and isnumeric(locationno) = 1 and status = 'A' and CAST(locationno as int) between 1 and 200 
				or Status='A' and UserInt1=1 and locationno!='00888' 
			order by LocationNo
		end
	/*****************************************************************************************************************************************************************
	***GETTING  LIST OF REORDERABLE VENDORS --exclude Supplies from roll-up
	*****************************************************************************************************************************************************************/
		create table #rVendors(vendorID varchar(20), NextOrderDate datetime)
		begin
			insert #rVendors
			select distinct vendorid,UserDate1 from reportsdata..vendormaster with(nolock)
			where isnull(ltrim(rtrim(userchar30)),'') <> '' 
		end
	/*****************************************************************************************************************************************************************
	***GETTING  LIST OF REORDERABLE ITEMCODES WITH REPORT ITEMCODE FOR END GROUPING
	*****************************************************************************************************************************************************************/
		select distinct pmd.ItemCode,cast(isnull(dbo.RPTfn_GetHistItemCodes(pmd.itemcode),'')as varchar(100))[PreviousItems],case when isnull(pmd.ReportitemCode,'')='' then pmd.ItemCode else pmd.ReportItemCode end[ReportitemCode],case when pm.title = '' then pm.description else pm.title end [Title],
			CalcCost,pm.reorderable,pmd.reorderableitem,case when pm.PurchaseFromVendorID <> '' then pm.PurchaseFromVendorID else pm.VendorID end as [VendorID]
			,isnull((select SectionCode from ReportsData..sectionmaster_dipsmapping where DIPS_SectionCode=pm.SectionCode),pm.SectionCode)[sectioncode],case ltrim(rtrim(pm.ISBN)) when '' then substring(pmd.upc,1,13) else pm.isbn end [isbn],ISNULL(pmrc.ConversionQty,0)[CaseQty],pm.Cost,pm.Price
		into #curreorderables
		from reportsdata..productmasterdist pmd with(nolock) inner join reportsdata..productmaster pm with(nolock) on pm.itemcode = pmd.itemcode 
			and case when PurchaseFromVendorID <> '' then PurchaseFromVendorID else VendorID end in (select distinct vendorid from #rVendors)
			left outer join ReportsData..ProductMasterReorderConversion pmrc on pmd.ItemCode=pmrc.ItemCode
		where pm.reorderable = 'Y' 

	----get UPC/ISBN items..................................................................
		--select pm.ItemCode,pmd.ReportItemCode
		--into #upcItems
		--from ReportsData..ProductMaster pm with (nolock) inner join ReportsData..ProductMasterDist pmd with (nolock)
		--	on pm.ItemCode=pmd.ItemCode
		--where pm.ItemCode in (select distinct right('00000000000000000000' + replace(ItemAlias,'UPC',''),20) from ReportsData..ProductMaster where ItemAlias like 'UPC%')
		
		select distinct right('00000000000000000000' + replace(ItemAlias,'UPC',''),20)[ItemCode], cast('00000000000000000000' as char(20))[ReportItemCode]
		into #upcItems
		from ReportsData..ProductMaster with (nolock) where ItemAlias like 'UPC%'
		
		update u
		set reportitemcode = pmd.ReportItemCode
		from ReportsData..ProductMaster pm with (nolock) inner join ReportsData..ProductMasterDist pmd with (nolock) on pm.ItemCode=pmd.ItemCode
			inner join #upcItems u on u.itemcode=pm.itemcode
			
		create table #reorderables(ItemCode varchar(20),PreviousItems varchar(100),ReportItemCode varchar(20),Title varchar(70),CalcCost money,Reorderable char(1),ReorderableItem char(1),VendorID varchar(20),SectionCode varchar(20),ISBN varchar(15),CaseQty int,Cost money,Price money)
		create clustered index [IDX_REO] ON #reorderables ([ItemCode], [ReportItemCode])
	--***adding in all items that are not reorderable but have the reportitemcode of any of the current reorderables excluding UPC items....
		insert into #reorderables
		select distinct ItemCode,max(PreviousItems)[PreviousItems],ReportItemCode,Title,CalcCost,Reorderable,ReorderableItem,VendorID,SectionCode,ISBN,CaseQty,Cost,Price
		from (select distinct pmd.ItemCode,r.PreviousItems,case when isnull(pmd.ReportitemCode,'')='' then pmd.ItemCode else pmd.ReportItemCode end[ReportitemCode],r.Title,pmd.CalcCost,pm.reorderable,pmd.reorderableitem
				,r.vendorid,r.sectioncode,r.isbn,r.CaseQty [CaseQty],r.Cost,r.Price
			from reportsdata..productmasterdist pmd with(nolock) inner join reportsdata..productmaster pm with(nolock) on pm.itemcode = pmd.itemcode  
				inner join #curreorderables r on r.reportitemcode = pmd.reportitemcode
			where pmd.ItemCode not in (select distinct ItemCode from #upcItems) 
			union
			select distinct itemcode,PreviousItems,reportitemcode,title,calccost,reorderable,reorderableitem,VendorID,SectionCode,ISBN,CaseQty,Cost,Price from #curreorderables) r
		group by ItemCode,ReportItemCode,Title,CalcCost,Reorderable,ReorderableItem,VendorID,SectionCode,ISBN,CaseQty,Cost,Price
		
	----adding in UPC items excluded from previous step....
		insert into #reorderables
		select distinct pmd.ItemCode,r.PreviousItems,case when isnull(pmd.ReportitemCode,'')='' then pmd.ItemCode else pmd.ReportItemCode end[ReportitemCode],r.Title,pmd.CalcCost,pm.reorderable,pmd.reorderableitem
				,r.vendorid,r.sectioncode,r.isbn,r.CaseQty [CaseQty],r.Cost,r.Price
		from reportsdata..productmasterdist pmd with(nolock) inner join reportsdata..productmaster pm with(nolock) on pm.itemcode = pmd.itemcode  
			inner join #curreorderables r on r.reportitemcode = pmd.reportitemcode
		where pmd.ItemCode in (select distinct ItemCode from #upcItems)

	------flip any items back that have been reactivated under an older itemcode......
		update r 
		set r.ReportItemCode = (select top 1 ItemCode from #curreorderables where ReportItemCode=r.ReportItemCode order by ItemCode desc)
		from #reorderables r
		where r.ReportItemCode in (select distinct ReportItemCode from #curreorderables where ItemCode<>ReportItemCode and ReportitemCode<>'')
		
	----Get last store/item/req information for sales & transfer date ranges.......
		select max(rh.RequisitionNo)[ReqNo],rh.LocationNo,rd.itemcode,cr.ReportItemCode[ReorderItemCode],max(rh.DateApprovedDisapproved)[LastOrderDate],0 [LastQty]
		into #lastStoreItemReq
		from reportsdata..requisitiondetail rd with (nolock) inner join reportsdata..requisitionheader rh with (nolock) on rd.requisitionno = rh.requisitionno
			inner join #reorderables cr on rd.itemcode = cr.itemcode
		where rh.requestby <> 'VOID' and rh.DateApprovedDisapproved is not null and rh.POnumber is not null 
			and rh.vendorid in (select distinct vendorid from #rVendors union select 'IDTEXASBOO') and rh.locationno in (select distinct locationno from #locs)
		group by rh.LocationNo,rd.itemcode,cr.ReportItemCode
		
	----Update last ordered qty for item/store...........................................................................................
		update req
		set LastQty = isnull(rd.ApprovedQtyToOrder,0)
		from reportsdata..requisitiondetail rd with(nolock) inner join ReportsData..RequisitionHeader rh with(nolock) on rd.RequisitionNo = rh.RequisitionNo
			inner join #lastStoreItemReq req on req.reqno = rd.requisitionno and req.itemcode = rd.itemcode and req.locationno = rh.locationno

	--initial dist dates...........................................................................................
		select  r.reportitemcode,r.itemcode,min(sd.datereceived) [InitialStoreDate],l.locationno,sum(0)[InitialQty]
		into #DistDate
		from #reorderables r inner join reportsdata..shipmentdetail sd with (nolock) on sd.itemcode = r.itemcode
			inner join #locs l with (nolock) on l.locationno = sd.locationno
		group by r.reportitemcode, r.itemcode, l.locationno

	--initial qty update....................................................
		update d
		set InitialQty = isnull(sd.qty,0)
		from #DistDate d inner join reportsdata..shipmentdetail sd with (nolock) on d.itemcode = sd.itemcode
			and d.locationno = sd.locationno and d.InitialStoreDate = sd.datereceived

	/*****************************************************************************************************************************************************************
	***INSERTING ADDITIONAL SALES FROM SEARCH & SHIP / ONLINE SALES........
	*****************************************************************************************************************************************************************/
		create table #AddtSales(Store varchar(6),DistrictCode varchar(30),ItemCode varchar(20),ReportItemCode varchar(20),VendorID varchar(20),ISBN varchar(15),SectionCode varchar(20),Sales numeric(12,0),SalesDate datetime)
	----Search & Ship sales..........
		insert into #AddtSales
		select lc.locationno,lc.locationname,r.Itemcode,r.ReportitemCode,r.VendorID,r.ISBN,r.SectionCode,isnull(sum(scd.Quantity),0)[SoldQty],scd.datesold
		from ReportsData..Sales_CrossChannel_Distribution scd with(nolock) inner join #reorderables r on r.itemcode = scd.itemcode 
			inner join #locs lc on lc.locationid = scd.locationid
		group by lc.locationno,lc.locationname,r.Itemcode,r.ReportitemCode,r.VendorID,r.ISBN,r.SectionCode,scd.datesold

	----Online market place sales.........
		insert into #AddtSales
		select lc.locationno,lc.locationname,r.Itemcode,r.ReportitemCode,r.VendorID,r.ISBN,r.SectionCode,isnull(sum(sod.Quantity),0)[SoldQty],sod.datesold
		from ReportsData..Sales_OnlineMarketPlaces_Distribution sod with(nolock) inner join #reorderables r on r.itemcode = sod.itemcode 
			inner join #locs lc on lc.locationid = sod.locationid
		group by lc.locationno,lc.locationname,r.Itemcode,r.ReportitemCode,r.VendorID,r.ISBN,r.SectionCode,sod.datesold

	/*****************************************************************************************************************************************************************
	***Get all the sales data in one call......
	*****************************************************************************************************************************************************************/
		select l.locationno,sih.itemcode[itemcode],r.VendorID,r.ISBN,isnull(sum(case sih.isreturn when 'y' then -(sih.quantity) else sih.quantity end),0)[sold]
			,cast(sih.businessdate as date)[saledate],case when max(sih.businessdate) < MAX(a.SalesDate) then  MAX(a.SalesDate) else max(sih.businessdate) end [lastsaledate]
			,sum(case when sih.unitprice > sih.registerprice and isreturn = 'n' then 1 else 0 end)[markdowns]
		into #allsales
		from rhpb_historical..salesitemhistory sih with(nolock) inner join #locs l on l.locationid=sih.locationid
			inner join #reorderables r on r.itemcode=sih.itemcode left outer join 
			(select Store,ItemCode,MAX(SalesDate)[SalesDate] from #AddtSales group by Store,ItemCode)a on a.ItemCode=r.itemcode and a.Store=l.locationno
		group by l.locationno,sih.itemcode,r.VendorID,r.ISBN,cast(sih.businessdate as date)
		having isnull(sum(case sih.isreturn when 'y' then -(sih.quantity) else sih.quantity end),0)> 0

		insert into #allsales
		select a.Store,a.ItemCode,a.VendorID,a.ISBN,a.Sales,a.SalesDate,
			(select max(lastsaledate) from #allsales where ItemCode=a.ItemCode and locationno=a.Store),0
		from #AddtSales a 
		
	/*****************************************************************************************************************************************************************
	***Put since last order sales into sold temp......
	*****************************************************************************************************************************************************************/
		select a.locationno,a.itemcode[itemcode],r.VendorID,r.ISBN,isnull(sum(a.sold),0)[numsold],max(a.lastsaledate)[lastsaledate],sum(a.markdowns)[markdowns]
		into #sold
		from #allsales a inner join #reorderables r on r.itemcode=a.itemcode
		where a.saledate >= (select cast(max(ls.lastorderdate)as date) from #lastStoreItemReq ls where ls.ReorderItemCode=r.ReportitemCode and ls.locationno=a.locationno) 
		group by a.locationno,a.itemcode,r.VendorID,r.ISBN 
		
		----add in sales for initial dist items that have not yet been reordered...........................................................
		insert into #sold
		select a.locationno,a.itemcode[itemcode],r.VendorID,r.isbn,isnull(sum(a.sold),0)[numsold],max(a.lastsaledate)[lastsaledate],sum(a.markdowns)[markdowns]
		from #allsales a inner join #reorderables r on r.itemcode=a.itemcode
		where a.saledate >= (select cast(max(dd.InitialStoreDate)as date) from #DistDate dd where dd.ReportitemCode=r.ReportItemCode and dd.locationno=a.locationno	
								and dd.ReportitemCode not in(select distinct ReorderItemCode from #lastStoreItemReq ls where ls.ReorderItemCode=r.ReportitemCode and ls.locationno=a.locationno))
		group by a.locationno,a.itemcode,r.VendorID,r.isbn
				
	/*****************************************************************************************************************************************************************
	***Put total sales into totalsold temp......
	*****************************************************************************************************************************************************************/
		select a.locationno,a.itemcode[itemcode],r.VendorID,r.ISBN,isnull(sum(a.sold),0)[totalsold],max(a.lastsaledate)[lastsaledate],
		isnull((select isnull(sum(case sih.isreturn when 'y' then -(sih.quantity) else sih.quantity end),0)[sold]
			 from rHPB_Historical..SalesItemHistory sih inner join ReportsData..Locations l on sih.LocationID=l.LocationID
			 where sih.ItemCode=a.ItemCode and l.LocationNo=a.locationno and sih.BusinessDate>DATEADD(week,-4,getdate())),0)[4WeekSales]
		into #totalsold
		from #allsales a inner join #reorderables r on r.itemcode=a.itemcode
		group by a.locationno,a.itemcode,r.VendorID,r.ISBN
		having ISNULL(sum(a.sold),0) > 0

	/*****************************************************************************************************************************************************************
	***TRANSFERRED INFORMATION --join lastReq table to get vendor/store startdate.....
	*****************************************************************************************************************************************************************/
		select lc.locationno,sum(isnull(it.transferqty,0))[qtytransferred],r.ReportItemCode[itemcode],it.fromlocationno
		into #qtytransferred
		from reportsdata..inventorytransfers it with(nolock) inner join #reorderables r on r.itemcode = it.itemcode
			inner join #locs lc on lc.locationno = it.fromlocationno
		where it.datetransferred >= (select max(ls.lastorderdate) from #lastStoreItemReq ls where ls.ReorderItemCode = r.ReportItemCode and ls.locationno = lc.locationno) 
		group by lc.locationno,r.ReportItemCode,it.fromlocationno
		
		----add in transfers for initial dist items that have not yet been reordered...........................................................
		insert into #qtytransferred
		select lc.locationno,sum(isnull(it.transferqty,0))[qtytransferred],r.ReportItemCode[itemcode],it.fromlocationno
		from reportsdata..inventorytransfers it with(nolock) inner join #reorderables r on r.itemcode = it.itemcode
			inner join #locs lc on lc.locationno = it.fromlocationno
		where it.datetransferred >= (select cast(max(dd.InitialStoreDate)as date) from #DistDate dd where dd.ReportitemCode=r.ReportItemCode and dd.locationno=lc.locationno
								and dd.ReportitemCode not in(select distinct ReorderItemCode from #lastStoreItemReq ls where ls.ReorderItemCode=r.ReportitemCode and ls.locationno=lc.locationno))
		group by lc.locationno,r.ReportItemCode,it.fromlocationno

	/*****************************************************************************************************************************************************************
	***SHIPPED since last order INFORMATION --join lastReq table to get vendor/store startdate.....
	*****************************************************************************************************************************************************************/
		select sd.locationno,sd.itemcode, SUM(isnull(sd.qty,0))[ShipQty]
		into #shipQty
		from reportsdata..shipmentdetail sd with(nolock) inner join reportsdata..shipmentheader sh with(nolock) on sd.transferid = sh.transferid 
				inner join #locs lc on lc.locationno = sd.locationno inner join #reorderables r on r.itemcode = sd.itemcode
				inner join #lastStoreItemReq ls on ls.itemcode = sd.itemcode and ls.locationno = sd.locationno
		where sh.FromLocationNo IN ('00944') and sh.datetransferred >= isnull(ls.lastorderdate,dateadd(dd,-1,getdate())) AND sh.datetransferred <= getdate()
		group by sd.locationno,sd.itemcode
		
		----add in shipped for initial dist items that have not yet been reordered...........................................................
		insert into #shipQty
		select sd.locationno,sd.itemcode, SUM(isnull(sd.qty,0))[ShipQty]
		from reportsdata..shipmentdetail sd with(nolock) inner join reportsdata..shipmentheader sh with(nolock) on sd.transferid = sh.transferid 
				inner join #locs lc on lc.locationno = sd.locationno inner join #reorderables r on r.itemcode = sd.itemcode
				inner join #lastStoreItemReq ls on ls.itemcode = sd.itemcode and ls.locationno = sd.locationno
		where sh.FromLocationNo IN ('00944') and sh.datetransferred >= (select cast(max(dd.InitialStoreDate)as date) from #DistDate dd where dd.ReportitemCode=r.ReportItemCode and dd.locationno=lc.locationno
								and dd.ReportitemCode not in(select distinct ReorderItemCode from #lastStoreItemReq ls where ls.ReorderItemCode=r.ReportitemCode and ls.locationno=lc.locationno))
		group by sd.locationno,sd.itemcode
		
	/*****************************************************************************************************************************************************************
	***RECEIVED INFORMATION
	*****************************************************************************************************************************************************************/
		--New Store Receiving tables....
		select sh.LocationNo,sd.ItemCode,sh.ShipmentNo[transferid],SUM(sd.qty)[qtyreceived],sh.ShipmentType
		into #received
		from ReportsData..SR_Header sh with (nolock) inner join ReportsData..SR_Detail sd with (nolock)
			on sh.BatchID = sd.BatchID inner join #reorderables r on r.itemcode = sd.ItemCode inner join #locs lc on sh.locationno = lc.locationno
		where sh.ShipmentType in ('W','R','S')
		group by sh.LocationNo,sd.ItemCode,sh.ShipmentNo,sh.ShipmentType
		having SUM(sd.Qty) > 0

		--New Store Receiving archive tables from old SR2 table.....
		insert into #received
		select sh.LocationNo,sd.ItemCode,sh.ShipmentNo[transferid],SUM(sd.qty)[qtyreceived],sh.ShipmentType
		from ReportsData..SR_Header_Historical sh with (nolock) inner join ReportsData..SR_Detail_Historical sd with (nolock)
			on sh.BatchID = sd.BatchID inner join #reorderables r on r.itemcode = sd.ItemCode inner join #locs lc on sh.LocationNo = lc.locationno
		where sh.ShipmentType in ('W','R','S') and sh.ShipmentNo not in (select distinct transferid from #received)
		group by sh.LocationNo,sd.ItemCode,sh.ShipmentNo,sh.ShipmentType
		having SUM(sd.Qty) > 0

		--pending quantities................................................................................................
		select sd.locationno,sd.itemcode,sd.transferid,sum(isnull(sd.qty,0))[qtypending],MAX(isnull(sd.datereceived,getdate()))[TransDate],r.VendorID
		into #pending
		from reportsdata..shipmentdetail sd with(nolock) inner join reportsdata..shipmentheader sh with(nolock) on sh.transferid = sd.transferid
			inner join (select distinct itemcode, VendorID from #reorderables) r on r.itemcode = sd.itemcode inner join #locs lc on sd.locationno = lc.locationno
		where sh.FromLocationNo = '00944' and sh.Receiver is null and sh.TransferID not in (select distinct transferid from #received)
			and right('0000'+sd.PONumber,10) not in (select distinct transferid from #received where ShipmentType='R')
		group by sd.locationno,sd.itemcode,sd.transferid,r.VendorID
		having SUM(sd.Qty) > 0
		--insert pending orders that have been placed by stores but not yet shipped by CDC....
		insert into #pending
		select rh.locationno,rd.itemcode,rh.PONumber,sum(isnull(rd.ApprovedQtyToOrder,0))[qtypending],MAX(o.PODate)[TransDate],r.VendorID
		from ReportsData..RequisitionHeader rh with(nolock) inner join ReportsData..RequisitionDetail rd on rh.RequisitionNo=rd.RequisitionNo
			inner join (select distinct itemcode, VendorID from #reorderables) r on r.itemcode = rd.itemcode inner join #locs lc on rh.locationno = lc.locationno
			inner join (select oh.PONumber,od.ItemCode,oh.PODate,oh.POType  from ReportsData..OrderHeader oh with(nolock) inner join ReportsData..OrderDetail od on oh.PONumber=od.PONumber
						where oh.VendorID<>'WHPBSUPPLY' and oh.POType in ('C','D') and oh.PODate > DATEADD(year,-1,getdate())) o on rh.PONumber=o.PONumber and rd.ItemCode=o.ItemCode
		where rd.Approved=1 and rh.VendorID<>'WHPBSUPPLY'  
			and rh.PONumber not in (select distinct sd.PONumber
							from reportsdata..shipmentdetail sd with(nolock) inner join reportsdata..shipmentheader sh with(nolock) on sh.transferid = sd.transferid
							where sd.PONumber=rh.PONumber)
			and right('0000'+rh.PONumber,10) not in (select distinct transferid from #received)
			and right('0000'+rh.PONumber,10) not in (select distinct transferid from #received where ShipmentType='R') 
			and right('0000'+rh.PONumber,10) not in (select distinct TransferID from #pending)
		group by rh.locationno,rd.itemcode,rh.PONumber,r.VendorID
		having SUM(rd.ApprovedQtyToOrder) > 0

		--Older received records not in SR....
		insert into #received
		select lc.locationno,sd.itemcode,sd.transferid,sum(sd.qty)[qtyreceived],'' ShipmentType
		from reportsdata..shipmentdetail sd with(nolock)
			inner join reportsdata..shipmentheader sh with(nolock) on sh.transferid = sd.transferid
			inner join #reorderables r on r.itemcode = sd.itemcode inner join #locs lc on sh.tolocationno = lc.locationno
		where sd.TransferID not in (select distinct TransferID from #received)
			and right('0000'+sd.PONumber,10) not in (select distinct transferid from #received where ShipmentType='R')
			and sd.TransferID not in (select distinct TransferID from #pending)
			and sd.TransferID in (select distinct TransferID from ReportsData..ShipmentHeader s with(nolock) inner join ReportsData..Locations l with(nolock) on s.FromLocationID = l.LocationID
							where l.LocationType in ('R','C'))
		group by lc.locationno,sd.itemcode,sd.transferid
		having SUM(sd.Qty) > 0	

	--get totals............................................
		select locationno,itemcode,sum(qtyreceived)[qtyreceived]
		into #totalrcvd
		from #received
		group by locationno,itemcode

	--delete pending quantities that are older than 6 months....
		delete from #pending where transdate <= DATEADD(month,-4,getdate()) or itemcode in (select distinct ItemCode from #upcItems)
		delete from #pending where VendorID='IDB&TDISTR' and transdate <= DATEADD(DAY,-30,getdate()) 
		--update pending table to consolidate and delete any duplicates...............................
		----update #pending set TransferID='',TransDate=GETDATE() 
		delete p1
		from #pending p1 
			join (select p.ItemCode,p.LocationNo,p.TransferID from #pending p
				group by p.ItemCode,p.LocationNo,p.TransferID 
				having COUNT(*)>1) p2 on p1.itemcode=p2.itemcode and p1.locationno=p2.locationno and p1.TransferID=p2.TransferID
	
		select LocationNo,ItemCode,sum(qtypending)[qtypending]
		into #totalpending
		from #pending
		group by LocationNo,ItemCode
	
	--reorder count.......................................................................................................
		select lc.locationno,r.itemcode,r.reportitemcode,count(*) [ReorderCount]
		into #reordercount
		from #reorderables r inner join reportsdata..requisitiondetail rd with(nolock) on r.itemcode = rd.itemcode
			inner join reportsdata..requisitionheader rh with(nolock) on rh.requisitionno = rd.requisitionno
			inner join #locs lc on lc.locationno = rh.locationno
		group by lc.locationno,r.itemcode,r.reportitemcode

	/*****************************************************************************************************************************************************************
	PUTTING THE GATHERED DATA TOGETHER
	*****************************************************************************************************************************************************************/
		select lc.locationno, lc.locationname [District],lc.locationid,sum(isnull(it.qtytransferred,0))[TransferredOut],r.title [Title],right(r.itemcode,8)[ItemCode]
			,right(r.reportitemcode,8)[ReorderItemCode],r.PreviousItems,r.VendorID,r.SectionCode,count(r.itemcode)[ItemCodeCount],pm.Cost,pm.Price
			,isnull(isnull(min(dd.InitialStoreDate),(select min(InitialStoreDate) from #distdate where ReportItemCode=r.ItemCode and locationno=lc.locationno)),pm.createdate) [InitialStoreDate]
			,sum(isnull(dd.InitialQty,0))[InitialQty],sum(isnull(s.numsold,0))[SoldInPeriod],sum(isnull(ts.TotalSold,0))[TotalSold],sum(isnull(pv.quantityonhand,0))[QtyOnHand]
			,isnull(max(s.lastsaledate),max(ts.lastsaledate))[LastSaleDate],sum(isnull(rc.qtyreceived,0))[TotalRcvd],max(lq.LastOrderDate)[LastReOrderDate]
			,sum(isnull(pend.qtypending,0))[Pending],0 [SuggestedOrderQty],sum(isnull(s.markdowns,0))[Markdowns]
			,max(isnull(roc.reordercount,0))[RO_CNT],sum(0)[LastQty],sum(0)[ShipQty],r.isbn
			,MAX(ISNULL(v.NextOrderDate,getdate()))[NextOrderDate],ISNULL(r.CaseQty,0)[CaseQty],
			case when isnull((select reportitemcode from #upcItems where ReportItemCode=r.ReportItemCode),'')<>'' then 'U' else '' end[itemType],ISNULL(SUM(ts.[4WeekSales]),0)[4WeekSales]
		into #totals
		from #locs lc cross join #reorderables r left join reportsdata..productmaster pm with(nolock) on pm.itemcode = r.itemcode
			left outer join #sold s on s.itemcode = r.itemcode and s.locationno = lc.locationno
			left outer join reportsdata..productinventory pv with(nolock) on pv.itemcode = r.itemcode and pv.locationno = lc.locationno
			left outer join #totalrcvd rc on rc.itemcode = r.itemcode and rc.locationno = lc.locationno
			left outer join #totalsold ts on ts.itemcode = r.itemcode and ts.locationno = lc.locationno
			left outer join #qtytransferred it on it.itemcode = r.itemcode and it.locationno = lc.locationno
			left outer join #totalpending pend on pend.itemcode = r.itemcode and pend.locationno = lc.locationno
			left outer join #reordercount roc on roc.itemcode = r.itemcode and roc.locationno = lc.locationno
			left outer join #lastStoreItemReq lq on lq.itemcode = r.itemcode and lq.locationno = lc.locationno
			left outer join #DistDate dd on dd.itemcode = r.itemcode and dd.locationno = lc.locationno
			left outer join #shipQty sq on sq.itemcode = r.itemcode and sq.locationno = lc.locationno
			inner join #rVendors v on r.VendorID = v.vendorID
		group by lc.locationno, lc.locationname,lc.locationid,r.itemcode,r.reportitemcode,r.title
			,pm.Cost,pm.price,pm.createdate,r.isbn,r.VendorID,r.SectionCode,r.PreviousItems,ISNULL(r.CaseQty,0)
	
	drop table #sold
	drop table #totalrcvd
	drop table #totalsold
	drop table #qtytransferred
	drop table #totalpending
	drop table #reordercount
	drop table #DistDate		
	drop table #received
	drop table #AddtSales		
	/*****************************************************************************************************************************************************************
	XREFERENCED BY ISBN!!!!!!! 
	*****************************************************************************************************************************************************************/
		select distinct locationno,isbn,sum(qtyonhand)[qty],max(ReorderItemCode)[itemcode],VendorID
		into #locxref 
		from #totals 
		where ltrim(rtrim(isbn))<>'' and itemcode is not null 
		group by locationno,isbn,VendorID
	----get distinct location/isbn for total sales.....
		select distinct locationno,isbn
		into #chkXref
		from #totals
		group by locationno,ISBN
	----Creating the joining table with all but the quantity--------------------------------------------------------
		select distinct lc.locationno,case ltrim(rtrim(pm.ISBN)) when '' then substring(pd.upc,1,13) else pm.isbn end [isbn],sum(isnull(pv.quantityonhand, 0))[qty]
		into #totalxref
		from reportsdata..productmaster pm with(nolock) inner join reportsdata..productmasterdist pd with(nolock) on pd.itemcode = pm.itemcode
			left outer join reportsdata..productinventory pv with(nolock) on pv.itemcode = pm.itemcode inner join #locs lc on lc.locationno = pv.locationno
		where case ltrim(rtrim(pm.ISBN)) when '' then substring(pd.upc,1,13) else pm.isbn end in (select distinct isbn from #locxref)
			and case when isnull(pd.ReportitemCode,'')='' then pd.ItemCode else pd.ReportItemCode end not in (select distinct isnull(RIGHT('00000000000000000000'+ltrim(ItemCode),20),'') from #locxref)
		group by lc.locationno,pm.isbn,pd.upc
		--having sum(isnull(pv.quantityonhand, 0)) > 0
	----Get other vendors xref-------------------------------------------------------------------------------------
		select l1.locationno,l1.ISBN,isnull(SUM(l2.qty),0)[qty],l1.VendorID,l1.itemcode
		into #vendxref
		from #locxref l1 left outer join #locxref l2 on l1.locationno=l2.locationno and l1.ISBN=l2.ISBN and l1.VendorID<>l2.VendorID
		group by l1.locationno,l1.ISBN,l1.VendorID,l1.itemcode	
	----Xref is complete--------------------------------------------------------------------------------------------
		select lx.locationno,lx.itemcode,lx.isbn,isnull(tx.qty,0)+isnull(r.qty,0)[xrefqty] 
		into #xref
		from #locxref lx left outer join #totalxref tx on lx.isbn = tx.isbn and lx.locationno = tx.locationno
			left join #vendxref r on lx.ISBN=r.ISBN and lx.locationno=r.locationno and lx.itemcode=r.itemcode
		--where isnull(tx.qty,0)+isnull(r.qty,0) > 0
		
	----clean up blank ISBN/UPC values
		delete from #xref where LTRIM(RTRIM(isbn))=''

	----delete out non-supply reorder locations.....
		delete from #totals where VendorID!='WHPBSUPPLY' and LocationNo in (select LocationNo from reportsdata..Locations where UserInt1=1) 
		
		create table #itemtotals (LocationNo char(5),District varchar(30),LocationID char(10),Title varchar(70),ReorderItemCode varchar(20),PreviousItems varchar(100),
						VendorID varchar(20),SectionCode varchar(20),ItemCodeCount int,Cost money,Price money,InitialStoreDate date,InitialQty int,
						SoldInPeriod int,TotalSold int,QtyOnHand int,TransferredOut int,LastSaleDate date,TotalRcvd int,LastReorderDate date,Pending int,Markdowns int,
						RO_CNT int, ISBN varchar(15),XRefQty int,NextOrderDate date,CaseQty int,ItemType varchar(6),[4WeekSales] int)
		create  clustered  index [IDX_ISBN] ON #itemtotals ([ISBN], [LocationNo])
	----group up all the totals to get to only current items.....
		insert into #itemtotals
		select t.locationno,t.district,t.locationid,t.title [Title],t.reorderitemcode,max(t.PreviousItems)[PreviousItems],
			t.vendorid,t.SectionCode,sum(t.itemcodecount)[itemcodecount],max(isnull(c.cost,0))[cost],max(isnull(c.price,0))[price],min(t.initialstoredate)[initialstoredate],sum(t.initialqty)[initialqty],
			sum(t.soldinperiod)[soldinperiod],sum(t.totalsold)[totalsold],sum(t.qtyonhand)[qtyonhand],sum(t.transferredout)[transferredout],
			max(t.lastsaledate)[lastsaledate],sum(t.totalrcvd)[totalrcvd],max(t.lastreorderdate)[lastreorderdate],sum(t.pending)[pending],
			sum(t.markdowns)[markdowns],sum(t.RO_CNT)[RO_CNT],max(t.isbn)[ISBN],sum(isnull(xr.xrefqty,0))[xrefqty],max(t.NextOrderDate)[NextOrderDate],max(t.CaseQty)[CaseQty],t.itemType,ISNULL(SUM(t.[4WeekSales]),0)[4WeekSales]
		from #totals t left outer join #xref xr on right('00000000000000'+xr.itemcode,20) = right('00000000000000'+t.ReorderItemCode,20) and xr.locationno = t.locationno
			left outer join #curreorderables c on c.itemcode = right('00000000000000'+t.itemcode,20)
		group by t.locationno,t.district,t.locationid,t.title,t.reorderitemcode,t.vendorid,t.SectionCode,t.itemType
	
	----insert pending Xref quantity ........
		select v.locationno,v.ISBN,v.VendorID,v.itemcode,p.qtypending [qtypendingXref],t.VendorID [VendorIDXref] 
		into #PendingXref
		from #itemtotals t inner join #pending p on t.LocationNo=p.LocationNo and RIGHT('00000000000000000000'+t.ReorderItemCode,20)=p.ItemCode
			left outer join #vendxref v on t.LocationNo=v.locationno and t.ISBN=v.ISBN
		where t.VendorID<>v.VendorID and v.ISBN<>'' --and v.qty>0
		order by v.locationno,v.ISBN
		
	----insert xref sales quantity .........
		select t.LocationNo,t.ReorderItemCode,t1.ISBN,sum(t1.sold)[sold]
		into #salesXref
		from #itemtotals t inner join #allsales t1 on t.ISBN=t1.ISBN and t.LocationNo=t1.locationno
		where ltrim(rtrim(isnull(t.ISBN,'')))<>'' and right('00000000000000000000'+t.ReorderItemCode,20)<>t1.itemcode and t.VendorID<>t1.VendorID and t1.LastSaleDate>isnull(t.LastReorderDate,t.InitialStoreDate)
		group by t.LocationNo,t.ReorderItemCode,t1.ISBN
		order by t.LocationNo,t.ReorderItemCode,t1.ISBN	

	----insert all sales by ISBN
		select x.LocationNo,x.ISBN,isnull(sum(sih.Quantity),0)[ISBNsold]
		into #ISBNsales
		from #chkXref x inner join #locs l on x.locationno=l.locationno
			inner join (select distinct pm.ItemCode,pm.ISBN,pmd.UPC from ReportsData..ProductMaster pm inner join ReportsData..ProductMasterDist pmd on pm.ItemCode=pmd.ItemCode
				where case ltrim(rtrim(pm.ISBN)) when '' then substring(pmd.upc,1,13) else pm.isbn end in (select distinct ISBN from #locxref)) pm on pm.ISBN=x.isbn
			inner join rHPB_Historical..SalesItemHistory sih on l.LocationID=sih.LocationID and pm.ItemCode=sih.ItemCode
		where ltrim(rtrim(isnull(x.ISBN,'')))<>'' 
		group by x.LocationNo,x.ISBN
		order by x.LocationNo,x.ISBN
	/*****************************************************************************************************************************************************************
	***Clear Roll-up table out
	*****************************************************************************************************************************************************************/
		truncate table reportsdata..TeaserRollUp
	----/*****************************************************************************************************************************************************************
	----INSERT FINAL RESULTS INTO TEASERROLLUP TABLE
	----*****************************************************************************************************************************************************************/
		insert into reportsdata..TeaserRollUp
		select t.locationno,t.district,t.locationid,t.title,''[itemcode],t.reorderitemcode,t.PreviousItems,t.vendorid,t.SectionCode,t.itemcodecount,
			t.cost,t.price,t.initialstoredate,t.initialqty,t.soldinperiod,t.totalsold,t.qtyonhand,t.transferredout,t.lastsaledate,t.totalrcvd,isnull(t.lastreorderdate,t.InitialStoreDate)[lastreorderdate],
			t.pending,0 [suggestedorderqty],t.markdowns,t.RO_CNT,sum(isnull(lq.lastqty,0))[lastqty],sum(isnull(sq.shipqty,0))[shipqty],t.isbn,t.xrefqty,t.NextOrderDate,t.CaseQty
			,cast(case when isnull(datediff(wk,min(t.InitialStoreDate),max(t.lastsaledate)),0)=0 then 0 else sum(isnull(t.TotalSold,0))/cast(isnull(datediff(wk,min(t.InitialStoreDate),max(t.lastsaledate)),1)as decimal(8,4)) end as decimal(8,4)) [RateOfSale]
			,isnull(cast(((convert(float,sum(isnull(t.totalsold,0)))/(convert(float,case when sum(isnull(t.totalrcvd,0)) = 0 then case when sum(isnull(t.totalsold,0)) = 0 then 1 else sum(isnull(t.totalsold,1)) end else sum(isnull(t.totalrcvd,1)) end ) + convert(float,sum(isnull(t.pending,0)))))*100) as int),0)[PercentSold] 
			,isnull(sr.rank,'NA / NA / NA / NA') [SalesRank],isnull(sip.SIPSQOH,0)[SIPsQOH],ISNULL(px.qtypendingXref,0)[PendXref],ISNULL(sx.sold,0)[SoldXref],isnull(isx.ISBNSold,0)[ISBNSold],sum(ISNULL(soh.SectionQty,0))[SectionQty],cast(ISNULL(cast(SUM(t.[4WeekSales]) as decimal(8,4)),0)/cast(4 as decimal(8,4))as decimal(8,4))[PMRateOfSale]
		from #itemtotals t left outer join #lastStoreItemReq lq on lq.itemcode = right('00000000000000'+t.reorderitemcode,20) and lq.locationno = t.locationno
				left outer join #shipQty sq on sq.itemcode = right('00000000000000'+t.reorderitemcode,20) and sq.locationno = t.locationno 
				left outer join #PendingXref px on px.itemcode=t.ReorderItemCode and px.locationno=t.LocationNo and px.ISBN=t.ISBN
				left outer join #salesXref sx on sx.ReorderItemCode=t.ReorderItemCode and sx.LocationNo=t.LocationNo and sx.ISBN=t.ISBN
				left outer join #ISBNsales isx on isx.LocationNo=t.LocationNo and isx.ISBN=t.ISBN
				left outer join ReportsData..TeaserSalesRank sr with(nolock) on sr.itemcode = t.reorderitemcode and sr.StoreNo = t.locationno
				left outer join ReportsData..TeaserSIPSQOH sip on t.ISBN=sip.ISBN and t.LocationNo=sip.LocationNo 
				left outer join ReportsData..TeaserSectionQOH soh on t.LocationNo=soh.LocationNo and t.SectionCode=soh.SectionCode
		group by  t.locationno,t.district,t.locationid,t.title,t.reorderitemcode,t.PreviousItems,t.vendorid,t.SectionCode,t.itemcodecount,t.cost,t.price,t.initialstoredate,t.initialqty,
			t.soldinperiod,t.totalsold,t.qtyonhand,t.transferredout,t.lastsaledate,t.totalrcvd,isnull(t.lastreorderdate,t.InitialStoreDate),t.pending,t.markdowns,t.RO_CNT,
			t.isbn,t.xrefqty,t.NextOrderDate,t.CaseQty,isnull(sr.rank,'NA / NA / NA / NA'),isnull(sip.SIPSQOH,0),ISNULL(px.qtypendingXref,0),ISNULL(sx.sold,0),isnull(isx.ISBNSold,0)


/*****************************************************************************************************************************************************************
CLEANING UP TEMP TABLES 
*****************************************************************************************************************************************************************/
drop table #itemtotals
drop table #curreorderables
drop table #reorderables
drop table #pending
drop table #allsales
drop table #locxref
drop table #totalxref
drop table #xref
drop table #locs
drop table #totals
drop table #rVendors
drop table #lastStoreItemReq
drop table #shipQty
drop table #upcItems
drop table #PendingXref
drop table #vendxref
drop table #salesXref
drop table #ISBNsales
drop table #chkXref

END


GO

