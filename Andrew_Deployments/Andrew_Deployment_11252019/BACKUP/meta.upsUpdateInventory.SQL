USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [meta].[uspUpdateInventory]    Script Date: 11/25/2019 9:41:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [meta].[uspUpdateInventory]
AS
BEGIN

	BEGIN TRANSACTION updateinv
	BEGIN TRY
		TRUNCATE TABLE staging.ISBNList
		TRUNCATE TABLE meta.IngramContentDCQuantities

		INSERT INTO staging.ISBNList(ISBNUPC)
			SELECT LTRIM(RTRIM(isbn)) AS ISBNUPC
			FROM STOC_TeaserData
			WHERE ISNULL(ISBN,'') != '' 
				AND ISNUMERIC(isbn) > 0
				AND (CAST(LastReorderDate AS DATE) > CAST(DATEADD(YEAR, -2, GETDATE()) AS DATE) 	
					 OR CAST(InitialStoreDate AS DATE ) > CAST(DATEADD(MONTH, -1, GETDATE()) AS DATE))
			GROUP BY ISBN
			UNION
			SELECT LTRIM(RTRIM(d.vendoritem)) AS ISBNUPC
			FROM VX_Requisition_Hdr h
				INNER JOIN VX_Requisition_Dtl d
					ON h.RequisitionNo = d.RequisitionNo
			WHERE h.[Status] BETWEEN 30 AND 40
			GROUP BY LTRIM(RTRIM(d.VendorItem))
	
		INSERT INTO meta.IngramContentDCQuantities (ISBNUPC, LVTN_OnHand, LVTN_Flag, ATPA_OnHand, ATPA_Flag, CBPA_OnHand, CBPA_Flag, FWIN_OnHand, FWIN_Flag, RBOR_OnHand, RBOR_Flag, FOCA_OnHand, FOCA_Flag)
			SELECT LTRIM(RTRIM(ctsi.ean)) AS ISBNUPC, ctsi.LVTN_On_Hand_Quantity, ctsi.LVTN_Stock_Flag
					,ctsi.ATPA_On_Hand_Quantity, ctsi.ATPA_Stock_Flag
					,ctsi.CBPA_On_Hand_Quantity, ctsi.CBPA_Stock_Flag
					,ctsi.FWIN_On_Hand_Quantity, ctsi.FWIN_Stock_Flag
					,ctsi.RBOR_On_Hand_Quantity, ctsi.RBOR_Stock_Flag
					,ctsi.FOCA_On_Hand_Quantity, ctsi.FOCA_Stock_Flag
			FROM meta.CurrentTitleStockInventory ctsi
				INNER JOIN staging.isbnlist ai
					ON LTRIM(RTRIM(ctsi.EAN)) =ai.ISBNUPC
		--union reserve inventory (not accessible yet)

		IF @@TRANCOUNT > 0 COMMIT TRANSACTION updateinv
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION updateinv

	END CATCH

END

GO

