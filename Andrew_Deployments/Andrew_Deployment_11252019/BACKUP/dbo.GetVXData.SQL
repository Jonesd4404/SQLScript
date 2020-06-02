USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[GetVXData]    Script Date: 11/25/2019 9:38:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B>
-- Create date: <10/24/2012>
-- Description:	<Returns reorder data to VX application>
-- =============================================
CREATE PROCEDURE [dbo].[GetVXData]
 	 @Vendors NVARCHAR(MAX)
	,@SectionCodes NVARCHAR(MAX)
	,@SectionX BIT
	,@Stores NVARCHAR(MAX)
	,@StoreX BIT
	,@Tags NVARCHAR(MAX)
	,@TagX BIT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TEASER_WORK_TBL]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE #TEASER_WORK_TBL

	CREATE TABLE #TEASER_WORK_TBL
	(
		 [RowID] INT IDENTITY(1,1)
		,[LocationNo] CHAR(5) NULL
		,[District] VARCHAR(30) NULL
		,[Title] VARCHAR(250) NULL
		,[ItemCode] VARCHAR(20) NULL
		,[PreviousItemCodes] VARCHAR(100)
		,[ReorderItemCode] VARCHAR(10) NULL
		,[VendorID] VARCHAR(20) NULL
		,[SectionCode] VARCHAR(20) NULL
		,[ItemCodeCount] INT NULL
		,[Cost] MONEY NULL
		,[Price] MONEY NULL
		,[InitialStoreDate] DATETIME NULL
		,[InitialQty] INT NULL
		,[QtyOnHand] INT NULL
		,[TotalRcvd] INT NULL
		,[LastReorderDate] DATETIME NULL
		,[Pending] INT NULL
		,[RO_CNT] INT NULL
		,[LastQty] INT NULL
		,[ShipQty] INT NULL
		,[ISBN] VARCHAR(20) NULL
		,[XRefQty] INT NULL
		,[LocationID] CHAR(10) NOT NULL
		,[SuggestedOrderQty] INT NULL
		,[Markdowns] INT NULL
		,[LastSaleDate] DATETIME NULL
		,[TransferredOut] INT NULL
		,[SoldInPeriod] INT NULL
		,[TotalSold] INT NULL
		,[NextOrderDate] DATETIME NULL
		,[CaseQty] INT NULL
		,[RateOfSale] NUMERIC(9,4) NULL
		,[PercentSold] NUMERIC(9,2) NULL
		,[SalesRank] VARCHAR (30) NULL
		,[XRefs] VARCHAR (10) NULL
		,[PendXRef] INT NULL
		,[SoldXRef] INT NULL
		,[ISBNSold] INT NULL) ON [PRIMARY]

	CREATE  CLUSTERED  INDEX [IDX_TEASER_RU] ON #TEASER_WORK_TBL ([LocationID], [ItemCode], [ReorderItemCode])
	CREATE  NONCLUSTERED  INDEX [IDX_TEASER_RU1] ON #TEASER_WORK_TBL ([LocationNo], [ItemCode], [ReorderItemCode])
	CREATE  NONCLUSTERED  INDEX [IDX_TEASER_RU2] ON #TEASER_WORK_TBL ([VendorID], [District], [LocationNo])

	----Create temp tables to store parameter values....................
	CREATE TABLE #tmpVendors(VendorID varchar(30))
	CREATE TABLE #tmpSections(Sections varchar(30))
	CREATE TABLE #tmpStores(Stores varchar(30))
	
	INSERT INTO #tmpVendors
		SELECT sID 
		FROM dbo.FN_STOC_ListStringToTable(@Vendors)
		GROUP BY sID
	INSERT INTO #tmpSections
		SELECT sID 
		FROM dbo.FN_STOC_ListStringToTable(@SectionCodes)
		GROUP BY sID
	INSERT INTO #tmpStores
		SELECT sID 
		FROM dbo.FN_STOC_ListStringToTable(@Stores)
		GROUP BY sID
	----.................................................................

	----Build query string based on parameter inputs..............................................................
	DECLARE	 @QueryString NVARCHAR(MAX)
			,@WhereClause NVARCHAR(MAX)
			,@SectionClause NVARCHAR(MAX)
			,@StoreClause NVARCHAR(MAX)
			,@TagClause NVARCHAR(MAX)

	SELECT	 @QueryString = 'INSERT INTO #TEASER_WORK_TBL SELECT r.LocationNo,r.District,r.Title,RIGHT(REPLICATE(''0'',20) + r.ItemCode, 20) AS [ItemCode]' +
							',r.PreviousItemCodes,r.ReorderItemCode,r.VendorID,r.SectionCode,r.ItemCodeCount,r.Cost,r.Price,r.InitialStoreDate,r.InitialQty' +
							',r.QtyOnHand,r.TotalRcvd,r.LastReorderDate,r.Pending,r.RO_CNT,r.LastQty,r.ShipQty,r.ISBN,r.XRefQty,r.LocationID,r.SuggestedOrderQty' +
							',r.markdowns,r.LastSaleDate,r.TransferredOut,r.SoldInPeriod,r.TotalSold,r.NextOrderDate,r.CaseQty,r.RateOfSale,r.PercentSold,' +
							'r.SalesRank,(CAST(r.XrefQty as varchar(5))+ '' / '' + CAST(r.SIPSQOH as varchar(5))),ISNULL(r.PendXref,0),ISNULL(r.SoldXref,0),ISNULL(r.ISBNSold,0) ' +
							'FROM dbo.STOC_TeaserData r WITH (NOLOCK) '
			,@WhereClause = ' WHERE r.vendorid in (SELECT VendorID FROM #tmpVendors) '

	IF @SectionX = 0 
		BEGIN 
			SET @SectionClause = ' AND r.sectioncode IN (SELECT Sections FROM #tmpSections) '
		END
	ELSE
		BEGIN
			SET @SectionClause = ' AND r.sectioncode NOT IN (SELECT Sections FROM #tmpSections) '
		END
		
	IF @StoreX = 0
		BEGIN
			SET @StoreClause = ' AND r.locationno IN (SELECT Stores FROM #tmpStores) '
		END
	ELSE
		BEGIN
			SET @StoreClause = ' AND r.locationno not IN (SELECT Stores FROM #tmpStores) '
		END
		
	IF @TagX = 0
		BEGIN
			SET @TagClause = ''
		END
	ELSE
		BEGIN
			SET @TagClause = ''
		END
	
	SET @QueryString = @QueryString + @WhereClause + @SectionClause + @StoreClause
	----....................................................................................................................

	--select @QueryString 
	EXECUTE sp_executeSQL @QueryString 
	--select * from #TEASER_WORK_TBL
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
			,CASE LEN(CAST(SUM(ISNULL(twt.SoldInPeriod,0)) AS VARCHAR(6)))
				WHEN 1 THEN '  '
				WHEN 2 THEN ' ' 
				ELSE '' 
			 END + CAST(SUM(ISNULL(twt.SoldInPeriod,0)) AS VARCHAR(6))+' / '+ CAST(SUM(ISNULL(twt.SoldXref,0)) AS VARCHAR(6)) AS [Sold-SLO]
			,twt.ISBNSold
			,SUM(ISNULL(twt.QtyOnHand,0)) AS [QtyOnHand]
			,CASE LEN(LEFT(twt.XRefs,CHARINDEX('/',twt.XRefs)-1))
				WHEN 1 THEN '  '+twt.XRefs
				WHEN 2 THEN ' ' +twt.XRefs
				ELSE twt.XRefs 
			 END AS [XRefs]
			,CASE LEN(CAST(SUM(twt.Pending)as varchar(10)))
				WHEN 1 THEN '  '
				WHEN 2 THEN ' ' 
				ELSE ''
			 END +CAST(SUM(twt.Pending) AS VARCHAR(10))+' / '+ CAST(SUM(twt.PendXRef) AS VARCHAR(10)) AS [EnRoute]
			,CASE WHEN EXISTS(SELECT VendorID FROM [HPB_Prime].[dbo].[VendorMaster] WHERE VendorID = twt.VendorID AND UserChar30 = 'TTBReorder') 
				THEN
					CASE WHEN SUM(ISNULL(twt.LastQty,0))=SUM(ISNULL(twt.ShipQty,0)) AND SUM(ISNULL(twt.Pending,0))=0 AND SUM(ISNULL(twt.TotalRcvd,0))<>0 
						THEN CASE WHEN (SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0)))<= 0 
								  THEN 0 
								  ELSE CASE WHEN (SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0))) < SUM(ISNULL(waq.QtyOnHand ,0)) 
											THEN SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0)) 
											ELSE SUM(ISNULL(waq.QtyOnHand ,0)) 
									   END 
							 END
								 WHEN SUM(ISNULL(twt.ShipQty,0))=0 OR SUM(ISNULL(twt.Pending,0))<>0 
								 THEN 0 
								 ELSE CASE WHEN SUM(ISNULL(twt.SoldInPeriod,0)) > SUM(ISNULL(waq.QtyOnHand ,0)) 
										   THEN SUM(ISNULL(waq.QtyOnHand ,0)) 
										   ELSE SUM(ISNULL(twt.SoldInPeriod,0)) 
									  END 
					END 
			  ELSE 
					CASE WHEN SUM(ISNULL(twt.LastQty,0))=SUM(ISNULL(twt.ShipQty,0)) AND SUM(ISNULL(twt.Pending,0))=0 AND SUM(ISNULL(twt.TotalRcvd,0))<>0 
						 THEN CASE WHEN (SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0)))<= 0 
								   THEN 0 
								   ELSE (SUM(ISNULL(twt.InitialQty,0)) - SUM(ISNULL(twt.QtyOnHand,0))) 
							  END
						  WHEN SUM(ISNULL(twt.ShipQty,0))=0 OR SUM(ISNULL(twt.Pending,0))<>0 
						  THEN 0 
						  ELSE SUM(ISNULL(twt.SoldInPeriod,0)) 
				    END 
			 END AS [SuggestedQty]
			,SUM(ISNULL(srd.requestedQty,0)) AS [OnOrderQty]
			,ISNULL(SUM(ISNULL(waq.QtyOnHand ,0))- ISNULL((SELECT ISNULL(OnOrdQty,0) FROM dbo.FN_VX_GetOnOrdQty_ByWhse(twt.VendorID,twt.ReorderItemCode,twt.LocationNo)),0),0) AS [AvailableQty]
			,SUM(ISNULL(srd.ConfirmedQty,0)) AS [ConfirmedQty]
			,SUM(ISNULL(srd.CanceledQty,0)) AS [CanceledQty]
			,SUM(ISNULL(srd.BackOrderQty,0))[BackOrderQty]
			--,ISNULL(srd.AllowBackOrder,0) as [BackOrder?]
			,CASE WHEN SUM(ISNULL(srd.requestedQty,0))>0 
				  THEN ISNULL(srd.AllowBackOrder,0) 
				  ELSE ISNULL(ev.DftBackOrd,0)
			 END AS [BackOrder?]
			,twt.VendorID
			,twt.SectionCode
			,ISNULL('','') AS [ItemTags]
			,CASE WHEN l.Active = 'N' 
				  THEN 'NA' 
				  ELSE ISNULL(src.PONumber,'NA') 
			 END AS[CurrentPONo]
			,ISNULL(src.RequisitionDueDate,'1900/01/01')[RequisitionDueDate]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.RequisitionNo,'NA') end [CurrentReqNo]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss.statusname,'NA') end[ReqStatus]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss2.statusname,'NA') end[LineStatus]
			,ISNULL(src.Locked,'N')[ReqLock],ISNULL(src.LockedBy,'')[ReqLockBy],ISNULL(twt.ISBN,'')[VendorItem]
			--,CASE WHEN (select count(distinct isbnupc) from vwVX_BT_AvailQty where ISBNUPC = twt.ISBN)= 0 then 'X' else '' end [ValidItem]
			,CASE twt.VendorID
				--WHEN  'IIDB&TDISTR' THEN CASE WHEN (SELECT COUNT(ISBNUPC) FROM vwVX_BT_ValidItem WHERE ISBNUPC = twt.ISBN GROUP BY ISBNUPC)= 0 THEN 'X' ELSE '' END
				WHEN  'IDINGRAMDI'  THEN CASE WHEN (SELECT COUNT(ISBNUPC) FROM vwVX_IC_ValidItem WHERE ISBNUPC = twt.ISBN GROUP BY ISBNUPC)= 0 THEN 'X' ELSE '' END
				ELSE ''
			 END AS [ValidItem]
	FROM #TEASER_WORK_TBL twt 
		LEFT JOIN dbo.VX_Reorder_Control src 
			ON twt.VendorID = src.VendorID 
				AND twt.LocationNo = src.StoreNo
		LEFT JOIN dbo.VX_Requisition_Dtl srd 
			ON src.requisitionno = srd.requisitionno 
				AND srd.itemcode = RIGHT(REPLICATE('0',20)+twt.ReorderItemCode,20)
		LEFT JOIN dbo.VX_Status ss 
			ON src.[Status] = ss.statuscode
		LEFT JOIN VX_Status ss2 
			ON ISNULL(srd.[Status],CASE WHEN ISNULL(src.[Status],100) > 20 THEN src.[Status] ELSE 10 END) = ss2.statuscode
		LEFT JOIN dbo.vwVX_IC_AvailQty waq 
			ON waq.ISBNUPC = twt.ISBN 
				AND waq.Warehouse = src.Warehouse
		LEFT JOIN dbo.VX_Locations l 
			ON twt.LocationNo = l.LocationNo
		LEFT JOIN [HPB_EDI].[dbo].[Vendor_SAN_Codes] ev 
			ON twt.VendorID=ev.VendorID
	GROUP BY twt.RowID,twt.LocationNo,twt.District,twt.Title,twt.Cost,twt.Price,twt.ReorderItemCode,twt.VendorID,twt.SectionCode,twt.Cost,twt.Price,twt.ISBNSold,twt.ISBN
			,twt.NextOrderDate,twt.CaseQty,twt.RateOfSale,twt.PercentSold,twt.SalesRank,twt.XRefs,ISNULL(src.RequisitionDueDate,'1900/01/01')
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.PONumber,'NA')  END, CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.RequisitionNo,'NA') END
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss.statusname,'NA') END, CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss2.statusname,'NA') END
			,ISNULL(src.Locked,'N'),ISNULL(src.LockedBy,''),ISNULL(srd.AllowBackOrder,0), ISNULL(ev.DftBackOrd,0)
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
		LEFT JOIN dbo.VX_Reorder_Control src 
			ON twt.VendorID = src.VendorID 
				AND twt.LocationNo = src.StoreNo
		LEFT JOIN dbo.VX_Requisition_Dtl srd
			ON src.requisitionno = srd.requisitionno 
				AND srd.itemcode = RIGHT(REPLICATE('0',20)+twt.ReorderItemCode,20)
		LEFT JOIN dbo.VX_Status ss 
			ON src.[Status] = ss.statuscode
		-- LEFT JOIN vwVX_BT_AvailQty waq ON waq.ISBNUPC = twt.ISBN and waq.Warehouse = src.Warehouse
		LEFT JOIN dbo.vwVX_IC_AvailQty waq 
			ON waq.ISBNUPC = twt.ISBN
				AND waq.Warehouse = src.Warehouse
	GROUP by twt.RowID,twt.LocationNo,twt.District,twt.Title,twt.Cost,twt.Price,twt.ReorderItemCode,twt.VendorID,twt.SectionCode,twt.Cost,twt.Price,twt.ISBNSold,twt.ISBN
			,twt.NextOrderDate,twt.CaseQty,twt.RateOfSale,twt.PercentSold,twt.SalesRank,twt.XRefs,ISNULL(src.RequisitionDueDate,'1900/01/01')
			,ISNULL(src.RequisitionNo,'NA'),ISNULL(ss.statusname,'NA'),ISNULL(src.Locked,'N'),ISNULL(src.LockedBy,'')
	ORDER BY twt.title,twt.District,twt.LocationNo

	--/*****************************************************************************************************************************************************************
	--***CLEAN UP.....
	--*****************************************************************************************************************************************************************/
	DROP TABLE #TEASER_WORK_TBL
	DROP TABLE #tmpVendors
	DROP TABLE #tmpSections
	DROP TABLE #tmpStores
END
-----------------------------------------------------------------------------------------------------------------

GO

