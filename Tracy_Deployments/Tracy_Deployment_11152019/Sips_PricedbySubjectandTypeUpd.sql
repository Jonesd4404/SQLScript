USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[Sips_PricedbySubjectandType]    Script Date: 11/7/2019 1:19:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sips_PricedbySubjectandType] 
--DECLARE 
     @StartDate DATETIME --= '11/1/2019'
	,@EndDate DATETIME --= '11/1/2019'
	,@FilterType CHAR(20) --= 'Store' --'District'
	,@DynFilter CHAR(20) --= '00290' --= 'Dallas North'
	,@SubTypeFilter CHAR(1)
	--= 'T'
	--= 'S'

AS
BEGIN
	/******************************************************************************************************************************************************************/
	/* Create Temp Table Data for selected locations Store Numbers                                                                                                    */
	/*                                                                                                                                                                */
	/*Tracy Dennis  11/11/19 #10273 Outlet / BookSmarter Transfer project Added Outlet and BookSmarter to the store section and all location section. Commented out   */
	/*                       RDC section since no longer used. Added RetailStore = 'Y'  for District comparison logic, we do not want Outlet and BookSmarter locations*/
	/*                       to be a part of district numbers or compare to them.                                                                                                           */
	/******************************************************************************************************************************************************************/
	CREATE TABLE #LOCS (
		LocationNo CHAR(5)
		,LocationID CHAR(10)
		,LocationName CHAR(30)
		)

	IF @FilterType = 'All Locations'
	BEGIN
		INSERT #LOCS
		SELECT LocationNo
			,l.LocationID
			,[Name]
		FROM reportsdata..Locations l
		JOIN reportsdata..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE
			-- LocationType = 'S'
			--AND RetailStore = 'Y'
			(
				RetailStore = 'Y'
				OR RptOutlet = 'Y'
				OR RptBookSmarter = 'Y'
				)
			AND STATUS = 'A'
		ORDER BY LocationNo
	END

	IF @FilterType = 'Store'
	BEGIN
		INSERT #LOCS
		SELECT LocationNo
			,LocationID
			,[Name]
		FROM ReportsData..Locations
		WHERE LocationNo = @DynFilter
			AND STATUS = 'A'
	END

	IF @FilterType = 'District'
	BEGIN
		INSERT #LOCS
		SELECT LocationNo
			,LocationID
			,[Name]
		FROM ReportsData..Locations
		WHERE DistrictCode = @DynFilter
			AND RetailStore = 'Y'
			AND STATUS = 'A'
	END

	IF @FilterType = 'Region'
	BEGIN
		INSERT #LOCS
		SELECT LocationNo
			,LocationID
			,[Name]
		FROM ReportsData..ReportLocations
		WHERE Region = @DynFilter
			AND STATUS = 'A'
	END

	--IF @FilterType = 'RDC'
	--BEGIN
	--INSERT  #LOCS
	--	SELECT 
	--	LocationNo, LocationID, [Name]
	--	FROM reportsdata..Locations 
	--	WHERE-- LocationType = 'R'
	--		--AND RetailStore = 'N'
	--		 LocationNo NOT IN ('00451','00710','00999')
	--		AND RDCLocationNo = @DynFilter
	--		AND RetailStore = 'Y'
	--		AND Status = 'A'
	--	END
	IF @FilterType = 'State'
	BEGIN
		INSERT #LOCS
		SELECT LocationNo
			,LocationID
			,[Name]
		FROM reportsdata..Locations
		WHERE LocationType = 'S'
			AND RetailStore = 'Y'
			AND STATUS = 'A'
			AND StateCode = @DynFilter
		ORDER BY LocationNo
	END

	--select @FilterType [AtEndOfIfs]
	/*****************************************************************************/
	/* Create Temp Table Data for selected Districts Store Numbers               */
	/*****************************************************************************/
	CREATE TABLE #DISTRICT (DistrictCode CHAR(20))

	CREATE TABLE #DISTRICTLOCS (
		LocationNo CHAR(5)
		,LocationID CHAR(10)
		,LocationName CHAR(30)
		)

	--select * from #LOCS
	--select @FilterType [BeforeEval]
	IF @FilterType = 'Store'
	BEGIN
		INSERT #DISTRICT
		SELECT DistrictCode
		FROM ReportsData..Locations
		WHERE LocationNo = @DynFilter
			AND RetailStore = 'Y' --Do not want Outlet and BookSmarter locations to be a part of district numbers

		--select *, 'InIf'[InIf] from #DISTRICT 
		INSERT #DISTRICTLOCS
		SELECT l.LocationNo
			,l.LocationID
			,l.[Name]
		FROM ReportsData..Locations l
		INNER JOIN #DISTRICT d ON l.DistrictCode = d.DistrictCode
		WHERE l.LocationType = 'S'
			AND l.RetailStore = 'Y'
			AND l.STATUS = 'A'
		ORDER BY l.LocationNo
			--select *  ,'InIf'[InIf] from #DISTRICTLOCS
	END

	--select * ,'AfterIf'[AfterIf]  from #DISTRICT
	-- select * , 'AfterIf'[AfterIf] from #DISTRICTLOCS
	CREATE TABLE #ALLSALES (
		SubType VARCHAR(255)
		,AmountPriced MONEY
		,QtyPriced INT
		,AvgPrice MONEY
		)

	CREATE TABLE #SELECTEDSALES (
		SubType VARCHAR(255)
		,AmountPriced MONEY
		,QtyPriced INT
		,AvgPrice MONEY
		)

	CREATE TABLE #DISTRICTSALES (
		SubType VARCHAR(255)
		,AmountPriced MONEY
		,QtyPriced INT
		,AvgPrice MONEY
		)

	IF @SubTypeFilter = 'S'
	BEGIN
		/*****************************************************************************/
		/* Create Temp Table Data for All Locations Sales                            */
		/*****************************************************************************/
		INSERT #ALLSALES
		SELECT s.Subject
			,Sum(i.Price) AS AmountPriced
			,Sum(i.QuantityOnHand) AS QtyPriced
			,Avg(i.Price * i.QuantityOnHand) AS AvgPrice
		FROM ReportsData..SipsProductInventory i
		INNER JOIN ReportsData..SubjectSummary s ON i.SubjectKey = s.SubjectKey
		WHERE i.DateInStock BETWEEN @StartDate
				AND DateAdd(dd, 1, @EndDate)
			AND i.Price < 1000
		GROUP BY s.Subject

		/*****************************************************************************/
		/* Create Temp Table Data for Selected Locations Sales                       */
		/*****************************************************************************/
		INSERT #SELECTEDSALES
		SELECT s.Subject
			,Sum(i.Price) AS AmountPriced
			,Sum(i.QuantityOnHand) AS QtyPriced
			,Avg(i.Price * i.QuantityOnHand) AS AvgPrice
		FROM ReportsData..SipsProductInventory i
		INNER JOIN ReportsData..SubjectSummary s ON i.SubjectKey = s.SubjectKey
		INNER JOIN #LOCS l ON i.LocationID = l.LocationID
		WHERE i.DateInStock BETWEEN @StartDate
				AND DateAdd(dd, 1, @EndDate)
			AND i.Price < 1000
		GROUP BY s.Subject

		/*****************************************************************************/
		/* Create Temp Table Data for District Locations Sales                       */
		/*****************************************************************************/
		INSERT #DISTRICTSALES
		SELECT s.Subject
			,Sum(i.Price) AS AmountPriced
			,Sum(i.QuantityOnHand) AS QtyPriced
			,Avg(i.Price * i.QuantityOnHand) AS AvgPrice
		FROM ReportsData..SipsProductInventory i
		INNER JOIN ReportsData..SubjectSummary s ON i.SubjectKey = s.SubjectKey
		INNER JOIN #DISTRICTLOCS l ON i.LocationID = l.LocationID
		WHERE i.DateInStock BETWEEN @StartDate
				AND DateAdd(dd, 1, @EndDate)
			AND i.Price < 1000
		GROUP BY s.Subject

		/*****************************************************************************/
		/* Select all Subject Data                                                   */
		/*****************************************************************************/
		SELECT ISNULL(s.SubType, a.SubType) AS SelectedSubject
			,ISNULL(s.AmountPriced, 0) AS SelectedAmountPriced
			,ISNULL(s.QtyPriced, 0) AS SelectedQtyPriced
			,ISNULL(s.AvgPrice, 0) AS SelectedAvgPrice
			,ISNULL(a.SubType, a.SubType) AS AllSubject
			,ISNULL(a.AmountPriced, 0) AS AllAmountPriced
			,ISNULL(a.QtyPriced, 0) AS AllQtyPriced
			,ISNULL(a.AvgPrice, 0) AS AllAvgPrice
			,ISNULL(d.SubType, a.SubType) AS DistrictSubject
			,ISNULL(d.AmountPriced, 0) AS DistrictAmountPriced
			,ISNULL(d.QtyPriced, 0) AS DistrictQtyPriced
			,ISNULL(d.AvgPrice, 0) AS DistrictAvgPrice
		FROM #SELECTEDSALES s
		RIGHT OUTER JOIN #ALLSALES a ON s.SubType = a.SubType
		LEFT OUTER JOIN #DISTRICTSALES d ON a.SubType = d.SubType
		ORDER BY SelectedSubject
	END
	ELSE
	BEGIN
		/*****************************************************************************/
		/* Create Temp Table Data for All Locations Sales                            */
		/*****************************************************************************/
		INSERT #ALLSALES
		SELECT i.ProductType
			,Sum(i.Price) AS AmountPriced
			,Sum(i.QuantityOnHand) AS QtyPriced
			,Avg(i.Price * i.QuantityOnHand) AS AvgPrice
		FROM ReportsData..SipsProductInventory i
		INNER JOIN ReportsData..SubjectSummary s ON i.SubjectKey = s.SubjectKey
		WHERE i.DateInStock BETWEEN @StartDate
				AND DateAdd(dd, 1, @EndDate)
			AND i.Price < 1000
		GROUP BY i.ProductType

		/*****************************************************************************/
		/* Create Temp Table Data for Selected Locations Sales                       */
		/*****************************************************************************/
		INSERT #SELECTEDSALES
		SELECT i.ProductType
			,Sum(i.Price) AS AmountPriced
			,Sum(i.QuantityOnHand) AS QtyPriced
			,Avg(i.Price * i.QuantityOnHand) AS AvgPrice
		FROM ReportsData..SipsProductInventory i
		INNER JOIN ReportsData..SubjectSummary s ON i.SubjectKey = s.SubjectKey
		INNER JOIN #LOCS l ON i.LocationID = l.LocationID
		WHERE i.DateInStock BETWEEN @StartDate
				AND DateAdd(dd, 1, @EndDate)
			AND i.Price < 1000
		GROUP BY i.ProductType

		/*****************************************************************************/
		/* Create Temp Table Data for District Locations Sales                       */
		/*****************************************************************************/
		INSERT #DISTRICTSALES
		SELECT i.ProductType
			,Sum(i.Price) AS AmountPriced
			,Sum(i.QuantityOnHand) AS QtyPriced
			,Avg(i.Price * i.QuantityOnHand) AS AvgPrice
		FROM ReportsData..SipsProductInventory i
		INNER JOIN ReportsData..SubjectSummary s ON i.SubjectKey = s.SubjectKey
		INNER JOIN #DISTRICTLOCS l ON i.LocationID = l.LocationID
		WHERE i.DateInStock BETWEEN @StartDate
				AND DateAdd(dd, 1, @EndDate)
			AND i.Price < 1000
		GROUP BY i.ProductType

		/*****************************************************************************/
		/* Select all Product Type Data                                              */
		/*****************************************************************************/
		SELECT ISNULL(s.SubType, a.SubType) AS SelectedType
			,ISNULL(s.AmountPriced, 0) AS SelectedAmountPriced
			,ISNULL(s.QtyPriced, 0) AS SelectedQtyPriced
			,ISNULL(s.AvgPrice, 0) AS SelectedAvgPrice
			,ISNULL(a.SubType, a.SubType) AS AllType
			,ISNULL(a.AmountPriced, 0) AS AllAmountPriced
			,ISNULL(a.QtyPriced, 0) AS AllQtyPriced
			,ISNULL(a.AvgPrice, 0) AS AllAvgPrice
			,ISNULL(d.SubType, a.SubType) AS DistrictType
			,ISNULL(d.AmountPriced, 0) AS DistrictAmountPriced
			,ISNULL(d.QtyPriced, 0) AS DistrictQtyPriced
			,ISNULL(d.AvgPrice, 0) AS DistrictAvgPrice
		FROM #SELECTEDSALES s
		RIGHT OUTER JOIN #ALLSALES a ON s.SubType = a.SubType
		LEFT OUTER JOIN #DISTRICTSALES d ON a.SubType = d.SubType
		ORDER BY SelectedType
	END

	/*****************************************************************************/
	/* DROP Temp Tables                                                          */
	/*****************************************************************************/
	DROP TABLE #DISTRICT

	DROP TABLE #DISTRICTLOCS

	DROP TABLE #LOCS

	DROP TABLE #ALLSALES

	DROP TABLE #SELECTEDSALES

	DROP TABLE #DISTRICTSALES
END
GO


