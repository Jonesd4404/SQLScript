USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[VX_GetVendorItemQty]    Script Date: 11/25/2019 9:39:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B.>
-- Create date: <11/2/2012>
-- Description:	<get quantities by item/warehouse for vendor.....>
-- =============================================
CREATE PROCEDURE [dbo].[VX_GetVendorItemQty] @vendorID VARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-----testing......
	--declare @vendorID varchar(10)
	--set @vendorID = 'IDB&TDISTR'
	--------------------------------
	----get vendor warehouse quantities
	--SELECT * into #tmp FROM (SELECT ISBNUPC,Warehouse,isnull(QtyOnHand,0)[QtyOnHand] FROM vwVX_BT_AvailQty with(nolock)
	--				where QtyOnHand > 0 and ISBNUPC in (select ISBN from [$(HPB_Prime)].[dbo].[ProductMaster] with(nolock) where Reorderable = 'Y' and PurchaseFromVendorID = @vendorID)) s
	--PIVOT (SUM(QtyOnHand) FOR Warehouse IN ([COM],[MOM],[SOM],[RNO])) AS Warehouse
	--order by ISBNUPC
	IF @vendorID = 'IDB&TDISTR'
		BEGIN
			SELECT *
			INTO #tmpbt
			FROM (	SELECT	 ISBNUPC
							,Warehouse
							,ISNULL(QtyOnHand, 0) [QtyOnHand]
					FROM vwVX_BT_AvailQty WITH (NOLOCK)
					WHERE ISBNUPC IN (	SELECT DISTINCT ISBN
										FROM dbo.STOC_TeaserData WITH (NOLOCK)
										WHERE VendorID = @vendorID)
						--and QtyOnHand > 0
				) s
			PIVOT(SUM(QtyOnHand) FOR Warehouse IN ([COM], [MOM], [SOM], [REN])) AS Warehouse
			ORDER BY ISBNUPC

			SELECT DISTINCT
				 st.ReorderItemCode [ItemCode]
				,st.Title
				,t.ISBNUPC [ISBN/UPC]
				,ISNULL(t.COM, 0) [COM]
				,ISNULL(t.MOM, 0) [MOM]
				,ISNULL(t.SOM, 0) [SOM]
				,ISNULL(t.REN, 0) [REN]
			FROM #tmpbt t
			INNER JOIN dbo.STOC_TeaserData st WITH (NOLOCK)
				ON t.ISBNUPC = st.ISBN
					AND st.VendorID = @vendorID
			ORDER BY st.Title

			DROP TABLE #tmpbt
		END
	ELSE IF @vendorID IN ('IDINGRAMDI')
		BEGIN
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT *
			INTO #tmping
			FROM (	SELECT	 icaq.ISBNUPC
							,icaq.Warehouse
							,ISNULL(icaq.QtyOnHand, 0) AS [QtyOnHand]
					FROM vwVX_IC_AvailQty icaq
						INNER JOIN dbo.STOC_TeaserData td
							on icaq.ISBNUPC = td.ISBN
								and td.VEndorID = @vendorID
					GROUP BY icaq.ISBNUPC, icaq.Warehouse, isnull(icaq.QtyOnHand,0)
				) s
			PIVOT(SUM(QtyOnHand) FOR Warehouse IN ([N], [B], [C], [D], [E], [J])) AS Warehouse
			ORDER BY ISBNUPC

			SELECT DISTINCT
				 st.ReorderItemCode [ItemCode]
				,st.Title
				,t.ISBNUPC [ISBN/UPC]
				,ISNULL(t.N, 0) AS [LaVerne]
				,ISNULL(t.B, 0) AS [Allentown]
				,ISNULL(t.C, 0) AS [Chambersburg]
				,ISNULL(t.D, 0) AS [FtWayne]
				,ISNULL(t.E, 0) AS [Roseburg]
				,ISNULL(t.J, 0) AS [Fresno]
			FROM #tmping t
			INNER JOIN dbo.STOC_TeaserData st WITH (NOLOCK)
				ON t.ISBNUPC = st.ISBN
					AND st.VendorID = @vendorID
			ORDER BY st.Title

			DROP TABLE #tmping
		END
	ELSE IF @vendorID <> 'IDB&TDISTR'
		BEGIN
			SELECT '' [ItemCode]
				,'' [Title]
				,'' [ISBN/UPC]
				,'' [WHSEQty]
		END
END

GO

