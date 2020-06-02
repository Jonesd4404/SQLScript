USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [meta].[uspInventoryUpdate]    Script Date: 11/25/2019 9:40:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [meta].[uspInventoryUpdate]
AS
BEGIN
	DECLARE @return INT = -1
	DECLARE @completed VARCHAR(2500) = ''

	BEGIN TRANSACTION upsert_records

	BEGIN TRY
		IF ((SELECT COUNT(1) 
			FROM staging.CurrentTitleStockInventory srce
				INNER JOIN meta.CurrentTitleStockInventory trgt
					ON srce.EAN = trgt.EAN
						AND srce.Last_Modified_Date <> trgt.Last_Modified_Date) > 0)
			BEGIN
				UPDATE  trgt
					SET	 [GTIN14]									= srce.[GTIN14]
						,[ISBN13]									= srce.[ISBN13]
						,[UPC]										= srce.[UPC]
						,[ISBN10]									= srce.[ISBN10]
						,[LVTN_On_Hand_Quantity]					= srce.[LVTN_On_Hand_Quantity]
						,[RBOR_On_Hand_Quantity]					= srce.[RBOR_On_Hand_Quantity]
						,[FWIN_On_Hand_Quantity]					= srce.[FWIN_On_Hand_Quantity]
						,[CBPA_On_Hand_Quantity]					= srce.[CBPA_On_Hand_Quantity]
						,[ATPA_On_Hand_Quantity]					= srce.[ATPA_On_Hand_Quantity]
						,[FOCA_On_Hand_Quantity]					= srce.[FOCA_On_Hand_Quantity]
						,[FFOH_On_Hand_Quantity]					= srce.[FFOH_On_Hand_Quantity]
						,[WADC_On_Hand_Quantity]					= srce.[WADC_On_Hand_Quantity]
						,[LVTN_On_Order_Quantity]					= srce.[LVTN_On_Order_Quantity]
						,[RBOR_On_Order_Quantity]					= srce.[RBOR_On_Order_Quantity]
						,[FWIN_On_Order_Quantity]					= srce.[FWIN_On_Order_Quantity]
						,[CBPA_On_Order_Quantity]					= srce.[CBPA_On_Order_Quantity]
						,[ATPA_On_Order_Quantity]					= srce.[ATPA_On_Order_Quantity]
						,[FOCA_On_Order_Quantity]					= srce.[FOCA_On_Order_Quantity]
						,[FFOH_On_Order_Quantity]					= srce.[FFOH_On_Order_Quantity]
						,[WADC_On_Order_Quantity]					= srce.[WADC_On_Order_Quantity]
						,[Total_Quantity_On_Hand]					= srce.[Total_Quantity_On_Hand]
						,[Price]									= srce.[Price]
						,[Discount_Level_Original_Value]			= srce.[Discount_Level_Original_Value]
						,[CDF_Discount_Pct]							= srce.[CDF_Discount_Pct]
						,[Bulk_Discount_Pct]						= srce.[Bulk_Discount_Pct]
						,[Publisher_Status_Code]					= srce.[Publisher_Status_Code]
						,[Publisher_Status_Description]				= srce.[Publisher_Status_Description]
						,[LVTN_Stock_Flag]							= srce.[LVTN_Stock_Flag]
						,[RBOR_Stock_Flag]							= srce.[RBOR_Stock_Flag]
						,[FWIN_Stock_Flag]							= srce.[FWIN_Stock_Flag]
						,[CBPA_Stock_Flag]							= srce.[CBPA_Stock_Flag]
						,[ATPA_Stock_Flag]							= srce.[ATPA_Stock_Flag]
						,[FOCA_Stock_Flag]							= srce.[FOCA_Stock_Flag]
						,[FFOH_Stock_Flag]							= srce.[FFOH_Stock_Flag]
						,[WADC_Stock_Flag]							= srce.[WADC_Stock_Flag]
						,[Publication_Date]							= srce.[Publication_Date]
						,[On_Sale_Date]								= srce.[On_Sale_Date]
						,[Returnable_Indicator]						= srce.[Returnable_Indicator]
						,[Return_Date]								= srce.[Return_Date]
						,[Backorder_Only_Indicator]					= srce.[Backorder_Only_Indicator]
						,[Media_Mail_Indicator]						= srce.[Media_Mail_Indicator]
						,[Ingram_Product_Type]						= srce.[Ingram_Product_Type]
						,[Ingram_Product_Type_Description]			= srce.[Ingram_Product_Type_Description]
						,[Imprintable_Indicator]					= srce.[Imprintable_Indicator]
						,[Indexable_Indicator]						= srce.[Indexable_Indicator]
						,[Weight]									= srce.[Weight]
						,[Ingram_Publisher_Number]					= srce.[Ingram_Publisher_Number]
						,[Ingram_Publisher_Number_Description]		= srce.[Ingram_Publisher_Number_Description]
						,[Restricted_Code]							= srce.[Restricted_Code]
						,[Restricted_Code_Description]				= srce.[Restricted_Code_Description]
						,[Discount_Category_Code]					= srce.[Discount_Category_Code]
						,[Product_Availability_Code]				= srce.[Product_Availability_Code]
						,[Product_Availability_Code_Description]	= srce.[Product_Availability_Code_Description]
						,[Ingram_Title_Code]						= srce.[Ingram_Title_Code]
						,[Product_Classification_Type]				= srce.[Product_Classification_Type]
						,[Last_Modified_Date]						= srce.[Last_Modified_Date]		
				FROM staging.CurrentTitleStockInventory srce
					INNER JOIN meta.CurrentTitleStockInventory trgt
						ON srce.EAN = trgt.EAN
							AND srce.Last_Modified_Date <> trgt.Last_Modified_Date

				SET @completed = @completed + ';UPD_INV=YES'
			END
		ELSE
			SET @completed = @completed + ';UPD_INV=NRC'

		IF ((SELECT COUNT(1) 
			FROM staging.CurrentTitleStockInventory srce
				LEFT JOIN meta.CurrentTitleStockInventory trgt
							ON srce.EAN = trgt.EAN
			WHERE trgt.EAN IS NULL) > 0)

			BEGIN
				INSERT INTO meta.CurrentTitleStockInventory ([GTIN14], [EAN], [ISBN13], [UPC], [ISBN10], [LVTN_On_Hand_Quantity], [RBOR_On_Hand_Quantity], [FWIN_On_Hand_Quantity], [CBPA_On_Hand_Quantity], [ATPA_On_Hand_Quantity], [FOCA_On_Hand_Quantity], [FFOH_On_Hand_Quantity], [WADC_On_Hand_Quantity], [LVTN_On_Order_Quantity], [RBOR_On_Order_Quantity], [FWIN_On_Order_Quantity], [CBPA_On_Order_Quantity], [ATPA_On_Order_Quantity], [FOCA_On_Order_Quantity], [FFOH_On_Order_Quantity], [WADC_On_Order_Quantity], [Total_Quantity_On_Hand], [Price], [Discount_Level_Original_Value], [CDF_Discount_Pct], [Bulk_Discount_Pct], [Publisher_Status_Code], [Publisher_Status_Description], [LVTN_Stock_Flag], [RBOR_Stock_Flag], [FWIN_Stock_Flag], [CBPA_Stock_Flag], [ATPA_Stock_Flag], [FOCA_Stock_Flag], [FFOH_Stock_Flag], [WADC_Stock_Flag], [Publication_Date], [On_Sale_Date], [Returnable_Indicator], [Return_Date], [Backorder_Only_Indicator], [Media_Mail_Indicator], [Ingram_Product_Type], [Ingram_Product_Type_Description], [Imprintable_Indicator], [Indexable_Indicator], [Weight], [Ingram_Publisher_Number], [Ingram_Publisher_Number_Description], [Restricted_Code], [Restricted_Code_Description], [Discount_Category_Code], [Product_Availability_Code], [Product_Availability_Code_Description], [Ingram_Title_Code], [Product_Classification_Type], [Last_Modified_Date])
					SELECT	 srce.[GTIN14]
							,srce.[EAN]
							,srce.[ISBN13]
							,srce.[UPC]
							,srce.[ISBN10]
							,srce.[LVTN_On_Hand_Quantity]
							,srce.[RBOR_On_Hand_Quantity]
							,srce.[FWIN_On_Hand_Quantity]
							,srce.[CBPA_On_Hand_Quantity]
							,srce.[ATPA_On_Hand_Quantity]
							,srce.[FOCA_On_Hand_Quantity]
							,srce.[FFOH_On_Hand_Quantity]
							,srce.[WADC_On_Hand_Quantity]
							,srce.[LVTN_On_Order_Quantity]
							,srce.[RBOR_On_Order_Quantity]
							,srce.[FWIN_On_Order_Quantity]
							,srce.[CBPA_On_Order_Quantity]
							,srce.[ATPA_On_Order_Quantity]
							,srce.[FOCA_On_Order_Quantity]
							,srce.[FFOH_On_Order_Quantity]
							,srce.[WADC_On_Order_Quantity]
							,srce.[Total_Quantity_On_Hand]
							,srce.[Price]
							,srce.[Discount_Level_Original_Value]
							,srce.[CDF_Discount_Pct]
							,srce.[Bulk_Discount_Pct]
							,srce.[Publisher_Status_Code]
							,srce.[Publisher_Status_Description]
							,srce.[LVTN_Stock_Flag]
							,srce.[RBOR_Stock_Flag]
							,srce.[FWIN_Stock_Flag]
							,srce.[CBPA_Stock_Flag]
							,srce.[ATPA_Stock_Flag]
							,srce.[FOCA_Stock_Flag]
							,srce.[FFOH_Stock_Flag]
							,srce.[WADC_Stock_Flag]
							,srce.[Publication_Date]
							,srce.[On_Sale_Date]
							,srce.[Returnable_Indicator]
							,srce.[Return_Date]
							,srce.[Backorder_Only_Indicator]
							,srce.[Media_Mail_Indicator]
							,srce.[Ingram_Product_Type]
							,srce.[Ingram_Product_Type_Description]
							,srce.[Imprintable_Indicator]
							,srce.[Indexable_Indicator]
							,srce.[Weight]
							,srce.[Ingram_Publisher_Number]
							,srce.[Ingram_Publisher_Number_Description]
							,srce.[Restricted_Code]
							,srce.[Restricted_Code_Description]
							,srce.[Discount_Category_Code]
							,srce.[Product_Availability_Code]
							,srce.[Product_Availability_Code_Description]
							,srce.[Ingram_Title_Code]
							,srce.[Product_Classification_Type]
							,srce.[Last_Modified_Date]
					FROM staging.CurrentTitleStockInventory srce
						LEFT JOIN meta.CurrentTitleStockInventory trgt
									ON srce.EAN = trgt.EAN
					WHERE trgt.EAN IS NULL

				SET @completed = @completed + ';INS_INV=YES'
			END
		ELSE
			SET @completed = @completed + ';INS_INV=NRC'

		IF @@TRANCOUNT > 0  COMMIT TRANSACTION upsert_records
			SET @return = 1 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION upsert_records
		SELECT @return = 0, @completed = @completed + ';CATCH_INVOKED=' + CAST(ERROR_NUMBER() AS VARCHAR(20)) + ' ' + ERROR_MESSAGE()
	END CATCH

	SELECT @return AS ReturnValue, @completed AS ItemsCompleted
END

GO

