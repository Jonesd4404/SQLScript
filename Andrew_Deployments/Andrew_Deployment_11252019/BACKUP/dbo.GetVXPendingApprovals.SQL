USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[GetVXPendingApprovals]    Script Date: 11/25/2019 9:39:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B>
-- CREATE date: <10/29/2012>
-- Description:	<Returns pending approval order data to VX application>
-- =============================================
CREATE PROCEDURE [dbo].[GetVXPendingApprovals]
	 @Vendors NVARCHAR(MAX)
	,@SectionCodes NVARCHAR(MAX)
	,@SectionX bit
	,@Stores NVARCHAR(MAX)
	,@StoreX bit
	,@Tags NVARCHAR(MAX)
	,@TagX bit
AS
BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[TEASER_WORK_TBL]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE #TEASER_WORK_TBL
	CREATE TABLE #TEASER_WORK_TBL
	(
		 [RowID] INT IDENTITY(1,1)
		,[LocationNo] [char](5) NULL
		,[District] VARCHAR(30) NULL
		,[Title] VARCHAR(250) NULL
		,[ItemCode] VARCHAR(20) NULL
		, [PreviousItemCodes] VARCHAR(100),[ReorderItemCode] VARCHAR(10) NULL,[VendorID] VARCHAR(20) NULL,[SectionCode] VARCHAR(20) NULL,[ItemCodeCount] INT NULL,
		[Cost] MONEY NULL,[Price] MONEY NULL,[InitialStoreDate] DATETIME NULL,[InitialQty] INT NULL,[QtyOnHand] INT NULL,[TotalRcvd] INT NULL,[LastReorderDate] DATETIME NULL,
		[Pending] INT NULL,[RO_CNT] INT NULL,[LastQty] INT NULL,[ShipQty] INT NULL,[ISBN] VARCHAR(20) NULL,[XRefQty] INT NULL, [LocationID] [char](10) NOT NULL,
		[SuggestedOrderQty] INT NULL,[Markdowns] INT NULL,[LastSaleDate] DATETIME NULL,[TransferredOut] INT NULL,[SoldInPeriod] INT NULL,[TotalSold] INT NULL,[NextOrderDate] DATETIME NULL,[CaseQty] INT NULL,[RateOfSale] [numeric](9,4) NULL,[PercentSold] [numeric](9,2) NULL,[SalesRank] VARCHAR(30) NULL, [XRefs] VARCHAR(10) NULL, [PendXRef] INT NULL, [SoldXRef] INT NULL, [ISBNSold] INT NULL) ON [PRIMARY]

	CREATE  CLUSTERED  INDEX [IDX_TEASER_RU] ON #TEASER_WORK_TBL ([LocationID], [ItemCode], [ReorderItemCode])
	CREATE  NONCLUSTERED  INDEX [IDX_TEASER_RU1] ON #TEASER_WORK_TBL ([LocationNo], [ItemCode], [ReorderItemCode])
	CREATE  NONCLUSTERED  INDEX [IDX_TEASER_RU2] ON #TEASER_WORK_TBL ([VendorID], [District], [LocationNo])

	--DECLARE @Vendors NVARCHAR(MAX),@Stores NVARCHAR(MAX)
	--DECLARE @StoreX int = 0

	--SET @Vendors =  'IDHARPERDI'--'IDTEXASBOO, IDTXBMARKD, IDTXBKAUDI, IDTXBKSOFT, IDTXBKSTAP' --'IDCROWNPOI, IDCROWNB&C'
	--SET @Stores = '00001,00002'


	----CREATE temp tables to store parameter values....................
	CREATE table #tmpVendors(VendorID VARCHAR(30))
	INSERT into #tmpVendors
	SELECT distinct sID FROM dbo.FN_STOC_ListStringToTable (@Vendors)
	CREATE table #tmpStores(Stores VARCHAR(30))
	INSERT into #tmpStores
	SELECT distinct sID FROM dbo.FN_STOC_ListStringToTable (@Stores)
	----.................................................................

	----Build query string based ON parameter inputs..............................................................
	DECLARE @QueryString NVARCHAR(MAX),@WhereClause NVARCHAR(MAX), @StoreClause NVARCHAR(MAX)

	SET @QueryString = 'INSERT into #TEASER_WORK_TBL SELECT r.LocationNo,r.District,r.Title,RIGHT(''00000000000000000000'' + r.ItemCode, 20)[ItemCode],r.PreviousItemCodes,r.ReorderItemCode,r.VendorID,r.SectionCode,r.ItemCodeCount,r.Cost,r.Price,r.InitialStoreDate,r.InitialQty,r.QtyOnHand,r.TotalRcvd,r.LastReorderDate,r.Pending,r.RO_CNT,r.LastQty,r.ShipQty,r.ISBN,r.XRefQty,r.LocationID,r.SuggestedOrderQty,r.markdowns,r.LastSaleDate,r.TransferredOut,r.SoldInPeriod,r.TotalSold,r.NextOrderDate,r.CaseQty,r.RateOfSale,r.PercentSold,r.SalesRank,(CAST(r.XrefQty AS VARCHAR(5))+ '' / '' + CAST(r.SIPSQOH AS VARCHAR(5))),ISNULL(r.PendXref,0),ISNULL(r.SoldXref,0),ISNULL(r.ISBNSold,0) FROM dbo.STOC_TeaserData r with (nolock) '
	SET @WhereClause = ' WHERE r.vendorid IN (SELECT distinct VendorID FROM #tmpVendors) '

	IF @StoreX = 0
		BEGIN
			SET @StoreClause = ' AND r.locationno IN (SELECT distinct Stores FROM #tmpStores) '
		END
	ELSE
		BEGIN
			SET @StoreClause = ' AND r.locationno NOT IN (SELECT distinct Stores FROM #tmpStores) '
		END

	SET @QueryString = @QueryString + @WhereClause + @StoreClause
	----....................................................................................................................

	--SELECT @QueryString 
	EXECUTE sp_executeSQL @QueryString 
	--SELECT * FROM #TEASER_WORK_TBL

	DECLARE @QueryString2 NVARCHAR(MAX)

	SET @QueryString2 = 'INSERT into #TEASER_WORK_TBL ' +
						'SELECT sh.LocationNo,l.DistrictCode,pm.Title,pm.ItemCode,'''' AS [PreviousItemCodes],RIGHT(sd.ItemCode,8) AS [ReorderItemCode] ' +
						',CASE WHEN ISNULL(pm.PurchaseFromVendorID,'''')='''' THEN pm.VendorID ELSE pm.PurchaseFromVendorID END AS [VendorID],pm.SectionCode ' +
						',1 AS [ItemCodeCount],pm.Cost,pm.Price, '''' AS [InitialStoreDate],0 AS [InitialQty],0 AS [QtyOnHand],0 AS [TotalRcvd] ' +
						','''' AS [LastReorderDate],0 AS [Pending],0 AS [RO_CNT],0 AS [LastQty],0 AS [ShipQty],pm.ISBN,0 AS [XRefQty],l.LocationID ' +
						',0 AS [SuggestedOrderQty], 0 AS [markdowns],'''' AS [LastSaleDate],0 AS [TransferredOut],0 AS [SoldInPeriod],0 AS [TotalSold] ' +
						','''' AS [NextOrderDate],pmd.UnitsPerCase AS [CaseQty],0 AS [RateOfSale],0 AS [PercentSold],''NA / NA / NA / NA'' AS [SalesRank] ' +
						',''0 / 0'' AS [XRefs],0 AS [PendXRef],0 AS [SoldXRef],0 AS [ISBNSold] ' +
						'FROM VX_Reorder_Control src WITH(NOLOCK) ' +
						'INNER JOIN VX_Requisition_Dtl sd WITH (NOLOCK) ON src.RequisitionNo=sd.RequisitionNo ' +
						'INNER JOIN VX_Requisition_Hdr sh WITH(NOLOCK) ON sd.RequisitionNo=sh.RequisitionNo ' + 
						'INNER JOIN [HPB_Prime].[dbo].[Locations] l with(nolock) ON l.LocationNo=src.StoreNo ' + 
						'INNER JOIN [HPB_Prime].[dbo].[ProductMaster] pm with(nolock) ON pm.ItemCode=sd.ItemCode ' +
						'INNER JOIN [HPB_Prime].[dbo].[ProductMasterDist] pmd with(nolock) ON pmd.ItemCode=pm.ItemCode ' +
						'WHERE sh.Status BETWEEN 20 AND 60 AND sd.requestedqty > 0 ' +
						'AND sd.ItemCode NOT IN (SELECT RIGHT(REPLICATE(''0'',20) + ReorderItemCode, 20) FROM #TEASER_WORK_TBL) ' +
						'AND sh.VendorID IN (SELECT VendorID FROM #tmpVendors) ' +
						REPLACE(@StoreClause,'r.','sh.') 
	EXECUTE sp_executeSQL @QueryString2 
	--SELECT * FROM #TEASER_WORK_TBL
	/*****************************************************************************************************************************************************************
	***GET DATA FROM ROLL-UP TABLE BASED ON PARAMETERS....
	*****************************************************************************************************************************************************************/
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT	 twt.RowID
			,twt.LocationNo
			,twt.District
			,twt.ReorderItemCode
			,twt.Title
			,twt.Cost
			,twt.Price
			,CASE len(CAST(SUM(ISNULL(twt.SoldInPeriod,0))AS VARCHAR(6)))	WHEN 1 THEN '  ' WHEN 2 THEN ' ' ELSE '' END + CAST(SUM(ISNULL(twt.SoldInPeriod,0))AS VARCHAR(6))+' / '+ CAST(SUM(ISNULL(twt.SoldXref,0))AS VARCHAR(6)) AS [Sold-SLO]
			,twt.ISBNSold
			,SUM(ISNULL(twt.QtyOnHand,0)) AS [QtyOnHand]
			,CASE LEN(LEFT(twt.XRefs,CHARINDEX('/',twt.XRefs)-1))			WHEN 1 THEN '  ' WHEN 2 THEN ' ' ELSE '' END + twt.XRefs AS [XRefs]
			,CASE len(CAST(SUM(twt.Pending)AS VARCHAR(10)))					WHEN 1 THEN '  ' WHEN 2 THEN ' ' ELSE '' END + CAST(SUM(twt.Pending)AS VARCHAR(10))+' / '+CAST(SUM(twt.PendXRef)AS VARCHAR(10)) AS [EnRoute]
			,CASE WHEN EXISTS(SELECT VendorID FROM [HPB_Prime].[dbo].[VendorMaster] WHERE VendorID = twt.VendorID AND UserChar30 = 'TTBReorder') 
			 THEN CASE WHEN SUM(ISNULL(twt.LastQty,0))=SUM(ISNULL(twt.ShipQty,0)) AND SUM(ISNULL(twt.Pending,0))=0 AND SUM(ISNULL(twt.TotalRcvd,0))<>0 THEN CASE WHEN (SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0)))<= 0 THEN 0 ELSE CASE WHEN (SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0))) < SUM(ISNULL(waq.QtyOnHand ,0)) THEN SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0)) ELSE SUM(ISNULL(waq.QtyOnHand ,0)) END END
				WHEN SUM(ISNULL(twt.ShipQty,0))=0 or SUM(ISNULL(twt.Pending,0))<>0 THEN 0 ELSE CASE WHEN SUM(ISNULL(twt.SoldInPeriod,0)) > SUM(ISNULL(waq.QtyOnHand ,0)) THEN SUM(ISNULL(waq.QtyOnHand ,0)) ELSE SUM(ISNULL(twt.SoldInPeriod,0)) END END 
			 ELSE 
			 CASE WHEN SUM(ISNULL(twt.LastQty,0))=SUM(ISNULL(twt.ShipQty,0)) AND SUM(ISNULL(twt.Pending,0))=0 AND SUM(ISNULL(twt.TotalRcvd,0))<>0 THEN CASE WHEN (SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0)))<= 0 THEN 0 ELSE (SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0))) END
				WHEN SUM(ISNULL(twt.ShipQty,0))=0 or SUM(ISNULL(twt.Pending,0))<>0 THEN 0 ELSE SUM(ISNULL(twt.SoldInPeriod,0)) END 
			 END AS [SuggestedQty]
			,SUM(ISNULL(srd.requestedQty,0))[OnOrderQty]
			,ISNULL(SUM(ISNULL(waq.QtyOnHand ,0))- ISNULL((SELECT ISNULL(OnOrdQty,0) FROM dbo.FN_VX_GetOnOrdQty_ByWhse(twt.VendorID,twt.ReorderItemCode,twt.LocationNo)),0),0)[AvailableQty]
			,SUM(ISNULL(srd.ConfirmedQty,0))[ConfirmedQty]
			,SUM(ISNULL(srd.CanceledQty,0))[CanceledQty]
			,SUM(ISNULL(srd.BackOrderQty,0))[BackOrderQty]
			--,ISNULL(srd.AllowBackOrder,0) AS [BackOrder?]
			,CASE WHEN SUM(ISNULL(srd.requestedQty,0))>0 THEN ISNULL(srd.AllowBackOrder,0) ELSE ISNULL(ev.DftBackOrd,0)END AS [BackOrder?]
			,twt.VendorID
			,twt.SectionCode
			,ISNULL('','') AS [ItemTags]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.PONumber,'NA') END AS[CurrentPONo]
			,ISNULL(src.RequisitionDueDate,'1900/01/01')[RequisitionDueDate]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.RequisitionNo,'NA') END AS [CurrentReqNo]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss.statusname,'NA') END AS [ReqStatus]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss2.statusname,'NA') END AS [LineStatus]
			,ISNULL(src.Locked,'N')[ReqLock],ISNULL(src.LockedBy,'')[ReqLockBy],ISNULL(twt.ISBN,'') AS [VendorItem]
			,'' AS [ValidItem]
	FROM #TEASER_WORK_TBL twt 
		INNER JOIN VX_Reorder_Control src 
			ON twt.VendorID = src.VendorID AND twt.LocationNo = src.StoreNo
		INNER JOIN VX_Requisition_Dtl srd 
			ON src.requisitionno = srd.requisitionno AND srd.itemcode = RIGHT('00000000000000'+twt.ReorderItemCode,20)
		INNER JOIN VX_Status ss 
			ON ISNULL(srd.Status,10) = ss.statuscode
		LEFT JOIN VX_Status ss2 
			ON ISNULL(srd.Status,CASE WHEN ISNULL(src.Status,100) > 20 THEN src.Status ELSE 10 END) = ss2.statuscode
		LEFT JOIN vwVX_IC_AvailQty waq 
			ON waq.ISBNUPC = twt.ISBN AND waq.Warehouse = src.Warehouse
		LEFT JOIN VX_Locations l 
			ON twt.LocationNo = l.LocationNo
		LEFT JOIN [HPB_EDI].[dbo].[Vendor_SAN_Codes] ev 
			ON twt.VendorID=ev.VendorID
	WHERE ss.StatusCode IN (40,98,99)
	GROUP BY twt.RowID,twt.LocationNo,twt.District,twt.Title,twt.Cost,twt.Price,twt.ReorderItemCode,twt.VendorID,twt.SectionCode,twt.Cost,twt.Price,twt.ISBNSold,twt.ISBN
			,twt.NextOrderDate,twt.CaseQty,twt.RateOfSale,twt.PercentSold,twt.SalesRank,twt.XRefs,ISNULL(src.RequisitionDueDate,'1900/01/01')
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.PONumber,'NA')  END, CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.RequisitionNo,'NA') END
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss.statusname,'NA') END, CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss2.statusname,'NA') END
			,ISNULL(src.Locked,'N'),ISNULL(src.LockedBy,''), ISNULL(srd.AllowBackOrder,0), ISNULL(ev.DftBackOrd,0)
	ORDER BY twt.title,twt.District,twt.LocationNo

	SELECT	 twt.RowID
			,'' AS [LocationNo]
			,'' AS [District]
			,'' AS [ReorderItemCode]
			,'' AS [PreviousItemCodes]
			,'' AS [PercentSold-PY]
			,'' AS [Markdowns-SLO]
			,'' AS [Transfers-SLO]
			,'' AS [ISBN/UPC]
			,'' AS [LastSaleDate]
			,'' AS [Weekly-ROS]
			,'' AS [InitialStoreDate]
			,'' AS [InitialQty]
			,'' AS [LastReorderDate]
			,'' AS [LastQty]
			,'' AS [CaseQty]
			,'' AS [ShipQty-SLO]
			,'' AS [RequisitionDueDate]
			,'' AS [SalesRank]
	FROM #TEASER_WORK_TBL twt 
		INNER JOIN VX_Reorder_Control src  
			ON twt.VendorID = src.VendorID AND twt.LocationNo = src.StoreNo
		INNER JOIN VX_Requisition_Dtl srd  
			ON src.requisitionno = srd.requisitionno AND srd.itemcode = RIGHT('00000000000000'+twt.ReorderItemCode,20)
		INNER JOIN VX_Status ss 
			ON ISNULL(srd.Status,10) = ss.statuscode
		LEFT JOIN vwVX_IC_AvailQty waq 
			ON waq.ISBNUPC = twt.ISBN AND waq.Warehouse = src.Warehouse
	WHERE ss.StatusCode IN (40,98,99)
	GROUP BY twt.RowID,twt.LocationNo,twt.District,twt.Title,twt.Cost,twt.Price,twt.ReorderItemCode,twt.VendorID,twt.SectionCode,twt.Cost,twt.Price,twt.ISBNSold,twt.ISBN
			,twt.NextOrderDate,twt.CaseQty,twt.RateOfSale,twt.PercentSold,twt.SalesRank,twt.XRefs,ISNULL(src.RequisitionDueDate,'1900/01/01'),ISNULL(src.RequisitionNo,'NA')
			,ISNULL(ss.statusname,'NA'),ISNULL(src.Locked,'N'),ISNULL(src.LockedBy,'')
	ORDER BY twt.title,twt.District,twt.LocationNo

	--/*****************************************************************************************************************************************************************
	--***CLEAN UP.....
	--*****************************************************************************************************************************************************************/
	DROP TABLE #TEASER_WORK_TBL
	DROP TABLE #tmpVendors
	DROP TABLE #tmpStores
END

GO

