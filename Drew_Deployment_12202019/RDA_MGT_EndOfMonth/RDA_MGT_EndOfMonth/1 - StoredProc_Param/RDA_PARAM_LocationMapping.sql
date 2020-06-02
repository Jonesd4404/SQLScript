USE [Reports]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 9/20/19
-- Description:	Return the region for any district entered, or the district and region for any location entered.
-- =============================================
CREATE PROCEDURE [dbo].[RDA_PARAM_LocationMapping]
	--@ParamType  accepts "District" or "Store" as valid input
	--If @FilterType = 'District', @ParamName accepts "DistrictName" from the StoreLocationMaster as valid input
	--If @ParamType = 'Store', @ParamName accepts "LocationNo" from the StoreLocationMaster
	@FilterType VARCHAR(20),
	@ParamName VARCHAR(20)
AS
BEGIN

SET NOCOUNT ON;

IF @FilterType = 'Store'
	BEGIN

	SELECT DISTINCT 
		slm.RegionName,
		slm.DistrictName
	FROM ReportsData..StoreLocationMaster slm
	WHERE slm.LocationNo = @ParamName

	END

--District
IF @FilterType = 'District'

	BEGIN

	SELECT DISTINCT 
		slm.RegionName
	FROM ReportsData..StoreLocationMaster slm
	WHERE slm.DistrictName = @ParamName



	END



END
GO
