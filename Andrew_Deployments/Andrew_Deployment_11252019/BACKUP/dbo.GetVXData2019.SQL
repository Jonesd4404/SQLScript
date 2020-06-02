USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[GetVXData2019]    Script Date: 11/25/2019 9:38:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B>
-- Create date: <10/24/2012>
-- Description:	<Returns reorder data to VX application>
-- =============================================
CREATE PROCEDURE [dbo].[GetVXData2019]
(
	 @Vendors AS dbo.TypeListString25 READONLY
	,@SectionCodes AS dbo.TypeListString250 READONLY
	,@SectionX BIT
	,@Stores AS dbo.TypeListString25 READONLY
	,@StoreX BIT
	,@Tags AS dbo.TypeListString25 READONLY
	,@TagX BIT
)
AS
BEGIN
	DECLARE 
		 @TWENTYZEROS VARCHAR(20) = REPLICATE('0',20)
		,@SECCOUNT INT

	IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[TEASER_WORK_TBL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		DROP TABLE #TEASER_WORK_TBL

	CREATE TABLE #TEASER_WORK_TBL
	(
		 [RowID] INT IDENTITY(1,1)
		,[LocationNo] CHAR(5) 
		,[District] VARCHAR(30) 
		,[Title] VARCHAR(250) 
		,[ItemCode] VARCHAR(20) 
		,[PreviousItemCodes] VARCHAR(100)
		,[ReorderItemCode] VARCHAR(10) 
		,[VendorID] VARCHAR(20) 
		,[SectionCode] VARCHAR(20) 
		,[ItemCodeCount] INT 
		,[Cost] MONEY 
		,[Price] MONEY 
		,[InitialStoreDate] DATETIME 
		,[InitialQty] INT 
		,[QtyOnHand] INT 
		,[TotalRcvd] INT 
		,[LastReorderDate] DATETIME 
		,[Pending] INT
		,[RO_CNT] INT 
		,[LastQty] INT
		,[ShipQty] INT
		,[ISBN] VARCHAR(20) 
		,[XRefQty] INT 
		,[LocationID] CHAR(10) NOT NULL
		,[SuggestedOrderQty] INT 
		,[Markdowns] INT 
		,[LastSaleDate] DATETIME 
		,[TransferredOut] INT 
		,[SoldInPeriod] INT 
		,[TotalSold] INT
		,[NextOrderDate] DATETIME
		,[CaseQty] INT
		,[RateOfSale] NUMERIC(9,4) 
		,[PercentSold] NUMERIC(9,2) NULL
		,[SalesRank] VARCHAR(30) NULL
		,[XRefs] VARCHAR(10) NULL
		,[PendXRef] INT
		,[SoldXRef] INT
		,[ISBNSold] INT
	)
	CREATE  CLUSTERED  INDEX [IDX_TEASER_RU] ON #TEASER_WORK_TBL ([LocationID], [ItemCode], [ReorderItemCode])
	CREATE  NONCLUSTERED  INDEX [IDX_TEASER_RU1] ON #TEASER_WORK_TBL ([LocationNo], [ItemCode], [ReorderItemCode])
	CREATE  NONCLUSTERED  INDEX [IDX_TEASER_RU2] ON #TEASER_WORK_TBL ([VendorID], [District], [LocationNo])

	SELECT @SECCOUNT = COUNT(1) FROM @SectionCodes

	IF @SECCOUNT > 0
	BEGIN
		IF @StoreX = 0
			BEGIN
				INSERT INTO #TEASER_WORK_TBL (LocationNo, District, Title, ItemCode, PreviousItemCodes, ReorderItemCode, VendorID
											 ,SectionCode, ItemCodeCount, cost, Price, InitialStoreDate, InitialQty, QtyOnHand, TotalRcvd, LastReorderDate, Pending
											 ,RO_CNT, LastQty, ShipQty, ISBN, XRefQty, LocationID, SuggestedOrderQty, Markdowns, LastSaleDate, TransferredOut, SoldInPeriod
											 ,TotalSold,NextOrderDate,CaseQty,RateOfSale, PercentSold, SalesRank, xrefs, PendXRef, SoldXRef, ISBNSold)									
						SELECT	 r.LocationNo,r.District,r.Title,RIGHT(@TWENTYZEROS + r.ItemCode, 20) AS [ItemCode],r.PreviousItemCodes,r.ReorderItemCode,r.VendorID
								,r.SectionCode,r.ItemCodeCount,r.Cost,r.Price,r.InitialStoreDate,r.InitialQty,r.QtyOnHand,r.TotalRcvd,r.LastReorderDate,r.Pending
								,r.RO_CNT,r.LastQty,r.ShipQty,r.ISBN,r.XRefQty,r.LocationID,r.SuggestedOrderQty,r.markdowns,r.LastSaleDate,r.TransferredOut,r.SoldInPeriod
								,r.TotalSold,r.NextOrderDate,r.CaseQty,r.RateOfSale,r.PercentSold,r.SalesRank
								,(CAST(r.XrefQty AS VARCHAR(5))+ ' / ' + CAST(r.SIPSQOH AS VARCHAR(5))),ISNULL(r.PendXref,0),ISNULL(r.SoldXref,0),ISNULL(r.ISBNSold,0) 
						FROM dbo.STOC_TeaserData r 
							INNER JOIN @Vendors v
								ON CAST(LTRIM(RTRIM(v.Strings)) AS VARCHAR(20)) = r.VendorID
							INNER JOIN @Stores s
								ON CAST(LTRIM(RTRIM(s.Strings)) AS CHAR(5)) = r.LocationNo
						WHERE CASE 
									WHEN @StoreX = 0 AND r.locationNo     IN (SELECT Strings FROM @Stores GROUP BY Strings ) THEN 1
									WHEN @StoreX = 1 AND r.LocationNo NOT IN (SELECT Strings FROM @Stores GROUP BY Strings ) THEN 1
									ELSE 0
								END = 1
			END
		ELSE IF @StoreX = 1
			BEGIN
				INSERT INTO #TEASER_WORK_TBL (LocationNo, District, Title, ItemCode, PreviousItemCodes, ReorderItemCode, VendorID
											 ,SectionCode, ItemCodeCount, cost, Price, InitialStoreDate, InitialQty, QtyOnHand, TotalRcvd, LastReorderDate, Pending
											 ,RO_CNT, LastQty, ShipQty, ISBN, XRefQty, LocationID, SuggestedOrderQty, Markdowns, LastSaleDate, TransferredOut, SoldInPeriod
											 ,TotalSold,NextOrderDate,CaseQty,RateOfSale, PercentSold, SalesRank, xrefs, PendXRef, SoldXRef, ISBNSold)									
						SELECT	 r.LocationNo,r.District,r.Title,RIGHT(@TWENTYZEROS + r.ItemCode, 20) AS [ItemCode],r.PreviousItemCodes,r.ReorderItemCode,r.VendorID
								,r.SectionCode,r.ItemCodeCount,r.Cost,r.Price,r.InitialStoreDate,r.InitialQty,r.QtyOnHand,r.TotalRcvd,r.LastReorderDate,r.Pending
								,r.RO_CNT,r.LastQty,r.ShipQty,r.ISBN,r.XRefQty,r.LocationID,r.SuggestedOrderQty,r.markdowns,r.LastSaleDate,r.TransferredOut,r.SoldInPeriod
								,r.TotalSold,r.NextOrderDate,r.CaseQty,r.RateOfSale,r.PercentSold,r.SalesRank
								,(CAST(r.XrefQty AS VARCHAR(5))+ ' / ' + CAST(r.SIPSQOH AS VARCHAR(5))),ISNULL(r.PendXref,0),ISNULL(r.SoldXref,0),ISNULL(r.ISBNSold,0) 
						FROM dbo.STOC_TeaserData r 
							INNER JOIN @Vendors v
								ON CAST(LTRIM(RTRIM(v.Strings)) AS VARCHAR(20)) = r.VendorID
							LEFT JOIN @Stores s
								ON CAST(LTRIM(RTRIM(s.Strings)) AS CHAR(5)) = r.LocationNo
						WHERE s.Strings IS NULL
							AND CASE 
									WHEN @StoreX = 0 AND r.locationNo     IN (SELECT Strings FROM @Stores GROUP BY Strings ) THEN 1
									WHEN @StoreX = 1 AND r.LocationNo NOT IN (SELECT Strings FROM @Stores GROUP BY Strings ) THEN 1
									ELSE 0
								END = 1
			END
	END
	ELSE IF @SECCOUNT = 0
		IF @StoreX = 0
			BEGIN
				INSERT INTO #TEASER_WORK_TBL (LocationNo, District, Title, ItemCode, PreviousItemCodes, ReorderItemCode, VendorID
											,SectionCode, ItemCodeCount, cost, Price, InitialStoreDate, InitialQty, QtyOnHand, TotalRcvd, LastReorderDate, Pending
											,RO_CNT, LastQty, ShipQty, ISBN, XRefQty, LocationID, SuggestedOrderQty, Markdowns, LastSaleDate, TransferredOut, SoldInPeriod
											,TotalSold,NextOrderDate,CaseQty,RateOfSale, PercentSold, SalesRank, xrefs, PendXRef, SoldXRef, ISBNSold)
					SELECT	 r.LocationNo,r.District,r.Title,RIGHT(@TWENTYZEROS + r.ItemCode, 20) AS [ItemCode],r.PreviousItemCodes,r.ReorderItemCode,r.VendorID
							,r.SectionCode,r.ItemCodeCount,r.Cost,r.Price,r.InitialStoreDate,r.InitialQty,r.QtyOnHand,r.TotalRcvd,r.LastReorderDate,r.Pending
							,r.RO_CNT,r.LastQty,r.ShipQty,r.ISBN,r.XRefQty,r.LocationID,r.SuggestedOrderQty,r.markdowns,r.LastSaleDate,r.TransferredOut,r.SoldInPeriod
							,r.TotalSold,r.NextOrderDate,r.CaseQty,r.RateOfSale,r.PercentSold,r.SalesRank
							,(CAST(r.XrefQty AS VARCHAR(5))+ ' / ' + CAST(r.SIPSQOH AS VARCHAR(5))),ISNULL(r.PendXref,0),ISNULL(r.SoldXref,0),ISNULL(r.ISBNSold,0) 
					FROM dbo.STOC_TeaserData r 
						INNER JOIN @Vendors v
							ON CAST(LTRIM(RTRIM(v.Strings)) AS VARCHAR(20)) = r.VendorID
						INNER JOIN @Stores  s
							ON CAST(LTRIM(RTRIM(s.Strings)) AS CHAR(5)) = r.LocationNo
			END
		ELSE IF @StoreX = 1
			BEGIN
				INSERT INTO #TEASER_WORK_TBL (LocationNo, District, Title, ItemCode, PreviousItemCodes, ReorderItemCode, VendorID
											,SectionCode, ItemCodeCount, cost, Price, InitialStoreDate, InitialQty, QtyOnHand, TotalRcvd, LastReorderDate, Pending
											,RO_CNT, LastQty, ShipQty, ISBN, XRefQty, LocationID, SuggestedOrderQty, Markdowns, LastSaleDate, TransferredOut, SoldInPeriod
											,TotalSold,NextOrderDate,CaseQty,RateOfSale, PercentSold, SalesRank, xrefs, PendXRef, SoldXRef, ISBNSold)
					SELECT	 r.LocationNo,r.District,r.Title,RIGHT(@TWENTYZEROS + r.ItemCode, 20) AS [ItemCode],r.PreviousItemCodes,r.ReorderItemCode,r.VendorID
							,r.SectionCode,r.ItemCodeCount,r.Cost,r.Price,r.InitialStoreDate,r.InitialQty,r.QtyOnHand,r.TotalRcvd,r.LastReorderDate,r.Pending
							,r.RO_CNT,r.LastQty,r.ShipQty,r.ISBN,r.XRefQty,r.LocationID,r.SuggestedOrderQty,r.markdowns,r.LastSaleDate,r.TransferredOut,r.SoldInPeriod
							,r.TotalSold,r.NextOrderDate,r.CaseQty,r.RateOfSale,r.PercentSold,r.SalesRank
							,(CAST(r.XrefQty AS VARCHAR(5))+ ' / ' + CAST(r.SIPSQOH AS VARCHAR(5))),ISNULL(r.PendXref,0),ISNULL(r.SoldXref,0),ISNULL(r.ISBNSold,0) 
					FROM dbo.STOC_TeaserData r 
						INNER JOIN @Vendors v
							ON CAST(LTRIM(RTRIM(v.Strings)) AS VARCHAR(20)) = r.VendorID
						LEFT JOIN @Stores s
							ON CAST(LTRIM(RTRIM(s.Strings)) AS CHAR(5)) = r.LocationNo
					WHERE s.Strings IS NULL
			END

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
			,CASE LEN(CAST(SUM(ISNULL(twt.SoldInPeriod, 0)) AS VARCHAR(6)))
				WHEN 1 THEN '  '
				WHEN 2 THEN ' '
				ELSE ''
			 END + CAST(SUM(ISNULL(twt.SoldInPeriod, 0)) AS VARCHAR(6)) + ' / ' + CAST(SUM(ISNULL(twt.SoldXref, 0)) AS VARCHAR(6)) AS [Sold-SLO]
			,twt.ISBNSold
			,SUM(ISNULL(twt.QtyOnHand, 0)) AS [QtyOnHand]
			,CASE LEN(LEFT(twt.XRefs, CHARINDEX('/', twt.XRefs) - 1))
				WHEN 1 THEN '  '
				WHEN 2 THEN ' '
				ELSE ''
			 END + twt.XRefs AS [XRefs]
			,CASE LEN(CAST(SUM(twt.Pending) AS VARCHAR(10)))
				WHEN 1 THEN '  '
				WHEN 2 THEN ' ' 
				ELSE ''
			 END + CAST(SUM(twt.Pending) AS VARCHAR(10)) + ' / ' + CAST(SUM(twt.PendXRef) AS VARCHAR(10)) AS [EnRoute]
			,CASE 
				WHEN EXISTS (	SELECT VendorID
								FROM [HPB_Prime].[dbo].[VendorMaster]
								WHERE VendorID = twt.VendorID
									AND UserChar30 = 'TTBReorder' )
					THEN CASE 
							WHEN SUM(ISNULL(twt.LastQty, 0)) = SUM(ISNULL(twt.ShipQty, 0))
								AND SUM(ISNULL(twt.Pending, 0)) = 0
								AND SUM(ISNULL(twt.TotalRcvd, 0)) <> 0
								THEN CASE 
								WHEN (SUM(ISNULL(twt.InitialQty, 0)) - SUM(ISNULL(twt.QtyOnHand, 0))) <= 0
									THEN 0
									ELSE CASE WHEN (SUM(ISNULL(twt.InitialQty, 0)) - SUM(ISNULL(twt.QtyOnHand, 0))) < SUM(ISNULL(waq.QtyOnHand, 0))
												THEN SUM(ISNULL(twt.InitialQty, 0)) - SUM(ISNULL(twt.QtyOnHand, 0))
												ELSE SUM(ISNULL(waq.QtyOnHand, 0))
										END
								    END
								WHEN SUM(ISNULL(twt.ShipQty, 0)) = 0 OR SUM(ISNULL(twt.Pending, 0)) <> 0
									THEN 0
									ELSE CASE  WHEN SUM(ISNULL(twt.SoldInPeriod, 0)) > SUM(ISNULL(waq.QtyOnHand, 0))
												THEN SUM(ISNULL(waq.QtyOnHand, 0))
												ELSE SUM(ISNULL(twt.SoldInPeriod, 0))
											END
							END
				ELSE CASE 
						WHEN SUM(ISNULL(twt.LastQty, 0)) = SUM(ISNULL(twt.ShipQty, 0))
							AND SUM(ISNULL(twt.Pending, 0)) = 0
							AND SUM(ISNULL(twt.TotalRcvd, 0)) <> 0
							THEN CASE 
									WHEN (SUM(ISNULL(twt.InitialQty, 0)) - SUM(ISNULL(twt.QtyOnHand, 0))) <= 0
										THEN 0
									ELSE (SUM(ISNULL(twt.InitialQty, 0)) - SUM(ISNULL(twt.QtyOnHand, 0)))
									END
						WHEN SUM(ISNULL(twt.ShipQty, 0)) = 0 OR SUM(ISNULL(twt.Pending, 0)) <> 0
							THEN 0
							ELSE SUM(ISNULL(twt.SoldInPeriod, 0))
						END
			 END AS [SuggestedQty]
			,SUM(ISNULL(srd.requestedQty, 0)) AS [OnOrderQty]
			,ISNULL(SUM(ISNULL(waq.QtyOnHand, 0)) - ISNULL(( SELECT ISNULL(OnOrdQty, 0) FROM dbo.FN_VX_GetOnOrdQty_ByWhse(twt.VendorID, twt.ReorderItemCode, twt.LocationNo)), 0), 0) AS [AvailableQty]
			,SUM(ISNULL(srd.ConfirmedQty, 0)) AS [ConfirmedQty]
			,SUM(ISNULL(srd.CanceledQty, 0)) AS [CanceledQty]
			,SUM(ISNULL(srd.BackOrderQty, 0)) AS [BackOrderQty]
			--ISNULL(srd.AllowBackOrder,0) as [BackOrder?]
			,CASE 
					WHEN SUM(ISNULL(srd.requestedQty, 0)) > 0
						THEN ISNULL(srd.AllowBackOrder, 0)
						ELSE ISNULL(ev.DftBackOrd, 0)
			 END AS [BackOrder?]
			,twt.VendorID
			,twt.SectionCode
			,ISNULL('', '') AS [ItemTags]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.PONumber, 'NA') END AS [CurrentPONo]
			,ISNULL(src.RequisitionDueDate, '1900/01/01') AS [RequisitionDueDate]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.RequisitionNo, 'NA') END AS [CurrentReqNo]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss.statusname, 'NA') END AS [ReqStatus]
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss2.statusname, 'NA') END AS [LineStatus]
			,ISNULL(src.Locked, 'N') AS [ReqLock]
			,ISNULL(src.LockedBy, '') AS [ReqLockBy]
			,ISNULL(twt.ISBN, '') AS [VendorItem]
			--Case when (select count(distinct isbnupc) from vwVX_BT_AvailQty where ISBNUPC = twt.ISBN)= 0 then 'X' else '' end [ValidItem]
			,CASE WHEN twt.VendorID != 'IDB&TDISTR'
					THEN ''
					ELSE CASE WHEN (	SELECT COUNT(DISTINCT isbnupc)
										FROM vwVX_BT_ValidItem 
										WHERE ISBNUPC = twt.ISBN
									) = 0
								THEN 'X'
								ELSE ''
						END
			END AS [ValidItem]
	FROM #TEASER_WORK_TBL twt 
		LEFT JOIN VX_Reorder_Control src 
			ON twt.VendorID = src.VendorID
				AND twt.LocationNo = src.StoreNo
		LEFT JOIN VX_Requisition_Dtl srd 
			ON src.requisitionno = srd.requisitionno
				AND srd.itemcode = RIGHT(@TWENTYZEROS + twt.ReorderItemCode, 20)
		LEFT JOIN VX_Status ss 
			ON src.STATUS = ss.statuscode
		LEFT JOIN VX_Status ss2 			
			ON ISNULL(srd.STATUS, CASE  WHEN ISNULL(src.STATUS, 100) > 20 THEN src.STATUS   ELSE 10 END) = ss2.statuscode
		LEFT JOIN vwVX_BT_AvailQty waq 
			ON waq.ISBNUPC = twt.ISBN
				AND waq.Warehouse = src.Warehouse
		LEFT JOIN VX_Locations l 
			ON twt.LocationNo = l.LocationNo
		LEFT JOIN [HPB_EDI].[dbo].[Vendor_SAN_Codes] ev 
			ON twt.VendorID = ev.VendorID
		GROUP BY twt.RowID ,twt.LocationNo ,twt.District ,twt.Title ,twt.Cost ,twt.Price ,twt.ReorderItemCode ,twt.VendorID ,twt.SectionCode ,twt.Cost ,twt.Price ,twt.ISBNSold ,twt.ISBN
				,twt.NextOrderDate,twt.CaseQty ,twt.RateOfSale ,twt.PercentSold ,twt.SalesRank ,twt.XRefs ,ISNULL(src.RequisitionDueDate, '1900/01/01') 
				,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.PONumber, 'NA') END ,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(src.RequisitionNo, 'NA') END
			,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss.statusname, 'NA') END ,CASE WHEN l.Active = 'N' THEN 'NA' ELSE ISNULL(ss2.statusname, 'NA') END
			,ISNULL(src.Locked, 'N') ,ISNULL(src.LockedBy, '') ,ISNULL(srd.AllowBackOrder, 0) ,ISNULL(ev.DftBackOrd, 0)
		ORDER BY twt.title
			,twt.District
			,twt.LocationNo


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
	FROM #TEASER_WORK_TBL twt with (nolock) 
		LEFT JOIN VX_Reorder_Control src with (nolock) on twt.VendorID = src.VendorID and twt.LocationNo = src.StoreNo
		LEFT JOIN VX_Requisition_Dtl srd with (nolock) on src.requisitionno = srd.requisitionno and srd.itemcode = RIGHT(@TWENTYZEROS+twt.ReorderItemCode,20)
		LEFT JOIN VX_Status ss with (nolock) on src.status = ss.statuscode
		LEFT JOIN vwVX_BT_AvailQty waq with (nolock) on waq.ISBNUPC = twt.ISBN and waq.Warehouse = src.Warehouse
	GROUP BY twt.RowID,twt.LocationNo,twt.District,twt.Title,twt.Cost,twt.Price,twt.ReorderItemCode,twt.VendorID,twt.SectionCode,twt.Cost,twt.Price,twt.ISBNSold,twt.ISBN,twt.NextOrderDate,twt.CaseQty,twt.RateOfSale,twt.PercentSold,twt.SalesRank,twt.XRefs
		,ISNULL(src.RequisitionDueDate,'1900/01/01'),ISNULL(src.RequisitionNo,'NA'),ISNULL(ss.statusname,'NA'),ISNULL(src.Locked,'N'),ISNULL(src.LockedBy,'')
	ORDER BY twt.title,twt.District,twt.LocationNo


/*	************************************************************************************************************************************************************
	* CLEAN UP.....
	************************************************************************************************************************************************************ */
DROP TABLE #TEASER_WORK_TBL
END

GO

