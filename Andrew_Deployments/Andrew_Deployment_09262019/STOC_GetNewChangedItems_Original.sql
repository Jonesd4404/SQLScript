USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[STOC_GetNewChangedItems]    Script Date: 9/26/2019 9:57:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B.>
-- Create date: <11/19/2012>
-- Description:	<Copies new and changed items over to reorder applications.....>
-- =============================================
CREATE PROCEDURE [dbo].[STOC_GetNewChangedItems] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @rVal int
	declare @err int
	set @rVal = 0
	set @err = 0
	
	----=============================================================================================================================================================================================================
	----get all the active store locations...........................................................................................................................................................................
		create table #locs(locationno char(5), locationname char(30), locationID char(10))
		begin
			insert #locs
				select locationno, DistrictCode, locationid 
				from [HPB_Prime].[dbo].[Locations]
				where retailstore = 'y' and isnumeric(locationno) = 1 and status = 'A' and CAST(locationno as int) between 1 and 200
		end
	----=============================================================================================================================================================================================================
	set @err = @@ERROR
	----=============================================================================================================================================================================================================
	----get items that have changed..................................................................................................................................................................................
		select pm.Title,right(pm.Itemcode,8)[ItemCode],pm.PurchaseFromVendorID [VendorID],pm.SectionCode,pm.Cost,pm.Price,case when ISNULL(pm.ISBN,'')='' then pmd.UPC else pm.ISBN end [ISBN],isnull(pmrc.ConversionQty,0)[UnitsPerCase]
		into #changeItems
		from OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.productmaster pm
			inner join OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.productmasterdist pmd
				on pm.itemcode = pmd.itemcode
			left outer join OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.ProductMasterReorderConversion pmrc
				on pm.itemcode = pmrc.itemcode
			inner join OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.vendormaster v
				on pm.purchasefromvendorid = v.vendorid
		where pmd.lastchangedate >= DATEADD(MINUTE,-61,getdate())
			and pm.reorderable = 'Y' 
			and isnull(v.userchar30,'') <> '' 
			and v.userchar30 <> 'Supplies'
			--and right(pm.Itemcode,8) in (select distinct ReorderItemCode from STOC_TeaserData)
	----=============================================================================================================================================================================================================
	if @err = 0 begin set @err = @@ERROR end
	----=============================================================================================================================================================================================================
	----update the changed items.....................................................................................................................................................................................
		update s
			set s.Title=i.Title,s.SectionCode=i.SectionCode,s.Cost=i.Cost,s.Price=i.Price,s.ISBN=i.ISBN,s.CaseQty=i.UnitsPerCase,s.VendorID=i.VendorID
		from STOC_TeaserData s 
			inner join #changeItems i 
				on s.ReorderItemCode=i.itemcode
	----=============================================================================================================================================================================================================
	if @err = 0 begin set @err = @@ERROR end
	----=============================================================================================================================================================================================================
	----insert the missing changed items.....................................................................................................................................................................................
		insert into STOC_TeaserData
			select l.locationno,l.locationname,l.locationID,i.title,'',i.itemcode,'',i.vendorid,i.sectioncode,1,i.cost,i.price,null,0,0,0,0,0,null,0,null,0,0,0,0,0,0,i.isbn,0,GETDATE(),i.UnitsPerCase,0,0,'NA / NA / NA / NA',0,0,0
			from #locs l cross join #changeItems i
			where i.ItemCode not in (select distinct ReorderItemCode from STOC_TeaserData)
	----=============================================================================================================================================================================================================
	if @err = 0 begin set @err = @@ERROR end
	----=============================================================================================================================================================================================================
	----get all the newly reorderable items for insertion............................................................................................................................................................
		select pm.Title,right(pm.Itemcode,8)[ItemCode],pm.PurchaseFromVendorID [VendorID],pm.SectionCode,pm.Cost,pm.Price,case when ISNULL(pm.ISBN,'')='' then pmd.UPC else pm.ISBN end [ISBN],isnull(pmrc.ConversionQty,0)[UnitsPerCase]
		into #newItems
		from OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.productmaster pm
			inner join OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.productmasterdist pmd
				on pm.itemcode = pmd.itemcode
			left outer join OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.ProductMasterReorderConversion pmrc
				on pm.itemcode = pmrc.itemcode
			inner join OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.vendormaster v
				on pm.purchasefromvendorid = v.vendorid
		where --pm.createdate > dateadd(dd,-3,getdate())
			cast(convert(varchar(10),pm.createdate,120)as datetime) = cast(convert(varchar(10),getdate(),120)as datetime)
			and pm.reorderable = 'Y' 
			and isnull(v.userchar30,'') <> '' 
			and v.userchar30 <> 'Supplies'
			and right(pm.Itemcode,8) not in (select distinct ReorderItemCode from STOC_TeaserData)
		
		select t.LocationNo,t.ReorderItemCode,t.ISBN,t.Pending,t.PendXref,t.QtyOnHand,t.SIPSQOH,t.SoldXRef
		into #updates
		from STOC_TeaserData t 
		where (LTRIM(RTRIM(t.ISBN))<>'' and t.ISBN in (select distinct ISBN from #newItems)) 
			or (LTRIM(RTRIM(t.ISBN))<>'' and t.ISBN in (select distinct ISBN from #changeItems))
		
		------copy the items to HPB_Prime as well....
		insert into [HPB_Prime].[dbo].[ProductMaster](ItemCode,ItemAlias,Description,ProductType,VendorID,ValidCost,Cost,CostBasis,PriceMethod,AllowRegisterPricing,Price,AltPrice,SectionCode,DistributionCategory
           ,SchemeID,Title,ISBN,PurchaseFromVendorID,LastPurchaseOrder,Note,LastVoucherNumber,LastInvoiceNo,CreateDate,ReclassFromItemCode,Reorderable,InternetItem,InternetMinQty,InternetMaxQty
           ,MfgSuggestedPrice,UpdateQOH,AllowRegisterTitle,KeyWords,UserChar15,UserChar30,UserDate1,UserDate2,UserInt1,UserInt2,UserNum1,UserNum2,rowguid)
			select pm.ItemCode,pm.ItemAlias,pm.Description,pm.ProductType,pm.VendorID,pm.ValidCost,pm.Cost,pm.CostBasis,pm.PriceMethod,pm.AllowRegisterPricing,pm.Price,pm.AltPrice,pm.SectionCode,pm.DistributionCategory
			   ,pm.SchemeID,pm.Title,pm.ISBN,pm.PurchaseFromVendorID,pm.LastPurchaseOrder,pm.Note,pm.LastVoucherNumber,pm.LastInvoiceNo,pm.CreateDate,pm.ReclassFromItemCode,pm.Reorderable,pm.InternetItem,pm.InternetMinQty
			   ,pm.InternetMaxQty,pm.MfgSuggestedPrice,pm.UpdateQOH,pm.AllowRegisterTitle,pm.KeyWords,pm.UserChar15,pm.UserChar30,pm.UserDate1,pm.UserDate2,pm.UserInt1,pm.UserInt2,pm.UserNum1,pm.UserNum2,pm.rowguid
			from OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.productmaster pm
				inner join #newItems i 
					on pm.itemcode = RIGHT('00000000000000'+i.itemcode,20)
			where i.ItemCode not in (select ItemCode from [HPB_Prime].[dbo].[ProductMaster] where ItemCode=i.ItemCode)
		
		insert into [HPB_Prime].[dbo].[ProductMasterDist](ItemCode,Discount,VendorItemNo,ASIN,SchemeID,CreatedBy,LastChangeBy,LastChangeDate,CalcCost,CalcDate,CalcOveride
												,CalcDesc,ReorderableItem,ReportItemCode,RetailText,UPC,TTBProdType,UnitsPerCase)
			select pmd.ItemCode,pmd.Discount,pmd.VendorItemNo,pmd.ASIN,pmd.SchemeID,pmd.CreatedBy,pmd.LastChangeBy,pmd.LastChangeDate,pmd.CalcCost,pmd.CalcDate,pmd.CalcOveride
			   ,pmd.CalcDesc,pmd.ReorderableItem,pmd.ReportItemCode,pmd.RetailText,pmd.UPC,pmd.TTBProdType,pmd.UnitsPerCase
			from OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.productmasterdist pmd
				inner join #newItems i 
					on pmd.itemcode = RIGHT('00000000000000'+i.itemcode,20) 
			where i.ItemCode not in (select ItemCode from [HPB_Prime].[dbo].[ProductMasterDist] where ItemCode=i.ItemCode)

	----=============================================================================================================================================================================================================
	if @err = 0 begin set @err = @@ERROR end
	----=============================================================================================================================================================================================================
	----setup the data to insert into the STOC_TeaserData table......................................................................................................................................................
		insert into dbo.STOC_TeaserData
			select l.locationno,l.locationname,l.locationID,i.title,'',i.itemcode,'',i.vendorid,i.sectioncode,1,i.cost,i.price,null,0,0,0,0,0,null,0,null,0,0,0,0,0,0,i.isbn,0,GETDATE(),i.UnitsPerCase,0,0,'NA / NA / NA / NA',0,0,0,0,0,0
			from #locs l cross join #newItems i
		
		update t
			set t.PendXref=u.Pending,t.XRefQty=u.QtyOnHand,t.SIPSQOH=u.SIPSQOH, t.SoldXRef=u.SoldXRef
		from STOC_TeaserData t 
			inner join #updates u 
				on t.LocationNo=u.LocationNo 
					and t.ReorderItemCode!=u.ReorderItemCode 
					and t.ISBN=u.ISBN
		where t.ISBN in (select distinct ISBN from #newItems) 
			or t.ISBN in (select distinct ISBN from #changeItems)
	----=============================================================================================================================================================================================================
	if @err = 0 begin set @err = @@ERROR end	
	drop table #locs
	drop table #newItems
	drop table #changeItems
	drop table #updates
	set @rVal = @err
	return @rVal
END

GO


