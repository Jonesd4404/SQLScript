USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [meta].[uspTitleAndInventoryUpdate]    Script Date: 11/25/2019 9:41:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [meta].[uspTitleAndInventoryUpdate]
AS
BEGIN
	DECLARE @return INT = -1
	DECLARE @completed VARCHAR(2500) = ''

	BEGIN TRANSACTION upsert_records

	BEGIN TRY
		IF((SELECT COUNT(1) FROM staging.IngramContentTitlesActive) > 0)
			BEGIN
				UPDATE  trgt
						SET	 [ISBN_10]									= srce.[ISBN_10]
							,[Ingram_Product_Type_Code]					= srce.[Ingram_Product_Type_Code]
							,[Ingram_Product_Type]						= srce.[Ingram_Product_Type]
							,[Accessory_Code]							= srce.[Accessory_Code]
							,[Product_Classification_Type]				= srce.[Product_Classification_Type]
							,[Product_Form_Code]						= srce.[Product_Form_Code]
							,[Product_Form]								= srce.[Product_Form]
							,[Product_Form_Detail]						= srce.[Product_Form_Detail]
							,[Title]									= srce.[Title]
							,[Edition_Description]						= srce.[Edition_Description]
							,[Contributor_1_Role]						= srce.[Contributor_1_Role]
							,[Contributor_1]							= srce.[Contributor_1]
							,[Contributor_2_Role]						= srce.[Contributor_2_Role]
							,[Contributor_2]							= srce.[Contributor_2]
							,[Contributor_3_Role]						= srce.[Contributor_3_Role]
							,[Contributor_3]							= srce.[Contributor_3]
							,[Publisher]								= srce.[Publisher]
							,[BISAC_Binding_Type]						= srce.[BISAC_Binding_Type]
							,[BISAC_Childrens_Book_Type]				= srce.[BISAC_Childrens_Book_Type]
							,[Ingram_Subject_Code]						= srce.[Ingram_Subject_Code]
							,[BISAC_Subject_Code_1]						= srce.[BISAC_Subject_Code_1]
							,[BISAC_Subject_Heading_Description_1]		= srce.[BISAC_Subject_Heading_Description_1]
							,[BISAC_Subject_Code_2]						= srce.[BISAC_Subject_Code_2]
							,[BISAC_Subject_Heading_Description_2]		= srce.[BISAC_Subject_Heading_Description_2]
							,[BISAC_Subject_Code_3]						= srce.[BISAC_Subject_Code_3]
							,[BISAC_Subject_Heading_Description_3]		= srce.[BISAC_Subject_Heading_Description_3]
							,[Audience_Age_Minimum]						= srce.[Audience_Age_Minimum]
							,[Audience_Age_Maximum]						= srce.[Audience_Age_Maximum]
							,[Audience_Grade_Minimum]					= srce.[Audience_Grade_Minimum]
							,[Audience_Grade_Minimum_Desc]				= srce.[Audience_Grade_Minimum_Desc]
							,[Audience_Grade_Maximum]					= srce.[Audience_Grade_Maximum]
							,[Audience_Grade_Maximum_Desc]				= srce.[Audience_Grade_Maximum_Desc]
							,[Lexile_Reading_Level]						= srce.[Lexile_Reading_Level]
							,[LCCN]										= srce.[LCCN]
							,[Dewey_Decimal_Classification]				= srce.[Dewey_Decimal_Classification]
							,[Library_of_Congress_Subject_Heading_1]	= srce.[Library_of_Congress_Subject_Heading_1]
							,[Library_of_Congress_Subject_Heading_2]	= srce.[Library_of_Congress_Subject_Heading_2]
							,[Number_Pages]								= srce.[Number_Pages]
							,[Playing_Time]								= srce.[Playing_Time]
							,[Number_Of_Items]							= srce.[Weight_In_Pounds]
							,[Weight_In_Pounds]							= srce.[Weight_In_Pounds]
							,[Length_In_Inches]							= srce.[Length_In_Inches]
							,[Width_In_Inches]							= srce.[Width_In_Inches]
							,[Height_In_Inches]							= srce.[Height_In_Inches]
							,[Dump_Display_Flag]						= srce.[Dump_Display_Flag]
							,[Illustration_Flag]						= srce.[Illustration_Flag]
							,[Spring_Arbor_Division_Flag]				= srce.[Spring_Arbor_Division_Flag]
							,[Language]									= srce.[Language]
							,[Spring_Arbor_Product_Type]				= srce.[Spring_Arbor_Product_Type]
							,[Spring_Arbor_Subject_Code_Major]			= srce.[Spring_Arbor_Subject_Code_Major]
							,[Spring_Arbor_Subject_Code_Minor]			= srce.[Spring_Arbor_Subject_Code_Minor]
							,[Publisher_Price]							= srce.[Publisher_Price] 
							,[Publication_Date]							= srce.[Publication_Date]
							,[Title_Last_Updated]						= srce.[Title_Last_Updated]
				FROM staging.IngramContentTitlesActive srce
					INNER JOIN meta.IngramContentTitlesActive trgt
						ON srce.EAN = trgt.EAN
							AND srce.Title_Last_Updated <> trgt.Title_Last_Updated

				SET @completed = @completed + ';UPD_TTL=YES'
	
				INSERT INTO meta.IngramContentTitlesActive ([ISBN_10], [Ingram_Product_Type_Code], [Ingram_Product_Type], [Accessory_Code], [Product_Classification_Type], [Product_Form_Code], [Product_Form], [Product_Form_Detail], [Title], [Edition_Description], [Contributor_1_Role], [Contributor_1], [Contributor_2_Role], [Contributor_2], [Contributor_3_Role], [Contributor_3], [Publisher], [BISAC_Binding_Type], [BISAC_Childrens_Book_Type], [Ingram_Subject_Code], [BISAC_Subject_Code_1], [BISAC_Subject_Heading_Description_1], [BISAC_Subject_Code_2], [BISAC_Subject_Heading_Description_2], [BISAC_Subject_Code_3], [BISAC_Subject_Heading_Description_3], [Audience_Age_Minimum], [Audience_Age_Maximum], [Audience_Grade_Minimum], [Audience_Grade_Minimum_Desc], [Audience_Grade_Maximum], [Audience_Grade_Maximum_Desc], [Lexile_Reading_Level], [LCCN], [Dewey_Decimal_Classification], [Library_of_Congress_Subject_Heading_1], [Library_of_Congress_Subject_Heading_2], [Number_Pages], [Playing_Time], [Number_Of_Items], [Weight_In_Pounds], [Length_In_Inches], [Width_In_Inches], [Height_In_Inches], [Dump_Display_Flag], [Illustration_Flag], [Spring_Arbor_Division_Flag], [Language], [Spring_Arbor_Product_Type], [Spring_Arbor_Subject_Code_Major], [Spring_Arbor_Subject_Code_Minor], [Publisher_Price], [Publication_Date], [Title_Last_Updated]) 
						SELECT	 srce.[ISBN_10]
								,srce.[Ingram_Product_Type_Code]
								,srce.[Ingram_Product_Type]
								,srce.[Accessory_Code]
								,srce.[Product_Classification_Type]
								,srce.[Product_Form_Code]
								,srce.[Product_Form]
								,srce.[Product_Form_Detail]
								,srce.[Title]
								,srce.[Edition_Description]
								,srce.[Contributor_1_Role]
								,srce.[Contributor_1]
								,srce.[Contributor_2_Role]
								,srce.[Contributor_2]
								,srce.[Contributor_3_Role]
								,srce.[Contributor_3]
								,srce.[Publisher]
								,srce.[BISAC_Binding_Type]
								,srce.[BISAC_Childrens_Book_Type]
								,srce.[Ingram_Subject_Code]
								,srce.[BISAC_Subject_Code_1]
								,srce.[BISAC_Subject_Heading_Description_1]
								,srce.[BISAC_Subject_Code_2]
								,srce.[BISAC_Subject_Heading_Description_2]
								,srce.[BISAC_Subject_Code_3]
								,srce.[BISAC_Subject_Heading_Description_3]
								,srce.[Audience_Age_Minimum]
								,srce.[Audience_Age_Maximum]
								,srce.[Audience_Grade_Minimum]
								,srce.[Audience_Grade_Minimum_Desc]
								,srce.[Audience_Grade_Maximum]
								,srce.[Audience_Grade_Maximum_Desc]
								,srce.[Lexile_Reading_Level]
								,srce.[LCCN]
								,srce.[Dewey_Decimal_Classification]
								,srce.[Library_of_Congress_Subject_Heading_1]
								,srce.[Library_of_Congress_Subject_Heading_2]
								,srce.[Number_Pages]
								,srce.[Playing_Time]
								,srce.[Number_Of_Items]
								,srce.[Weight_In_Pounds]
								,srce.[Length_In_Inches]
								,srce.[Width_In_Inches]
								,srce.[Height_In_Inches]
								,srce.[Dump_Display_Flag]
								,srce.[Illustration_Flag]
								,srce.[Spring_Arbor_Division_Flag]
								,srce.[Language]
								,srce.[Spring_Arbor_Product_Type]
								,srce.[Spring_Arbor_Subject_Code_Major]
								,srce.[Spring_Arbor_Subject_Code_Minor]
								,srce.[Publisher_Price]
								,srce.[Publication_Date]
								,srce.[Title_Last_Updated]
						FROM staging.IngramContentTitlesActive srce
							LEFT JOIN meta.IngramContentTitlesActive trgt
								ON srce.ean = trgt.EAN
						WHERE trgt.EAN IS NULL

					SET @completed = @completed + ';INS_TTL=YES'
			END
		ELSE
			BEGIN
				SET @completed = @completed+ ';UPD_TTL=NRC;INST_TTL=NRC'
			END
			
		IF ((SELECT COUNT(1) FROM staging.CurrentTitleStockInventory ) > 0)
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
			BEGIN
				SET @completed = @completed + ';UPD_INV=NRC;INS_INV=NRC'
			END

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

