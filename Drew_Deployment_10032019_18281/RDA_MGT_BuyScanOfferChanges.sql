USE [ReportsData]
GO
/****** Object:  StoredProcedure [dbo].[RDA_MGT_BuyOfferAdjustmentsByUser]    Script Date: 8/23/2019 2:09:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 8/23/19
-- Description:	Report data for buy scans and changes to suggested offers by users.
-- =============================================
CREATE PROCEDURE [dbo].[RDA_MGT_BuyOfferAdjustmentsByUser]
	-- Add the parameters for the stored procedure here
	@LocationNo CHAR(5),
	@StartDate DATE,
	@EndDate DATE
AS
BEGIN

	SET NOCOUNT ON;


SELECT 
	CASE 
		WHEN GROUPING(bbi.CreateUser) = 1
		THEN 'All'
		ELSE bbi.CreateUser
		END					[CreateUser],
	SUM(Quantity)			[total_ItemsPurchased],
	ISNULL(CAST(SUM(CASE 
					WHEN bbi.ItemEntryModeID IS NULL 
					THEN bbi.Quantity 
					END) AS FLOAT)/
					NULLIF(CAST(SUM(bbi.Quantity) AS FLOAT), 0), 0)							[pct_QtyScanned],
	ISNULL(CAST(SUM(CASE 
					WHEN bbi.ItemEntryModeID IS NULL 
					AND bbi.CreateMachine LIKE 'CT%'
					THEN bbi.Quantity 
					END) AS FLOAT)/
					NULLIF(CAST(SUM(CASE 
									WHEN bbi.ItemEntryModeID IS NULL 
									THEN bbi.Quantity 
									END) AS FLOAT), 0), 0)									[pct_ScansHandheldScanned],
	ISNULL(CAST(SUM(CASE 
					WHEN bbi.Scoring_ID IS NOT NULL
					THEN bbi.Quantity 
					END) AS FLOAT)/
					NULLIF(CAST(SUM(bbi.Quantity) AS FLOAT), 0), 0)							[pct_QtySuggestedOffer],
	ISNULL(CAST(SUM(CASE 
					WHEN bbi.SuggestedOffer <>  (bbi.Offer / NULLIF(bbi.Quantity, 0))
					AND bbi.Scoring_ID IS NOT NULL
					THEN bbi.Quantity
					END) AS FLOAT), 0)														[total_QtySuggestedOffersAdjusted],
	ISNULL(CAST(SUM(CASE 
					WHEN bbi.SuggestedOffer <>  (bbi.Offer / NULLIF(bbi.Quantity, 0))
					AND bbi.Scoring_ID IS NOT NULL
					THEN bbi.Quantity
					END) AS FLOAT)/
		NULLIF(CAST(SUM(CASE 
						WHEN bbi.Scoring_ID IS NOT NULL
						THEN bbi.Quantity 
						END) AS FLOAT), 0), 0)												[pct_QtySuggestedOffersAdjusted]
FROM ReportsData..BuyBinHeader bbh
	INNER JOIN ReportsData..BuyBinItems bbi
		ON bbh.BuyBinNo = bbi.BuyBinNo
		AND bbh.LocationNo = bbi.LocationNo
WHERE 
	bbh.CreateTime >  @StartDate AND
	bbh.CreateTime < DATEADD(DAY, 1, @EndDate) AND
	bbh.StatusCode = 1 AND
	bbi.StatusCode = 1 AND
	bbi.Quantity < 10000 AND
	bbi.Offer < 10000 AND
	bbh.LocationNo = @LocationNo
GROUP BY bbi.CreateUser WITH ROLLUP
ORDER BY total_QtySuggestedOffersAdjusted DESC
END
