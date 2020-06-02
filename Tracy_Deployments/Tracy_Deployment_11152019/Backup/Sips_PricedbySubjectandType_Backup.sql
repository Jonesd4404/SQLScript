USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[Sips_PricedbySubjectandType]    Script Date: 11/15/2019 8:37:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



Create PROCEDURE [dbo].[Sips_PricedbySubjectandType]

@StartDate DATETIME = '11/1/2010',
@EndDate DATETIME = '1/31/2011',
@FilterType CHAR(20) = 'District',
@DynFilter CHAR(20) = 'Dallas North',
@SubTypeFilter CHAR(1) = 'T'

AS
BEGIN
/*****************************************************************************/
/* Create Temp Table Data for selected locations Store Numbers               */
/*****************************************************************************/
CREATE TABLE #LOCS(LocationNo CHAR(5), LocationID CHAR(10), LocationName CHAR(30))

IF @FilterType = 'All Locations'
	BEGIN
	INSERT  #LOCS
	SELECT 
		LocationNo, LocationID, [Name]
		FROM reportsdata..Locations 
		WHERE LocationType = 'S'
			AND RetailStore = 'Y'
			AND Status = 'A'
	ORDER BY LocationNo
	END
IF @FilterType = 'Store'
	BEGIN
	INSERT  #LOCS
	SELECT 
	LocationNo, LocationID, [Name]
		FROM ReportsData..Locations WHERE LocationNo = @DynFilter
		AND Status = 'A'
	END
IF @FilterType = 'District'
	BEGIN
	INSERT  #LOCS
	SELECT 
	LocationNo, LocationID, [Name]
		FROM ReportsData..Locations 
		WHERE DistrictCode = @DynFilter 
		AND RetailStore = 'Y'
		AND Status = 'A'
	END
IF @FilterType = 'Region'
	BEGIN
	INSERT  #LOCS
	SELECT 
	LocationNo, LocationID, [Name]
		FROM  ReportsData..ReportLocations 
		WHERE Region = @DynFilter
		AND Status = 'A'
	END
IF @FilterType = 'RDC'
BEGIN
INSERT  #LOCS
	SELECT 
	LocationNo, LocationID, [Name]
	FROM reportsdata..Locations 
	WHERE-- LocationType = 'R'
		--AND RetailStore = 'N'
		 LocationNo NOT IN ('00451','00710','00999')
		AND RDCLocationNo = @DynFilter
		AND RetailStore = 'Y'
		AND Status = 'A'
	END
IF @FilterType = 'State'
	BEGIN
	INSERT  #LOCS
	SELECT 
		LocationNo, LocationID, [Name]
		FROM reportsdata..Locations 
		WHERE LocationType = 'S'
			AND RetailStore = 'Y'
			AND Status = 'A'
			AND StateCode = @DynFilter
	ORDER BY LocationNo
	END


/*****************************************************************************/
/* Create Temp Table Data for selected Districts Store Numbers               */
/*****************************************************************************/
CREATE TABLE #DISTRICT (DistrictCode Char(20))
CREATE TABLE #DISTRICTLOCS(LocationNo CHAR(5), LocationID CHAR(10), LocationName CHAR(30))

IF @FilterType = 'Store'
   BEGIN
		INSERT	#DISTRICT
		SELECT	DistrictCode
		FROM	ReportsData..Locations 
		WHERE	LocationNo = @DynFilter

		INSERT #DISTRICTLOCS
		SELECT l.LocationNo, 
			   l.LocationID, 
			   l.[Name]

		FROM ReportsData..Locations l inner join
			 #DISTRICT d
				ON l.DistrictCode = d.DistrictCode
		WHERE l.LocationType = 'S'
			AND l.RetailStore = 'Y'
			AND l.Status = 'A'
		ORDER BY l.LocationNo
	END

CREATE TABLE #ALLSALES(SubType VARCHAR(255), AmountPriced MONEY, QtyPriced INT, AvgPrice MONEY)
CREATE TABLE #SELECTEDSALES(SubType VARCHAR(255), AmountPriced MONEY, QtyPriced INT, AvgPrice MONEY)
CREATE TABLE #DISTRICTSALES(SubType VARCHAR(255), AmountPriced MONEY, QtyPriced INT, AvgPrice MONEY)
IF @SubTypeFilter = 'S'
	BEGIN		
		/*****************************************************************************/
		/* Create Temp Table Data for All Locations Sales                            */
		/*****************************************************************************/
		INSERT #ALLSALES
		SELECT
			   s.Subject,
			   Sum(i.Price) AS AmountPriced,	   
			   Sum(i.QuantityOnHand) AS QtyPriced,
			   Avg(i.Price*i.QuantityOnHand) AS AvgPrice
		FROM   ReportsData..SipsProductInventory i inner join
			   ReportsData..SubjectSummary s 
					ON i.SubjectKey = s.SubjectKey 
		WHERE i.DateInStock between @StartDate and DateAdd(dd,1,@EndDate) and
		      i.Price < 1000
		GROUP BY s.Subject
		

		/*****************************************************************************/
		/* Create Temp Table Data for Selected Locations Sales                       */
		/*****************************************************************************/
		INSERT #SELECTEDSALES
		SELECT
			   s.Subject,
			   Sum(i.Price) AS AmountPriced,	   
			   Sum(i.QuantityOnHand) AS QtyPriced,
			   Avg(i.Price*i.QuantityOnHand) AS AvgPrice			     
		FROM   ReportsData..SipsProductInventory i inner join
			   ReportsData..SubjectSummary s 
					ON i.SubjectKey = s.SubjectKey inner join
			   #LOCS l
					ON i.LocationID = l.LocationID
		WHERE i.DateInStock between @StartDate and DateAdd(dd,1,@EndDate) and
					  i.Price < 1000
		GROUP BY s.Subject

		/*****************************************************************************/
		/* Create Temp Table Data for District Locations Sales                       */
		/*****************************************************************************/
		INSERT #DISTRICTSALES
		SELECT
			   s.Subject,
			   Sum(i.Price) AS AmountPriced,	   
			   Sum(i.QuantityOnHand) AS QtyPriced,
			   Avg(i.Price*i.QuantityOnHand) AS AvgPrice			     
		FROM   ReportsData..SipsProductInventory i inner join
			   ReportsData..SubjectSummary s 
					ON i.SubjectKey = s.SubjectKey inner join
			   #DISTRICTLOCS l
					ON i.LocationID = l.LocationID
		WHERE i.DateInStock between @StartDate and DateAdd(dd,1,@EndDate) and
					  i.Price < 1000
		GROUP BY s.Subject


		/*****************************************************************************/
		/* Select all Subject Data                                                   */
		/*****************************************************************************/

		select ISNULL(s.SubType, a.SubType) as SelectedSubject,
			   ISNULL(s.AmountPriced, 0) as SelectedAmountPriced,
			   ISNULL(s.QtyPriced, 0) as SelectedQtyPriced,
			   ISNULL(s.AvgPrice, 0) as SelectedAvgPrice,
			   ISNULL(a.SubType, a.SubType) as AllSubject,
			   ISNULL(a.AmountPriced, 0) as AllAmountPriced,
			   ISNULL(a.QtyPriced, 0) as AllQtyPriced,
			   ISNULL(a.AvgPrice, 0) as AllAvgPrice,
			   ISNULL(d.SubType, a.SubType) as DistrictSubject,
			   ISNULL(d.AmountPriced, 0) as DistrictAmountPriced,
			   ISNULL(d.QtyPriced, 0) as DistrictQtyPriced,
			   ISNULL(d.AvgPrice, 0) as DistrictAvgPrice
			   
		from #SELECTEDSALES s right outer join
			 #ALLSALES a 
				ON s.SubType = a.SubType left outer join
			 #DISTRICTSALES d
			    ON a.SubType = d.SubType
		Order by SelectedSubject
			
	END
ELSE
	BEGIN
		/*****************************************************************************/
		/* Create Temp Table Data for All Locations Sales                            */
		/*****************************************************************************/
		INSERT #ALLSALES
		SELECT
			   i.ProductType,
			   Sum(i.Price) AS AmountPriced,	   
			   Sum(i.QuantityOnHand) AS QtyPriced,
			   Avg(i.Price*i.QuantityOnHand) AS AvgPrice			   			     
		FROM   ReportsData..SipsProductInventory i inner join
			   ReportsData..SubjectSummary s 
					ON i.SubjectKey = s.SubjectKey 
		WHERE i.DateInStock between @StartDate and DateAdd(dd,1,@EndDate) and
		      i.Price < 1000
		GROUP BY i.ProductType

		/*****************************************************************************/
		/* Create Temp Table Data for Selected Locations Sales                       */
		/*****************************************************************************/
		INSERT #SELECTEDSALES
		SELECT
			   i.ProductType,
			   Sum(i.Price) AS AmountPriced,	   
			   Sum(i.QuantityOnHand) AS QtyPriced,
			   Avg(i.Price*i.QuantityOnHand) AS AvgPrice			     
		FROM   ReportsData..SipsProductInventory i inner join
			   ReportsData..SubjectSummary s 
					ON i.SubjectKey = s.SubjectKey inner join
			   #LOCS l
					ON i.LocationID = l.LocationID
		WHERE i.DateInStock between @StartDate and DateAdd(dd,1,@EndDate) and
			  i.Price < 1000
		GROUP BY i.ProductType
		
		/*****************************************************************************/
		/* Create Temp Table Data for District Locations Sales                       */
		/*****************************************************************************/
		INSERT #DISTRICTSALES
		SELECT
			   i.ProductType,
			   Sum(i.Price) AS AmountPriced,	   
			   Sum(i.QuantityOnHand) AS QtyPriced,
			   Avg(i.Price*i.QuantityOnHand) AS AvgPrice			     
		FROM   ReportsData..SipsProductInventory i inner join
			   ReportsData..SubjectSummary s 
					ON i.SubjectKey = s.SubjectKey inner join
			   #DISTRICTLOCS l
					ON i.LocationID = l.LocationID
		WHERE i.DateInStock between @StartDate and DateAdd(dd,1,@EndDate) and
			  i.Price < 1000
		GROUP BY i.ProductType		

		/*****************************************************************************/
		/* Select all Product Type Data                                              */
		/*****************************************************************************/

		select ISNULL(s.SubType, a.SubType) as SelectedType,
			   ISNULL(s.AmountPriced, 0) as SelectedAmountPriced,
			   ISNULL(s.QtyPriced, 0) as SelectedQtyPriced,
			   ISNULL(s.AvgPrice, 0) as SelectedAvgPrice,
			   ISNULL(a.SubType, a.SubType) as AllType,
			   ISNULL(a.AmountPriced, 0) as AllAmountPriced,
			   ISNULL(a.QtyPriced, 0) as AllQtyPriced,
			   ISNULL(a.AvgPrice, 0) as AllAvgPrice,
			   ISNULL(d.SubType, a.SubType) as DistrictType,
			   ISNULL(d.AmountPriced, 0) as DistrictAmountPriced,
			   ISNULL(d.QtyPriced, 0) as DistrictQtyPriced,
			   ISNULL(d.AvgPrice, 0) as DistrictAvgPrice
			   
		from #SELECTEDSALES s right outer join
			 #ALLSALES a 
				ON s.SubType = a.SubType left outer join
			 #DISTRICTSALES d 
			    ON a.SubType = d.SubType
		Order By SelectedType	

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


