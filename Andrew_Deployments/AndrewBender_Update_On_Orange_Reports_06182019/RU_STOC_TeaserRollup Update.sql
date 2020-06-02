-- =============================================
-- Author:		<Joey Blalock>
-- Create date: <6/1/2012>
-- Description:	<Rollup all reorderable data for STOC application.....>
--
-- Update:
--	- 2019-06-17 ALB Update to remove 452 (la Reunion from the list of supply only stores
-- =============================================
ALTER PROCEDURE [dbo].[RU_STOC_TeaserRollup]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	----run PI check and fill with reorderable items if needed.................
	EXEC ReportsData..STOC_ProdInv_Failsafe

	/*****************************************************************************************************************************************************************
	***LOCATION FILTERING
	*****************************************************************************************************************************************************************/
	CREATE TABLE #locs 
	(
		 locationno CHAR(5)
		,locationname CHAR(30)
		,locationID CHAR(10)
	)

	BEGIN
		INSERT #locs
			SELECT	 locationno
					,DistrictCode
					,locationid --[name]
			FROM reportsdata..locations WITH (NOLOCK)
			WHERE retailstore = 'y'
				AND isnumeric(locationno) = 1
				AND STATUS = 'A'
				AND CAST(locationno AS INT) BETWEEN 1 AND 200
				OR STATUS = 'A'
				AND UserInt1 = 1
				AND locationno != '00888'
			ORDER BY LocationNo
	END

	/*****************************************************************************************************************************************************************
	***GETTING  LIST OF REORDERABLE VENDORS --exclude Supplies from roll-up
	*****************************************************************************************************************************************************************/
	CREATE TABLE #rVendors 
	(
		 vendorID VARCHAR(20)
		,NextOrderDate DATETIME
	)

	BEGIN
		INSERT #rVendors
			SELECT DISTINCT 
				 vendorid
				,UserDate1
			FROM reportsdata..vendormaster WITH (NOLOCK)
			WHERE isnull(ltrim(rtrim(userchar30)), '') <> ''
	END

	/*****************************************************************************************************************************************************************
	***GETTING  LIST OF REORDERABLE ITEMCODES WITH REPORT ITEMCODE FOR END GROUPING
	*****************************************************************************************************************************************************************/
	SELECT DISTINCT 
		 pmd.ItemCode
		,cast(isnull(dbo.RPTfn_GetHistItemCodes(pmd.itemcode), '') AS VARCHAR(100)) AS [PreviousItems]
		,CASE WHEN isnull(pmd.ReportitemCode, '') = '' THEN pmd.ItemCode ELSE pmd.ReportItemCode END AS [ReportitemCode]
		,CASE WHEN pm.title = '' THEN pm.description ELSE pm.title END AS [Title]
		,CalcCost
		,pm.reorderable
		,pmd.reorderableitem
		,CASE WHEN pm.PurchaseFromVendorID <> '' THEN pm.PurchaseFromVendorID ELSE pm.VendorID END AS [VendorID]
		,isnull((SELECT SectionCode FROM ReportsData..sectionmaster_dipsmapping WHERE DIPS_SectionCode = pm.SectionCode ), pm.SectionCode) AS [sectioncode]
		,CASE ltrim(rtrim(pm.ISBN)) WHEN '' THEN substring(pmd.upc, 1, 13) ELSE pm.isbn END AS [isbn]
		,ISNULL(pmrc.ConversionQty, 0) AS [CaseQty]
		,pm.Cost
		,pm.Price
	INTO #curreorderables
	FROM reportsdata..productmasterdist pmd WITH (NOLOCK)
		INNER JOIN reportsdata..productmaster pm WITH (NOLOCK)
			ON pm.itemcode = pmd.itemcode
				AND CASE WHEN PurchaseFromVendorID <> '' THEN PurchaseFromVendorID ELSE VendorID END IN ( SELECT DISTINCT vendorid FROM #rVendors )
		LEFT JOIN ReportsData..ProductMasterReorderConversion pmrc
			ON pmd.ItemCode = pmrc.ItemCode
	WHERE pm.reorderable = 'Y'

	----get UPC/ISBN items..................................................................
	--select pm.ItemCode,pmd.ReportItemCode
	--into #upcItems
	--from ReportsData..ProductMaster pm with (nolock) inner join ReportsData..ProductMasterDist pmd with (nolock)
	--	on pm.ItemCode=pmd.ItemCode
	--where pm.ItemCode in (select distinct right('00000000000000000000' + replace(ItemAlias,'UPC',''),20) from ReportsData..ProductMaster where ItemAlias like 'UPC%')
	SELECT DISTINCT 
		 right('00000000000000000000' + replace(ItemAlias, 'UPC', ''), 20) AS [ItemCode]
		,cast('00000000000000000000' AS CHAR(20)) AS [ReportItemCode]
	INTO #upcItems
	FROM ReportsData..ProductMaster WITH (NOLOCK)
	WHERE ItemAlias LIKE 'UPC%'

	UPDATE u
		SET reportitemcode = pmd.ReportItemCode
	FROM ReportsData..ProductMaster pm WITH (NOLOCK)
		INNER JOIN ReportsData..ProductMasterDist pmd WITH (NOLOCK)
			ON pm.ItemCode = pmd.ItemCode
		INNER JOIN #upcItems u
			ON u.itemcode = pm.itemcode

	CREATE TABLE #reorderables 
	(
		ItemCode VARCHAR(20)
		,PreviousItems VARCHAR(100)
		,ReportItemCode VARCHAR(20)
		,Title VARCHAR(70)
		,CalcCost MONEY
		,Reorderable CHAR(1)
		,ReorderableItem CHAR(1)
		,VendorID VARCHAR(20)
		,SectionCode VARCHAR(20)
		,ISBN VARCHAR(15)
		,CaseQty INT
		,Cost MONEY
		,Price MONEY
	)
	CREATE CLUSTERED INDEX [IDX_REO] ON #reorderables ( [ItemCode] ,[ReportItemCode] )

	--***adding in all items that are not reorderable but have the reportitemcode of any of the current reorderables excluding UPC items....
	INSERT INTO #reorderables
		SELECT DISTINCT 
			 ItemCode
			,max(PreviousItems) AS [PreviousItems]
			,ReportItemCode
			,Title
			,CalcCost
			,Reorderable
			,ReorderableItem
			,VendorID
			,SectionCode
			,ISBN
			,CaseQty
			,Cost
			,Price
		FROM (	SELECT DISTINCT 
					 pmd.ItemCode 
					,r.PreviousItems 
					,CASE WHEN isnull(pmd.ReportitemCode, '') = '' THEN pmd.ItemCode ELSE pmd.ReportItemCode END AS [ReportitemCode]
					,r.Title
					,pmd.CalcCost
					,pm.reorderable
					,pmd.reorderableitem
					,r.vendorid
					,r.sectioncode
					,r.isbn
					,r.CaseQty [CaseQty]
					,r.Cost
					,r.Price
				FROM reportsdata..productmasterdist pmd WITH (NOLOCK)
					INNER JOIN reportsdata..productmaster pm WITH (NOLOCK)
						ON pm.itemcode = pmd.itemcode
					INNER JOIN #curreorderables r
						ON r.reportitemcode = pmd.reportitemcode
					WHERE pmd.ItemCode NOT IN ( SELECT DISTINCT ItemCode FROM #upcItems )		
				UNION		
				SELECT DISTINCT 
					 itemcode
					,PreviousItems
					,reportitemcode
					,title
					,calccost
					,reorderable
					,reorderableitem
					,VendorID
					,SectionCode
					,ISBN
					,CaseQty
					,Cost
					,Price
				FROM #curreorderables 
			) r
		GROUP BY ItemCode ,ReportItemCode ,Title ,CalcCost ,Reorderable ,ReorderableItem ,VendorID ,SectionCode ,ISBN ,CaseQty ,Cost ,Price

	----adding in UPC items excluded from previous step....
	INSERT INTO #reorderables
		SELECT DISTINCT 
			 pmd.ItemCode
			,r.PreviousItems
			,CASE WHEN isnull(pmd.ReportitemCode, '') = '' THEN pmd.ItemCode ELSE pmd.ReportItemCode END AS [ReportitemCode]
			,r.Title
			,pmd.CalcCost
			,pm.reorderable
			,pmd.reorderableitem
			,r.vendorid
			,r.sectioncode
			,r.isbn
			,r.CaseQty [CaseQty]
			,r.Cost
			,r.Price
		FROM reportsdata..productmasterdist pmd WITH (NOLOCK)
			INNER JOIN reportsdata..productmaster pm WITH (NOLOCK)
				ON pm.itemcode = pmd.itemcode
			INNER JOIN #curreorderables r
				ON r.reportitemcode = pmd.reportitemcode
		WHERE pmd.ItemCode IN ( SELECT DISTINCT ItemCode FROM #upcItems )

	------flip any items back that have been reactivated under an older itemcode......
	UPDATE r
		SET r.ReportItemCode = ( SELECT TOP 1 ItemCode FROM #curreorderables WHERE ReportItemCode = r.ReportItemCode ORDER BY ItemCode DESC )
	FROM #reorderables r
	WHERE r.ReportItemCode IN ( SELECT DISTINCT ReportItemCode FROM #curreorderables WHERE ItemCode <> ReportItemCode AND ReportitemCode <> '' )

	----Get last store/item/req information for sales & transfer date ranges.......
	SELECT	 max(rh.RequisitionNo) [ReqNo]
			,rh.LocationNo
			,rd.itemcode
			,cr.ReportItemCode [ReorderItemCode]
			,max(rh.DateApprovedDisapproved) [LastOrderDate]
			,0 [LastQty]
	INTO #lastStoreItemReq
	FROM reportsdata..requisitiondetail rd WITH (NOLOCK)
		INNER JOIN reportsdata..requisitionheader rh WITH (NOLOCK)
			ON rd.requisitionno = rh.requisitionno
		INNER JOIN #reorderables cr
			ON rd.itemcode = cr.itemcode
	WHERE rh.requestby <> 'VOID'
		AND rh.DateApprovedDisapproved IS NOT NULL
		AND rh.POnumber IS NOT NULL
		AND rh.vendorid IN ( SELECT DISTINCT vendorid FROM #rVendors UNION  SELECT 'IDTEXASBOO' )
		AND rh.locationno IN ( SELECT DISTINCT locationno FROM #locs )
	GROUP BY rh.LocationNo ,rd.itemcode ,cr.ReportItemCode

	----Update last ordered qty for item/store...........................................................................................
	UPDATE req
		SET LastQty = isnull(rd.ApprovedQtyToOrder, 0)
	FROM reportsdata..requisitiondetail rd WITH (NOLOCK)
		INNER JOIN ReportsData..RequisitionHeader rh WITH (NOLOCK)
			ON rd.RequisitionNo = rh.RequisitionNo
		INNER JOIN #lastStoreItemReq req
			ON req.reqno = rd.requisitionno
				AND req.itemcode = rd.itemcode
				AND req.locationno = rh.locationno

	--initial dist dates...........................................................................................
	SELECT	 r.reportitemcode
			,r.itemcode
			,min(sd.datereceived) [InitialStoreDate]
			,l.locationno
			,sum(0) [InitialQty]
	INTO #DistDate
	FROM #reorderables r
		INNER JOIN reportsdata..shipmentdetail sd WITH (NOLOCK)
			ON sd.itemcode = r.itemcode
		INNER JOIN #locs l WITH (NOLOCK)
			ON l.locationno = sd.locationno
		GROUP BY r.reportitemcode ,r.itemcode ,l.locationno

	--initial qty update....................................................
	UPDATE d
		SET InitialQty = isnull(sd.qty, 0)
	FROM #DistDate d
		INNER JOIN reportsdata..shipmentdetail sd WITH (NOLOCK)
			ON d.itemcode = sd.itemcode
				AND d.locationno = sd.locationno
				AND d.InitialStoreDate = sd.datereceived

	/*****************************************************************************************************************************************************************
	***INSERTING ADDITIONAL SALES FROM SEARCH & SHIP / ONLINE SALES........
	*****************************************************************************************************************************************************************/
	CREATE TABLE #AddtSales 
	(
		 Store VARCHAR(6)
		,DistrictCode VARCHAR(30)
		,ItemCode VARCHAR(20)
		,ReportItemCode VARCHAR(20)
		,VendorID VARCHAR(20)
		,ISBN VARCHAR(15)
		,SectionCode VARCHAR(20)
		,Sales NUMERIC(12, 0)
		,SalesDate DATETIME
	)

	----Search & Ship sales..........
	INSERT INTO #AddtSales
		SELECT	 lc.locationno
				,lc.locationname
				,r.Itemcode
				,r.ReportitemCode
				,r.VendorID
				,r.ISBN
				,r.SectionCode
				,isnull(sum(scd.Quantity), 0) [SoldQty]
				,scd.datesold
		FROM ReportsData..Sales_CrossChannel_Distribution scd WITH (NOLOCK)
			INNER JOIN #reorderables r
				ON r.itemcode = scd.itemcode
			INNER JOIN #locs lc
				ON lc.locationid = scd.locationid
		GROUP BY lc.locationno ,lc.locationname ,r.Itemcode ,r.ReportitemCode ,r.VendorID ,r.ISBN ,r.SectionCode ,scd.datesold

	----Online market place sales.........
	INSERT INTO #AddtSales
		SELECT	 lc.locationno
				,lc.locationname
				,r.Itemcode
				,r.ReportitemCode
				,r.VendorID
				,r.ISBN
				,r.SectionCode
				,isnull(sum(sod.Quantity), 0) [SoldQty]
				,sod.datesold
		FROM ReportsData..Sales_OnlineMarketPlaces_Distribution sod WITH (NOLOCK)
			INNER JOIN #reorderables r
				ON r.itemcode = sod.itemcode
			INNER JOIN #locs lc
				ON lc.locationid = sod.locationid
		GROUP BY lc.locationno ,lc.locationname ,r.Itemcode ,r.ReportitemCode ,r.VendorID ,r.ISBN ,r.SectionCode ,sod.datesold

	/*****************************************************************************************************************************************************************
	***Get all the sales data in one call......
	*****************************************************************************************************************************************************************/
	SELECT	 l.locationno
			,sih.itemcode [itemcode]
			,r.VendorID
			,r.ISBN
			,isnull(sum(CASE sih.isreturn WHEN 'y' THEN - (sih.quantity) ELSE sih.quantity END), 0) [sold]
			,cast(sih.businessdate AS DATE) [saledate]
			,CASE WHEN max(sih.businessdate) < MAX(a.SalesDate) THEN MAX(a.SalesDate) ELSE max(sih.businessdate) END AS [lastsaledate]
			,sum(CASE WHEN sih.unitprice > sih.registerprice AND isreturn = 'n' THEN 1 ELSE 0 END) [markdowns]
	INTO #allsales
	FROM rhpb_historical..salesitemhistory sih WITH (NOLOCK)
		INNER JOIN #locs l
			ON l.locationid = sih.locationid
		INNER JOIN #reorderables r
			ON r.itemcode = sih.itemcode
		LEFT JOIN ( SELECT Store ,ItemCode ,MAX(SalesDate) [SalesDate] FROM #AddtSales GROUP BY Store ,ItemCode ) a
			ON a.ItemCode = r.itemcode
				AND a.Store = l.locationno
	GROUP BY l.locationno ,sih.itemcode ,r.VendorID ,r.ISBN ,cast(sih.businessdate AS DATE)
	HAVING isnull(sum(CASE sih.isreturn WHEN 'y' THEN - (sih.quantity) ELSE sih.quantity END), 0) > 0

	INSERT INTO #allsales
		SELECT	 a.Store
				,a.ItemCode
				,a.VendorID
				,a.ISBN
				,a.Sales
				,a.SalesDate
				,( SELECT max(lastsaledate) FROM #allsales WHERE ItemCode = a.ItemCode AND locationno = a.Store )
				,0
		FROM #AddtSales a

	/*****************************************************************************************************************************************************************
	***Put since last order sales into sold temp......
	*****************************************************************************************************************************************************************/
	SELECT	 a.locationno
			,a.itemcode [itemcode]
			,r.VendorID
			,r.ISBN
			,isnull(sum(a.sold), 0) [numsold]
			,max(a.lastsaledate) [lastsaledate]
			,sum(a.markdowns) [markdowns]
	INTO #sold
	FROM #allsales a
		INNER JOIN #reorderables r
			ON r.itemcode = a.itemcode
	WHERE a.saledate >= ( SELECT cast(max(ls.lastorderdate) AS DATE) FROM #lastStoreItemReq ls WHERE ls.ReorderItemCode = r.ReportitemCode AND ls.locationno = a.locationno )
	GROUP BY a.locationno ,a.itemcode ,r.VendorID ,r.ISBN

	----add in sales for initial dist items that have not yet been reordered...........................................................
	INSERT INTO #sold
		SELECT	 a.locationno
				,a.itemcode [itemcode]
				,r.VendorID
				,r.isbn
				,isnull(sum(a.sold), 0) [numsold]
				,max(a.lastsaledate) [lastsaledate]
				,sum(a.markdowns) [markdowns]
		FROM #allsales a
			INNER JOIN #reorderables r
				ON r.itemcode = a.itemcode
		WHERE a.saledate >= (	SELECT cast(max(dd.InitialStoreDate) AS DATE) 
								FROM #DistDate dd 
								WHERE dd.ReportitemCode = r.ReportItemCode
									AND dd.locationno = a.locationno
									AND dd.ReportitemCode NOT IN ( SELECT DISTINCT ReorderItemCode FROM #lastStoreItemReq ls WHERE ls.ReorderItemCode = r.ReportitemCode AND ls.locationno = a.locationno )

							)
	GROUP BY a.locationno ,a.itemcode ,r.VendorID ,r.isbn

	/*****************************************************************************************************************************************************************
	***Put total sales into totalsold temp......
	*****************************************************************************************************************************************************************/
	SELECT	 a.locationno
			,a.itemcode [itemcode]
			,r.VendorID
			,r.ISBN
			,isnull(sum(a.sold), 0) [totalsold]
			,max(a.lastsaledate) [lastsaledate]
			,isnull((	SELECT isnull(sum(CASE sih.isreturn WHEN 'y' THEN - (sih.quantity) ELSE sih.quantity END), 0) [sold]
						FROM rHPB_Historical..SalesItemHistory sih
							INNER JOIN ReportsData..Locations l
								ON sih.LocationID = l.LocationID
						WHERE sih.ItemCode = a.ItemCode
							AND l.LocationNo = a.locationno
							AND sih.BusinessDate > DATEADD(week, - 4, getdate())), 0) [4WeekSales]
	INTO #totalsold
	FROM #allsales a
		INNER JOIN #reorderables r
			ON r.itemcode = a.itemcode
	GROUP BY a.locationno ,a.itemcode ,r.VendorID ,r.ISBN
	HAVING ISNULL(sum(a.sold), 0) > 0

	/*****************************************************************************************************************************************************************
	***TRANSFERRED INFORMATION --join lastReq table to get vendor/store startdate.....
	*****************************************************************************************************************************************************************/
	SELECT	 lc.locationno
			,sum(isnull(it.transferqty, 0)) [qtytransferred]
			,r.ReportItemCode [itemcode]
			,it.fromlocationno
	INTO #qtytransferred
	FROM reportsdata..inventorytransfers it WITH (NOLOCK)
		INNER JOIN #reorderables r
			ON r.itemcode = it.itemcode
		INNER JOIN #locs lc
			ON lc.locationno = it.fromlocationno
	WHERE it.datetransferred >= (	SELECT max(ls.lastorderdate)
									FROM #lastStoreItemReq ls
									WHERE ls.ReorderItemCode = r.ReportItemCode
									AND ls.locationno = lc.locationno 
								)
	GROUP BY lc.locationno ,r.ReportItemCode ,it.fromlocationno

	----add in transfers for initial dist items that have not yet been reordered...........................................................
	INSERT INTO #qtytransferred
		SELECT	 lc.locationno
				,sum(isnull(it.transferqty, 0)) [qtytransferred]
				,r.ReportItemCode [itemcode]
				,it.fromlocationno
		FROM reportsdata..inventorytransfers it WITH (NOLOCK)
			INNER JOIN #reorderables r
				ON r.itemcode = it.itemcode
			INNER JOIN #locs lc
				ON lc.locationno = it.fromlocationno
		WHERE it.datetransferred >= (	SELECT cast(max(dd.InitialStoreDate) AS DATE)
										FROM #DistDate dd
										WHERE dd.ReportitemCode = r.ReportItemCode
											AND dd.locationno = lc.locationno
											AND dd.ReportitemCode NOT IN (	SELECT DISTINCT ReorderItemCode
																			FROM #lastStoreItemReq ls
																			WHERE ls.ReorderItemCode = r.ReportitemCode
																				AND ls.locationno = lc.locationno
																		 )
									)
		GROUP BY lc.locationno ,r.ReportItemCode ,it.fromlocationno

	/*****************************************************************************************************************************************************************
	***SHIPPED since last order INFORMATION --join lastReq table to get vendor/store startdate.....
	*****************************************************************************************************************************************************************/
	SELECT	 sd.locationno
			,sd.itemcode
			,SUM(isnull(sd.qty, 0)) [ShipQty]
	INTO #shipQty
	FROM reportsdata..shipmentdetail sd WITH (NOLOCK)
		INNER JOIN reportsdata..shipmentheader sh WITH (NOLOCK)
			ON sd.transferid = sh.transferid
		INNER JOIN #locs lc
			ON lc.locationno = sd.locationno
		INNER JOIN #reorderables r
			ON r.itemcode = sd.itemcode
		INNER JOIN #lastStoreItemReq ls
			ON ls.itemcode = sd.itemcode
				AND ls.locationno = sd.locationno
	WHERE sh.FromLocationNo IN ('00944')
		AND sh.datetransferred >= isnull(ls.lastorderdate, dateadd(dd, - 1, getdate()))
		AND sh.datetransferred <= getdate()
	GROUP BY sd.locationno ,sd.itemcode

	----add in shipped for initial dist items that have not yet been reordered...........................................................
	INSERT INTO #shipQty
		SELECT sd.locationno
			,sd.itemcode
			,SUM(isnull(sd.qty, 0)) [ShipQty]
		FROM reportsdata..shipmentdetail sd WITH (NOLOCK)
			INNER JOIN reportsdata..shipmentheader sh WITH (NOLOCK)
				ON sd.transferid = sh.transferid
			INNER JOIN #locs lc
				ON lc.locationno = sd.locationno
			INNER JOIN #reorderables r
				ON r.itemcode = sd.itemcode
			INNER JOIN #lastStoreItemReq ls
				ON ls.itemcode = sd.itemcode
					AND ls.locationno = sd.locationno
		WHERE sh.FromLocationNo IN ('00944')
			AND sh.datetransferred >= (	SELECT cast(max(dd.InitialStoreDate) AS DATE)
										FROM #DistDate dd
										WHERE dd.ReportitemCode = r.ReportItemCode
											AND dd.locationno = lc.locationno
											AND dd.ReportitemCode NOT IN (	SELECT DISTINCT ReorderItemCode
																			FROM #lastStoreItemReq ls
																			WHERE ls.ReorderItemCode = r.ReportitemCode
																				AND ls.locationno = lc.locationno 
																		 )
									)
		GROUP BY sd.locationno ,sd.itemcode

	/*****************************************************************************************************************************************************************
	***RECEIVED INFORMATION
	*****************************************************************************************************************************************************************/
	--New Store Receiving tables....
	SELECT	 sh.LocationNo
			,sd.ItemCode
			,sh.ShipmentNo [transferid]
			,SUM(sd.qty) [qtyreceived]
			,sh.ShipmentType
	INTO #received
	FROM ReportsData..SR_Header sh WITH (NOLOCK)
		INNER JOIN ReportsData..SR_Detail sd WITH (NOLOCK)
			ON sh.BatchID = sd.BatchID
		INNER JOIN #reorderables r
			ON r.itemcode = sd.ItemCode
		INNER JOIN #locs lc
			ON sh.locationno = lc.locationno
	WHERE sh.ShipmentType IN ('W', 'R', 'S')
	GROUP BY sh.LocationNo ,sd.ItemCode ,sh.ShipmentNo
		,sh.ShipmentType
	HAVING SUM(sd.Qty) > 0

	--New Store Receiving archive tables from old SR2 table.....
	INSERT INTO #received
		SELECT	 sh.LocationNo
				,sd.ItemCode
				,sh.ShipmentNo [transferid]
				,SUM(sd.qty) [qtyreceived]
				,sh.ShipmentType
		FROM ReportsData..SR_Header_Historical sh WITH (NOLOCK)
			INNER JOIN ReportsData..SR_Detail_Historical sd WITH (NOLOCK)
				ON sh.BatchID = sd.BatchID
			INNER JOIN #reorderables r
				ON r.itemcode = sd.ItemCode
			INNER JOIN #locs lc
				ON sh.LocationNo = lc.locationno
		WHERE sh.ShipmentType IN ('W', 'R', 'S')
			AND sh.ShipmentNo NOT IN ( SELECT DISTINCT transferid FROM #received )
		GROUP BY sh.LocationNo ,sd.ItemCode ,sh.ShipmentNo ,sh.ShipmentType
		HAVING SUM(sd.Qty) > 0

	--pending quantities................................................................................................
	SELECT	 sd.locationno
			,sd.itemcode
			,sd.transferid
			,sum(isnull(sd.qty, 0)) [qtypending]
			,MAX(isnull(sd.datereceived, getdate())) [TransDate]
			,r.VendorID
	INTO #pending
	FROM reportsdata..shipmentdetail sd WITH (NOLOCK)
		INNER JOIN reportsdata..shipmentheader sh WITH (NOLOCK)
			ON sh.transferid = sd.transferid
		INNER JOIN (
			SELECT DISTINCT itemcode
				,VendorID
			FROM #reorderables
			) r
			ON r.itemcode = sd.itemcode
		INNER JOIN #locs lc
			ON sd.locationno = lc.locationno
	WHERE sh.FromLocationNo = '00944'
		AND sh.Receiver IS NULL
		AND sh.TransferID NOT IN ( SELECT DISTINCT transferid FROM #received )
		AND right('0000' + sd.PONumber, 10) NOT IN ( SELECT DISTINCT transferid FROM #received WHERE ShipmentType = 'R' )
	GROUP BY sd.locationno ,sd.itemcode ,sd.transferid ,r.VendorID
	HAVING SUM(sd.Qty) > 0

	--insert pending orders that have been placed by stores but not yet shipped by CDC....
	INSERT INTO #pending
		SELECT	 rh.locationno
				,rd.itemcode
				,rh.PONumber
				,sum(isnull(rd.ApprovedQtyToOrder, 0)) [qtypending]
				,MAX(o.PODate) [TransDate]
				,r.VendorID
		FROM ReportsData..RequisitionHeader rh WITH (NOLOCK)
			INNER JOIN ReportsData..RequisitionDetail rd
				ON rh.RequisitionNo = rd.RequisitionNo
			INNER JOIN ( SELECT DISTINCT itemcode ,VendorID FROM #reorderables ) r
				ON r.itemcode = rd.itemcode
			INNER JOIN #locs lc
				ON rh.locationno = lc.locationno
			INNER JOIN (	SELECT oh.PONumber ,od.ItemCode ,oh.PODate ,oh.POType 
							FROM ReportsData..OrderHeader oh WITH (NOLOCK)
								INNER JOIN ReportsData..OrderDetail od
									ON oh.PONumber = od.PONumber
							WHERE oh.VendorID <> 'WHPBSUPPLY'
								AND oh.POType IN ('C', 'D')
								AND oh.PODate > DATEADD(year, - 1, getdate())
						) o
				ON rh.PONumber = o.PONumber
					AND rd.ItemCode = o.ItemCode
		WHERE rd.Approved = 1
			AND rh.VendorID <> 'WHPBSUPPLY'
			AND rh.PONumber NOT IN (	SELECT DISTINCT sd.PONumber
										FROM reportsdata..shipmentdetail sd WITH (NOLOCK)
											INNER JOIN reportsdata..shipmentheader sh WITH (NOLOCK)
												ON sh.transferid = sd.transferid
										WHERE sd.PONumber = rh.PONumber )
			AND right('0000' + rh.PONumber, 10) NOT IN ( SELECT DISTINCT transferid FROM #received )
			AND right('0000' + rh.PONumber, 10) NOT IN ( SELECT DISTINCT transferid FROM #received WHERE ShipmentType = 'R' )
			AND right('0000' + rh.PONumber, 10) NOT IN ( SELECT DISTINCT TransferID FROM #pending )
		GROUP BY rh.locationno ,rd.itemcode ,rh.PONumber ,r.VendorID
		HAVING SUM(rd.ApprovedQtyToOrder) > 0

	--Older received records not in SR....
	INSERT INTO #received
		SELECT	 lc.locationno
				,sd.itemcode
				,sd.transferid
				,sum(sd.qty) [qtyreceived]
				,'' ShipmentType
		FROM reportsdata..shipmentdetail sd WITH (NOLOCK)
			INNER JOIN reportsdata..shipmentheader sh WITH (NOLOCK)
				ON sh.transferid = sd.transferid
			INNER JOIN #reorderables r
				ON r.itemcode = sd.itemcode
			INNER JOIN #locs lc
				ON sh.tolocationno = lc.locationno
		WHERE sd.TransferID NOT IN ( SELECT DISTINCT TransferID FROM #received )
			AND right('0000' + sd.PONumber, 10) NOT IN ( SELECT DISTINCT transferid FROM #received WHERE ShipmentType = 'R' )
			AND sd.TransferID NOT IN ( SELECT DISTINCT TransferID FROM #pending )
			AND sd.TransferID IN (	SELECT DISTINCT TransferID 
									FROM ReportsData..ShipmentHeader s WITH (NOLOCK) 
										INNER JOIN ReportsData..Locations l WITH (NOLOCK) 
												ON s.FromLocationID = l.LocationID
									WHERE l.LocationType IN ('R', 'C'))
		GROUP BY lc.locationno ,sd.itemcode ,sd.transferid
		HAVING SUM(sd.Qty) > 0

	--get totals............................................
	SELECT	 locationno
			,itemcode
			,sum(qtyreceived) [qtyreceived]
	INTO #totalrcvd
	FROM #received
	GROUP BY locationno ,itemcode

	--delete pending quantities that are older than 6 months....
	DELETE FROM #pending
	WHERE transdate <= DATEADD(month, - 4, getdate())
		OR itemcode IN ( SELECT DISTINCT ItemCode FROM #upcItems )

	DELETE FROM #pending
	WHERE VendorID = 'IDB&TDISTR'
		AND transdate <= DATEADD(DAY, - 30, getdate())

	--update pending table to consolidate and delete any duplicates...............................
	----update #pending set TransferID='',TransDate=GETDATE() 
	DELETE p1
	FROM #pending p1
	INNER JOIN (	SELECT p.ItemCode,p.LocationNo ,p.TransferID
					FROM #pending p
					GROUP BY p.ItemCode ,p.LocationNo ,p.TransferID
					HAVING COUNT(*) > 1 ) p2
		ON p1.itemcode = p2.itemcode
			AND p1.locationno = p2.locationno
			AND p1.TransferID = p2.TransferID

	SELECT LocationNo
		,ItemCode
		,sum(qtypending) [qtypending]
	INTO #totalpending
	FROM #pending
	GROUP BY LocationNo ,ItemCode

	--reorder count.......................................................................................................
	SELECT	 lc.locationno
			,r.itemcode
			,r.reportitemcode
			,count(*) [ReorderCount]
	INTO #reordercount
	FROM #reorderables r
		INNER JOIN reportsdata..requisitiondetail rd WITH (NOLOCK)
			ON r.itemcode = rd.itemcode
		INNER JOIN reportsdata..requisitionheader rh WITH (NOLOCK)
			ON rh.requisitionno = rd.requisitionno
		INNER JOIN #locs lc
			ON lc.locationno = rh.locationno
	GROUP BY lc.locationno ,r.itemcode ,r.reportitemcode

	/*****************************************************************************************************************************************************************
	PUTTING THE GATHERED DATA TOGETHER
	*****************************************************************************************************************************************************************/
	SELECT	 lc.locationno
			,lc.locationname [District]
			,lc.locationid
			,sum(isnull(it.qtytransferred, 0)) [TransferredOut]
			,r.title [Title]
			,right(r.itemcode, 8) [ItemCode]
			,right(r.reportitemcode, 8) [ReorderItemCode]
			,r.PreviousItems
			,r.VendorID
			,r.SectionCode
			,count(r.itemcode) [ItemCodeCount]
			,pm.Cost
			,pm.Price
			,isnull(isnull(min(dd.InitialStoreDate), ( SELECT min(InitialStoreDate) FROM #distdate WHERE ReportItemCode = r.ItemCode AND locationno = lc.locationno )), pm.createdate) [InitialStoreDate]
			,sum(isnull(dd.InitialQty, 0)) [InitialQty]
			,sum(isnull(s.numsold, 0)) [SoldInPeriod]
			,sum(isnull(ts.TotalSold, 0)) [TotalSold]
			,sum(isnull(pv.quantityonhand, 0)) [QtyOnHand]
			,isnull(max(s.lastsaledate), max(ts.lastsaledate)) [LastSaleDate]
			,sum(isnull(rc.qtyreceived, 0)) [TotalRcvd]
			,max(lq.LastOrderDate) [LastReOrderDate]
			,sum(isnull(pend.qtypending, 0)) [Pending]
			,0 [SuggestedOrderQty]
			,sum(isnull(s.markdowns, 0)) [Markdowns]
			,max(isnull(roc.reordercount, 0)) [RO_CNT]
			,sum(0) [LastQty]
			,sum(0) [ShipQty]
			,r.isbn
			,MAX(ISNULL(v.NextOrderDate, getdate())) [NextOrderDate]
			,ISNULL(r.CaseQty, 0) [CaseQty]
			,CASE WHEN isnull(( SELECT reportitemcode FROM #upcItems WHERE ReportItemCode = r.ReportItemCode ), '') <> '' THEN 'U' ELSE '' END AS [itemType]
			,ISNULL(SUM(ts.[4WeekSales]), 0) [4WeekSales]
	INTO #totals
	FROM #locs lc
		CROSS JOIN #reorderables r
		LEFT JOIN reportsdata..productmaster pm WITH (NOLOCK)
			ON pm.itemcode = r.itemcode
		LEFT JOIN #sold s
			ON s.itemcode = r.itemcode
				AND s.locationno = lc.locationno
		LEFT JOIN reportsdata..productinventory pv WITH (NOLOCK)
			ON pv.itemcode = r.itemcode
				AND pv.locationno = lc.locationno
		LEFT JOIN #totalrcvd rc
			ON rc.itemcode = r.itemcode
				AND rc.locationno = lc.locationno
		LEFT JOIN #totalsold ts
			ON ts.itemcode = r.itemcode
				AND ts.locationno = lc.locationno
		LEFT JOIN #qtytransferred it
			ON it.itemcode = r.itemcode
				AND it.locationno = lc.locationno
		LEFT JOIN #totalpending pend
			ON pend.itemcode = r.itemcode
				AND pend.locationno = lc.locationno
		LEFT JOIN #reordercount roc
			ON roc.itemcode = r.itemcode
				AND roc.locationno = lc.locationno
		LEFT JOIN #lastStoreItemReq lq
			ON lq.itemcode = r.itemcode
				AND lq.locationno = lc.locationno
		LEFT JOIN #DistDate dd
			ON dd.itemcode = r.itemcode
				AND dd.locationno = lc.locationno
		LEFT JOIN #shipQty sq
			ON sq.itemcode = r.itemcode
				AND sq.locationno = lc.locationno
		INNER JOIN #rVendors v
			ON r.VendorID = v.vendorID
	GROUP BY lc.locationno ,lc.locationname ,lc.locationid ,r.itemcode ,r.reportitemcode ,r.title ,pm.Cost ,pm.price ,pm.createdate ,r.isbn ,r.VendorID ,r.SectionCode ,r.PreviousItems, ISNULL(r.CaseQty, 0)

	DROP TABLE #sold
	DROP TABLE #totalrcvd
	DROP TABLE #totalsold
	DROP TABLE #qtytransferred
	DROP TABLE #totalpending
	DROP TABLE #reordercount
	DROP TABLE #DistDate
	DROP TABLE #received
	DROP TABLE #AddtSales

	/*****************************************************************************************************************************************************************
	XREFERENCED BY ISBN!!!!!!! 
	*****************************************************************************************************************************************************************/
	SELECT DISTINCT
		 locationno
		,isbn
		,sum(qtyonhand) [qty]
		,max(ReorderItemCode) [itemcode]
		,VendorID
	INTO #locxref
	FROM #totals
	WHERE ltrim(rtrim(isbn)) <> ''
		AND itemcode IS NOT NULL
	GROUP BY locationno ,isbn ,VendorID

	----get distinct location/isbn for total sales.....
	SELECT DISTINCT
		 locationno
		,isbn
	INTO #chkXref
	FROM #totals
	GROUP BY locationno ,ISBN

	----Creating the joining table with all but the quantity--------------------------------------------------------
	SELECT DISTINCT
		 lc.locationno
		,CASE ltrim(rtrim(pm.ISBN)) WHEN '' THEN substring(pd.upc, 1, 13) ELSE pm.isbn END AS [isbn]
		,sum(isnull(pv.quantityonhand, 0)) [qty]
	INTO #totalxref
	FROM reportsdata..productmaster pm WITH (NOLOCK)
		INNER JOIN reportsdata..productmasterdist pd WITH (NOLOCK)
			ON pd.itemcode = pm.itemcode
		LEFT JOIN reportsdata..productinventory pv WITH (NOLOCK)
			ON pv.itemcode = pm.itemcode
		INNER JOIN #locs lc
			ON lc.locationno = pv.locationno
	WHERE CASE ltrim(rtrim(pm.ISBN)) WHEN '' THEN substring(pd.upc, 1, 13) ELSE pm.isbn END IN ( SELECT DISTINCT isbn FROM #locxref )
		AND CASE WHEN isnull(pd.ReportitemCode, '') = '' THEN pd.ItemCode ELSE pd.ReportItemCode END NOT IN ( SELECT DISTINCT isnull(RIGHT('00000000000000000000' + ltrim(ItemCode), 20), '') FROM #locxref )
	GROUP BY lc.locationno ,pm.isbn ,pd.upc

	--having sum(isnull(pv.quantityonhand, 0)) > 0
	----Get other vendors xref-------------------------------------------------------------------------------------
	SELECT	 l1.locationno
			,l1.ISBN
			,isnull(SUM(l2.qty), 0) [qty]
			,l1.VendorID
			,l1.itemcode
	INTO #vendxref
	FROM #locxref l1
		LEFT JOIN #locxref l2
			ON l1.locationno = l2.locationno
				AND l1.ISBN = l2.ISBN
				AND l1.VendorID <> l2.VendorID
	GROUP BY l1.locationno ,l1.ISBN ,l1.VendorID ,l1.itemcode

	----Xref is complete--------------------------------------------------------------------------------------------
	SELECT	 lx.locationno
			,lx.itemcode
			,lx.isbn
			,isnull(tx.qty, 0) + isnull(r.qty, 0) [xrefqty]
	INTO #xref
	FROM #locxref lx
		LEFT JOIN #totalxref tx
			ON lx.isbn = tx.isbn
				AND lx.locationno = tx.locationno
		LEFT JOIN #vendxref r
			ON lx.ISBN = r.ISBN
				AND lx.locationno = r.locationno
				AND lx.itemcode = r.itemcode
	--where isnull(tx.qty,0)+isnull(r.qty,0) > 0
	----clean up blank ISBN/UPC values
	
	DELETE FROM #xref 
	WHERE LTRIM(RTRIM(isbn)) = ''

	----delete out non-supply reorder locations.....
	-- updated to exclude location 452
	DELETE FROM #totals
	WHERE VendorID != 'WHPBSUPPLY'
		AND LocationNo IN ( SELECT LocationNo FROM reportsdata..Locations WHERE UserInt1 = 1 AND locationno NOT IN ('00452') )

	CREATE TABLE #itemtotals 
	(
		LocationNo CHAR(5)
		,District VARCHAR(30)
		,LocationID CHAR(10)
		,Title VARCHAR(70)
		,ReorderItemCode VARCHAR(20)
		,PreviousItems VARCHAR(100)
		,VendorID VARCHAR(20)
		,SectionCode VARCHAR(20)
		,ItemCodeCount INT
		,Cost MONEY
		,Price MONEY
		,InitialStoreDate DATE
		,InitialQty INT
		,SoldInPeriod INT
		,TotalSold INT
		,QtyOnHand INT
		,TransferredOut INT
		,LastSaleDate DATE
		,TotalRcvd INT
		,LastReorderDate DATE
		,Pending INT
		,Markdowns INT
		,RO_CNT INT
		,ISBN VARCHAR(15)
		,XRefQty INT
		,NextOrderDate DATE
		,CaseQty INT
		,ItemType VARCHAR(6)
		,[4WeekSales] INT
	)
	CREATE CLUSTERED INDEX [IDX_ISBN] ON #itemtotals ( [ISBN] ,[LocationNo] )

	----group up all the totals to get to only current items.....
	INSERT INTO #itemtotals
		SELECT	 t.locationno
				,t.district
				,t.locationid
				,t.title [Title]
				,t.reorderitemcode
				,max(t.PreviousItems) [PreviousItems]
				,t.vendorid
				,t.SectionCode
				,sum(t.itemcodecount) [itemcodecount]
				,max(isnull(c.cost, 0)) [cost]
				,max(isnull(c.price, 0)) [price]
				,min(t.initialstoredate) [initialstoredate]
				,sum(t.initialqty) [initialqty]
				,sum(t.soldinperiod) [soldinperiod]
				,sum(t.totalsold) [totalsold]
				,sum(t.qtyonhand) [qtyonhand]
				,sum(t.transferredout) [transferredout]
				,max(t.lastsaledate) [lastsaledate]
				,sum(t.totalrcvd) [totalrcvd]
				,max(t.lastreorderdate) [lastreorderdate]
				,sum(t.pending) [pending]
				,sum(t.markdowns) [markdowns]
				,sum(t.RO_CNT) [RO_CNT]
				,max(t.isbn) [ISBN]
				,sum(isnull(xr.xrefqty, 0)) [xrefqty]
				,max(t.NextOrderDate) [NextOrderDate]
				,max(t.CaseQty) [CaseQty]
				,t.itemType
				,ISNULL(SUM(t.[4WeekSales]), 0) [4WeekSales]
		FROM #totals t
			LEFT JOIN #xref xr
				ON right('00000000000000' + xr.itemcode, 20) = right('00000000000000' + t.ReorderItemCode, 20)
					AND xr.locationno = t.locationno
			LEFT JOIN #curreorderables c
				ON c.itemcode = right('00000000000000' + t.itemcode, 20)
		GROUP BY t.locationno ,t.district ,t.locationid ,t.title ,t.reorderitemcode ,t.vendorid ,t.SectionCode ,t.itemType

	----insert pending Xref quantity ........
	SELECT	 v.locationno
			,v.ISBN
			,v.VendorID
			,v.itemcode
			,p.qtypending [qtypendingXref]
			,t.VendorID [VendorIDXref]
	INTO #PendingXref
	FROM #itemtotals t
	INNER JOIN #pending p
		ON t.LocationNo = p.LocationNo
			AND RIGHT('00000000000000000000' + t.ReorderItemCode, 20) = p.ItemCode
	LEFT JOIN #vendxref v
		ON t.LocationNo = v.locationno
			AND t.ISBN = v.ISBN
	WHERE t.VendorID <> v.VendorID
		AND v.ISBN <> '' --and v.qty>0
	ORDER BY v.locationno ,v.ISBN

	----insert xref sales quantity .........
	SELECT	 t.LocationNo
			,t.ReorderItemCode
			,t1.ISBN
			,sum(t1.sold) [sold]
	INTO #salesXref
	FROM #itemtotals t
		INNER JOIN #allsales t1
			ON t.ISBN = t1.ISBN
				AND t.LocationNo = t1.locationno
	WHERE ltrim(rtrim(isnull(t.ISBN, ''))) <> ''
		AND right('00000000000000000000' + t.ReorderItemCode, 20) <> t1.itemcode
		AND t.VendorID <> t1.VendorID
		AND t1.LastSaleDate > isnull(t.LastReorderDate, t.InitialStoreDate)
	GROUP BY t.LocationNo ,t.ReorderItemCode ,t1.ISBN
	ORDER BY t.LocationNo ,t.ReorderItemCode ,t1.ISBN

	----insert all sales by ISBN
	SELECT x.LocationNo
		,x.ISBN
		,isnull(sum(sih.Quantity), 0) [ISBNsold]
	INTO #ISBNsales
	FROM #chkXref x
	INNER JOIN #locs l
		ON x.locationno = l.locationno
	INNER JOIN (	SELECT DISTINCT pm.ItemCode ,pm.ISBN ,pmd.UPC
					FROM ReportsData..ProductMaster pm
						INNER JOIN ReportsData..ProductMasterDist pmd
							ON pm.ItemCode = pmd.ItemCode
					WHERE CASE ltrim(rtrim(pm.ISBN)) WHEN '' THEN substring(pmd.upc, 1, 13) ELSE pm.isbn END IN ( SELECT DISTINCT ISBN FROM #locxref ) 
			   ) pm
		ON pm.ISBN = x.isbn
	INNER JOIN rHPB_Historical..SalesItemHistory sih
		ON l.LocationID = sih.LocationID
			AND pm.ItemCode = sih.ItemCode
	WHERE ltrim(rtrim(isnull(x.ISBN, ''))) <> ''
	GROUP BY x.LocationNo ,x.ISBN
	ORDER BY x.LocationNo ,x.ISBN

	/*****************************************************************************************************************************************************************
	***Clear Roll-up table out
	*****************************************************************************************************************************************************************/
	TRUNCATE TABLE reportsdata..TeaserRollUp

	----/*****************************************************************************************************************************************************************
	----INSERT FINAL RESULTS INTO TEASERROLLUP TABLE
	----*****************************************************************************************************************************************************************/
	INSERT INTO reportsdata..TeaserRollUp
		SELECT	 t.locationno
				,t.district
				,t.locationid
				,t.title
				,'' [itemcode]
				,t.reorderitemcode
				,t.PreviousItems
				,t.vendorid
				,t.SectionCode
				,t.itemcodecount
				,t.cost
				,t.price
				,t.initialstoredate
				,t.initialqty
				,t.soldinperiod
				,t.totalsold
				,t.qtyonhand
				,t.transferredout
				,t.lastsaledate
				,t.totalrcvd
				,isnull(t.lastreorderdate, t.InitialStoreDate) [lastreorderdate]
				,t.pending
				,0 [suggestedorderqty]
				,t.markdowns
				,t.RO_CNT
				,sum(isnull(lq.lastqty, 0)) [lastqty]
				,sum(isnull(sq.shipqty, 0)) [shipqty]
				,t.isbn
				,t.xrefqty
				,t.NextOrderDate
				,t.CaseQty
				,cast(CASE WHEN isnull(datediff(wk, min(t.InitialStoreDate), max(t.lastsaledate)), 0) = 0 THEN 0 ELSE sum(isnull(t.TotalSold, 0)) / cast(isnull(datediff(wk, min(t.InitialStoreDate), max(t.lastsaledate)), 1) AS DECIMAL(8, 4)) END AS DECIMAL(8, 4)) [RateOfSale]
				,isnull(cast(((convert(FLOAT, sum(isnull(t.totalsold, 0))) / (convert(FLOAT, CASE WHEN sum(isnull(t.totalrcvd, 0)) = 0 THEN CASE WHEN sum(isnull(t.totalsold, 0)) = 0 THEN 1 ELSE sum(isnull(t.totalsold, 1)) END ELSE sum(isnull(t.totalrcvd, 1)) END) + convert(FLOAT, sum(isnull(t.pending, 0))))) * 100) AS INT), 0) [PercentSold]
				,isnull(sr.rank, 'NA / NA / NA / NA') [SalesRank]
				,isnull(sip.SIPSQOH, 0) [SIPsQOH]
				,ISNULL(px.qtypendingXref, 0) [PendXref]
				,ISNULL(sx.sold, 0) [SoldXref]
				,isnull(isx.ISBNSold, 0) [ISBNSold]
				,sum(ISNULL(soh.SectionQty, 0)) [SectionQty]
				,cast(ISNULL(cast(SUM(t.[4WeekSales]) AS DECIMAL(8, 4)), 0) / cast(4 AS DECIMAL(8, 4)) AS DECIMAL(8, 4)) [PMRateOfSale]
		FROM #itemtotals t
		LEFT JOIN #lastStoreItemReq lq
			ON lq.itemcode = right('00000000000000' + t.reorderitemcode, 20)
				AND lq.locationno = t.locationno
		LEFT JOIN #shipQty sq
			ON sq.itemcode = right('00000000000000' + t.reorderitemcode, 20)
				AND sq.locationno = t.locationno
		LEFT JOIN #PendingXref px
			ON px.itemcode = t.ReorderItemCode
				AND px.locationno = t.LocationNo
				AND px.ISBN = t.ISBN
		LEFT JOIN #salesXref sx
			ON sx.ReorderItemCode = t.ReorderItemCode
				AND sx.LocationNo = t.LocationNo
				AND sx.ISBN = t.ISBN
		LEFT JOIN #ISBNsales isx
			ON isx.LocationNo = t.LocationNo
				AND isx.ISBN = t.ISBN
		LEFT JOIN ReportsData..TeaserSalesRank sr WITH (NOLOCK)
			ON sr.itemcode = t.reorderitemcode
				AND sr.StoreNo = t.locationno
		LEFT JOIN ReportsData..TeaserSIPSQOH sip
			ON t.ISBN = sip.ISBN
				AND t.LocationNo = sip.LocationNo
		LEFT JOIN ReportsData..TeaserSectionQOH soh
			ON t.LocationNo = soh.LocationNo
				AND t.SectionCode = soh.SectionCode
		GROUP BY t.locationno ,t.district ,t.locationid ,t.title ,t.reorderitemcode ,t.PreviousItems ,t.vendorid ,t.SectionCode ,t.itemcodecount ,t.cost ,t.price ,t.initialstoredate ,t.initialqty ,t.soldinperiod ,t.totalsold ,t.qtyonhand ,t.transferredout ,t.lastsaledate ,t.totalrcvd ,isnull(t.lastreorderdate, t.InitialStoreDate) ,t.pending ,t.markdowns ,t.RO_CNT ,t.isbn ,t.xrefqty ,t.NextOrderDate ,t.CaseQty ,isnull(sr.rank, 'NA / NA / NA / NA') ,isnull(sip.SIPSQOH, 0) ,ISNULL(px.qtypendingXref, 0) ,ISNULL(sx.sold, 0) ,isnull(isx.ISBNSold, 0)

	/*****************************************************************************************************************************************************************
CLEANING UP TEMP TABLES 
*****************************************************************************************************************************************************************/
	DROP TABLE #itemtotals
	DROP TABLE #curreorderables
	DROP TABLE #reorderables
	DROP TABLE #pending
	DROP TABLE #allsales
	DROP TABLE #locxref
	DROP TABLE #totalxref
	DROP TABLE #xref
	DROP TABLE #locs
	DROP TABLE #totals
	DROP TABLE #rVendors
	DROP TABLE #lastStoreItemReq
	DROP TABLE #shipQty
	DROP TABLE #upcItems
	DROP TABLE #PendingXref
	DROP TABLE #vendxref
	DROP TABLE #salesXref
	DROP TABLE #ISBNsales
	DROP TABLE #chkXref
END
GO