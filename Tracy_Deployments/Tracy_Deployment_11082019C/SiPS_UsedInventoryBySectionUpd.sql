USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[SiPS_UsedInventoryBySection]    Script Date: 10/23/2019 1:11:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Alter PROCEDURE [dbo].[SiPS_UsedInventoryBySection]
/***************************
Mike T
SIPS Inventory By Section
10/9/2008

RThomas - 1/20/2009
Changed the location filtering and moved over to Almond
3/19/2009 - Added in a date range for date in stock.

RThomas - 4/24/2009
Removed the QOH for later dates due to a new report.

--RTHOMAS - 8/16/2010
SW#30749
Put in a having check for qtypriced for those rare cases that a section has no active items in it.
	
--RTHOMAS - 3/23/2011 
SW#43687
Divide by zero fix incase none were sold

Tracy Dennis - 10/23/2019 
SDP#10273 Outlet / BookSmarter Transfer project
Changed the Store and All logic to Support BookSmarter / Outlet. Added logic to get RptBookSmarter for @locs table.  Added to AND STATUS = 'A' to the location logic.
  Limited by date in stock and transfer date.  Added logic for BoookSmarter reports.  BookSmarter 
transfers still show as the location that sent it in sipsProductinventory.  They have a status of B when it has been sent to BookSmarter.  We have 
to look up the items trasfer tables (rIls_Data..Shipment_Header and rIls_Data..Shipment_Detail) to determine what BookSmarter location it was sent to. 
We also have to get any items directly priced in BookSmarter.
****************************/
--DECLARE 
    @FilterType CHAR(20) --= 'Store' --
	--= 'District'
	--='All Locations'
	,@DynFilter CHAR(20) --= '00690' --
	--= 'Dallas North  
	--='All'      
	,@startdate DATETIME --= '10/01/2019'
	,@enddate DATETIME --= '10/31/2019'

AS
BEGIN

set @enddate=dateadd(dd,1,@enddate)

	--declare @filterType char(20), @DynFilter char(20)
	--set @FilterType = 'District'
	--set @DynFilter = 'Dallas North        '
	--DECLARE @Location char(20)
	--SET @Location = '00008'
	--Location Filtering
	/*
DECLARE @LOCS TABLE (LocationNo CHAR(5), LocationName CHAR(30))
IF @Location = 'All'
	BEGIN
	INSERT INTO @LOCS
	SELECT 
		LocationNo, [Name]
		FROM Locations 
		WHERE LocationType = 'S'
			AND RetailStore = 'Y'
			AND Status = 'A'
	ORDER BY LocationNo
	END

IF @Location <> 'All'
	BEGIN
	INSERT INTO @LOCS
	SELECT 
	LocationNo, [Name]
		FROM Locations WHERE LocationNo = @Location
			AND Status = 'A'
	END

IF @FilterType = 'District'
	BEGIN
	INSERT INTO @LOCS
	SELECT 
	LocationNo, [Name]
		FROM ReportsData..Locations WHERE DistrictCode = @Location
	END
*/
	DECLARE @LOCS TABLE (
		LocationNo CHAR(5)
		,LocationName CHAR(30)
		,RptBookSmarter CHAR(1)
		)

	CREATE TABLE #Results (
		LocationNo CHAR(5)
		,Subject VARCHAR(255)
		,QtyPriced INT
		,QtyOnHand INT
		,SoldCount INT
		,Donates INT
		,Trash INT
		,SoldPct MONEY
		,AvgDaysToSell MONEY
		,AvgShelfLife MONEY
		,TotalSales MONEY
		,SoldMarkedDown INT
		,PctSoldMarkedDown MONEY
		,AvgSalesAmt MONEY
		,SoldAtHalf INT
		,PctSoldAtHalf MONEY
		)

	IF @FilterType = 'All Locations'
	BEGIN
		INSERT INTO @LOCS
		SELECT LocationNo
			,[Name]
			,RptBookSmarter
		FROM ReportsData..Locations l
		JOIN ReportsData..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE (
				RetailStore = 'Y'
				OR RptOutlet = 'Y'
				OR RptBookSmarter = 'Y'
				)
			AND STATUS = 'A'
		ORDER BY LocationNo
	END

	IF @FilterType = 'Store'
	BEGIN
		INSERT INTO @LOCS
		SELECT LocationNo
			,[Name]
			,RptBookSmarter
		FROM ReportsData..Locations l
		JOIN ReportsData..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE LocationNo = @DynFilter
			AND STATUS = 'A'
	END

	IF @FilterType = 'District'
	BEGIN
		INSERT INTO @LOCS
		SELECT LocationNo
			,[Name]
			,RptBookSmarter
		FROM ReportsData..Locations l
		JOIN ReportsData..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE DistrictCode = @DynFilter
			AND RetailStore = 'Y'
			AND STATUS = 'A'
	END

	IF @FilterType = 'Region'
	BEGIN
		INSERT INTO @LOCS
		SELECT LocationNo
			,[Name]
			,RptBookSmarter
		--FROM  ReportsData..ReportLocations --ReportLocations 
		FROM ReportsData..Locations l
		JOIN ReportsData..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE Region = @DynFilter
			AND STATUS = 'A'
	END

	IF @FilterType = 'RDC'
	BEGIN
		INSERT INTO @LOCS
		SELECT LocationNo
			,[Name]
			,RptBookSmarter
		FROM ReportsData..Locations l
		JOIN ReportsData..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE -- LocationType = 'R'
			--AND RetailStore = 'N'
			LocationNo NOT IN (
				'00451'
				,'00710'
				,'00999'
				)
			AND RDCLocationNo = @DynFilter
			AND RetailStore = 'Y'
	END

	IF @FilterType = 'State'
	BEGIN
		INSERT INTO @LOCS
		SELECT LocationNo
			,[Name]
			,RptBookSmarter
		FROM ReportsData..Locations l
		JOIN ReportsData..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE LocationType = 'S'
			AND RetailStore = 'Y'
			AND StateCode = @DynFilter
			AND STATUS = 'A'
		ORDER BY LocationNo
	END

	/********************************/
	/*SELECT spi.SipsID,
	spi.ItemCode,
	spi.DateInStock,
	spm.Author,
	spm.Title,
	ss.Subject,
	spi.Price,
	spi.LocationNo
FROM sipsProductinventory spi
	JOIN subjectsummary ss ON ss.SubjectKey = spi.SubjectKey
	JOIN SipsProductMaster spm	ON spm.SipsID = spi.SipsID
	LEFT JOIN sipssaleshistory ssh ON ssh.SipsItemCode = spi.ItemCode
		AND ssh.IsReturn = 'N'
	JOIN @LOCS locs
		ON spi.LocationNo = locs.LocationNo
WHERE --spi.LocationNo = '00043'
spi.Active = 'Y'
AND ssh.Itemcode IS NULL
ORDER BY ss.Subject, spm.Title*/
	DECLARE @Stores INT
		,@BookSmarter INT

	SET @Stores = (
			SELECT count(LocationNo)
			FROM @LOCS
			WHERE RptBookSmarter = 'N'
			)
	SET @BookSmarter = (
			SELECT count(LocationNo)
			FROM @LOCS
			WHERE RptBookSmarter = 'Y'
			)

	--Select @Stores[Stores]
	--Select @BookSmarter [BookSmarter]
	IF @Stores >= 1
	BEGIN
		INSERT INTO #Results (
			LocationNo
			,Subject
			,QtyPriced
			,QtyOnHand
			,SoldCount
			,Donates
			,Trash
			,SoldPct
			,AvgDaysToSell
			,AvgShelfLife
			,TotalSales
			,SoldMarkedDown
			,PctSoldMarkedDown
			,AvgSalesAmt
			,SoldAtHalf
			,PctSoldAtHalf
			)
		SELECT spi.LocationNo
			,ss.Subject
			,COUNT(*) AS QtyPriced
			,SUM(CASE 
					WHEN ssh.Itemcode IS NULL
						AND spi.Active = 'Y'
						THEN 1
					ELSE 0
					END) AS QtyOnHand
			,
			--days in section
			--	SUM(CASE WHEN spi.Active NOT IN ('D','T') AND DATEDIFF(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE())) >= 30 THEN 1 ELSE 0 END) AS QtyOnHand30days,
			--	SUM(CASE WHEN spi.Active NOT IN ('D','T') AND DATEDIFF(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE())) >= 60 THEN 1 ELSE 0 END) AS QtyOnHand60days,
			--	SUM(CASE WHEN spi.Active NOT IN ('D','T') AND DATEDIFF(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE())) >= 90 THEN 1 ELSE 0 END) AS QtyOnHand90days,
			--	SUM(CASE WHEN spi.Active NOT IN ('D','T') AND DATEDIFF(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE())) >= 120 THEN 1 ELSE 0 END) AS QtyOnHand120days,
			SUM(CASE 
					WHEN ssh.Itemcode IS NOT NULL
						AND spi.Active = 'Y'
						THEN 1
					ELSE 0
					END) AS SoldCount
			,SUM(CASE 
					WHEN spi.Active = 'D'
						THEN 1
					ELSE 0
					END) AS Donates
			,SUM(CASE 
					WHEN spi.Active = 'T'
						THEN 1
					ELSE 0
					END) AS Trash
			,
			--pct sold
			CASE 
				WHEN SUM(CASE 
							WHEN ssh.Itemcode IS NOT NULL
								AND spi.Active = 'Y'
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(CASE 
								WHEN ssh.Itemcode IS NOT NULL
									AND spi.Active = 'Y'
									THEN 1
								ELSE 0
								END) / CAST(count(*) AS MONEY) * 100
				ELSE 0
				END AS SoldPct
			,
			--AvgDaysToSell
			SUM(datediff(day, spi.DateInStock, ssh.BusinessDate)) / CAST(count(*) AS MONEY) AS AvgDaysToSell
			,--only for items that have sold!
			--shelf life
			--For all priced items that have not been trashed or donated
			--days on shelf/divided by number priced
			CASE 
				WHEN SUM(CASE 
							WHEN spi.Active NOT IN (
									'D'
									,'T'
									)
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(datediff(day, spi.DateInStock, ISNULL(ssh.BusinessDate, GETDATE()))) / CAST(SUM(CASE 
									WHEN spi.Active NOT IN (
											'D'
											,'T'
											)
										THEN 1
									ELSE 0
									END) AS MONEY)
				ELSE 0
				END AS AvgShelfLife
			,SUM(ssh.RegisterPrice) AS TotalSales
			,SUM(CASE 
					WHEN ssh.RegisterPrice < spi.Price
						THEN 1
					ELSE 0
					END) AS SoldMarkedDown
			,
			--PctSoldMarkedDown
			CASE 
				WHEN SUM(CASE 
							WHEN ssh.Itemcode IS NOT NULL
								AND spi.Active = 'Y'
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(CASE 
								WHEN ssh.RegisterPrice < spi.Price
									THEN 1
								ELSE 0
								END) / CAST(SUM(CASE 
									WHEN ssh.Itemcode IS NOT NULL
										AND spi.Active = 'Y'
										THEN 1
									ELSE 0
									END) AS MONEY) * 100
				ELSE 0
				END AS PctSoldMarkedDown
			,
			--RTHOMAS - Divide by zero fix incase none were sold
			CASE 
				WHEN SUM(CASE 
							WHEN ssh.Itemcode IS NOT NULL
								AND spi.Active = 'Y'
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(ssh.RegisterPrice) / SUM(CASE 
								WHEN ssh.Itemcode IS NOT NULL
									AND spi.Active = 'Y'
									THEN 1
								ELSE 0
								END)
				ELSE 0
				END AS AvgSalesAmt
			,
			--# sold at half
			SUM(CASE 
					WHEN ssh.RegisterPrice >= ((MfgSuggestedPrice / 2) - .02)
						THEN 1
					ELSE 0
					END) AS SoldAtHalf
			,
			--PctSoldAtHalf
			CASE 
				WHEN SUM(CASE 
							WHEN ssh.Itemcode IS NOT NULL
								AND spi.Active = 'Y'
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(CASE 
								WHEN ssh.RegisterPrice >= ((MfgSuggestedPrice / 2) - .02)
									THEN 1
								ELSE 0
								END) / CAST(SUM(CASE 
									WHEN ssh.Itemcode IS NOT NULL
										AND spi.Active = 'Y'
										THEN 1
									ELSE 0
									END) AS MONEY) * 100
				ELSE 0
				END AS PctSoldAtHalf
		FROM ReportsData..SipsProductMaster spm
		JOIN ReportsData..SipsProductInventory spi ON spm.sipsid = spi.sipsid
		LEFT JOIN ReportsData..sipssaleshistory ssh ON ssh.SipsItemCode = spi.ItemCode
			AND ssh.IsReturn = 'N'
		JOIN ReportsData..subjectsummary ss ON ss.SubjectKey = spi.SubjectKey
		JOIN @LOCS locs ON spi.LocationNo = locs.LocationNo
			AND locs.RptBookSmarter = 'N'
		WHERE --spi.LocationNo = '00043' 
			spi.dateinstock >= @startdate
			AND dateinstock < @enddate
		GROUP BY spi.LocationNo
			,ss.Subject
		--RTHOMAS - Put in for those rare cases that there is one item in a section that is not active.
		HAVING COUNT(*) > 0
	END

	IF @BookSmarter >= 1
	BEGIN
		CREATE TABLE #RawData (
			LocationNo CHAR(5)
			,Subject VARCHAR(255)
			,SipsItemCode INT
			,DateInStock DATETIME
			,BusinessDate SMALLDATETIME
			,RegisterPrice MONEY
			,Price MONEY
			,Itemcode CHAR(20)
			,MfgSuggestedPrice MONEY
			,Active CHAR(1)
			)

		--Get items transfered to BookSmarter
		SELECT spi.LocationNo
			,ss.Subject
			,spi.Itemcode [SipsItemCode]
			,spi.DateInStock
			,ssh.BusinessDate
			,ssh.RegisterPrice
			,spi.Price
			,ssh.Itemcode
			,spm.MfgSuggestedPrice
			,spi.Active
		INTO #SIPS
		FROM ReportsData..SipsProductMaster spm
		JOIN ReportsData..SipsProductInventory spi ON spm.sipsid = spi.sipsid
		LEFT JOIN ReportsData..sipssaleshistory ssh ON ssh.SipsItemCode = spi.ItemCode
			AND ssh.IsReturn = 'N'
		JOIN ReportsData..subjectsummary ss ON ss.SubjectKey = spi.SubjectKey
		WHERE spi.dateinstock >= @startdate
			AND spi.dateinstock < @enddate
			AND spi.Active = 'B' --Transfered to BookSmarter location

			--select * from #SIPS
			--where Itemcode is not null

		--Of the items sent to BookSmarter determine where it was transfered to BookSmarter location looking for
		INSERT INTO #RawData (
			LocationNo
			,Subject
			,SipsItemCode
			,DateInStock
			,BusinessDate
			,RegisterPrice
			,Price
			,Itemcode
			,MfgSuggestedPrice
			,Active
			)
		SELECT sh.ToLocationNo [LocationNo]
			,s.Subject
			,s.SipsItemCode
			,s.DateInStock
			,s.BusinessDate
			,s.RegisterPrice
			,s.Price
			,s.Itemcode
			,s.MfgSuggestedPrice
			,s.Active
		FROM rIls_Data..Shipment_Header sh
		JOIN rIls_Data..Shipment_Detail sd ON sh.ShipmentNo = sd.ShipmentNo
			AND sh.ShipmentType = sd.ShipmentType
		JOIN #SIPS S ON sd.sipsitemcode = s.sipsitemcode
		JOIN @LOCS locs ON sh.ToLocationNo = locs.LocationNo
			AND locs.RptBookSmarter = 'Y'
		WHERE sh.datetransferred >= @StartDate
			AND sh.datetransferred < @EndDate
			AND sh.ShipmentType = 'B' --transfered to BookSmarter
--select * from #RawData

		--Items that were priced at BookSmarter locations
		INSERT INTO #RawData (
			LocationNo
			,Subject
			,SipsItemCode
			,DateInStock
			,BusinessDate
			,RegisterPrice
			,Price
			,Itemcode
			,MfgSuggestedPrice
			,Active
			)
		SELECT spi.LocationNo
			,ss.Subject
			,spi.Itemcode [SipsItemCode]
			,spi.DateInStock
			,ssh.BusinessDate
			,ssh.RegisterPrice
			,spi.Price
			,ssh.Itemcode
			,spm.MfgSuggestedPrice
			,spi.Active
		FROM ReportsData..SipsProductMaster spm
		JOIN ReportsData..SipsProductInventory spi ON spm.sipsid = spi.sipsid
		LEFT JOIN ReportsData..sipssaleshistory ssh ON ssh.SipsItemCode = spi.ItemCode
			AND ssh.IsReturn = 'N'
		JOIN ReportsData..subjectsummary ss ON ss.SubjectKey = spi.SubjectKey
		JOIN @LOCS locs ON spi.LocationNo = locs.LocationNo
			AND locs.RptBookSmarter = 'Y'
		WHERE spi.dateinstock >= @startdate
			AND dateinstock < @enddate

		--Items transfered to BookSmarter and Items priced at BookSmarter
		INSERT INTO #Results (
			LocationNo
			,Subject
			,QtyPriced
			,QtyOnHand
			,SoldCount
			,Donates
			,Trash
			,SoldPct
			,AvgDaysToSell
			,AvgShelfLife
			,TotalSales
			,SoldMarkedDown
			,PctSoldMarkedDown
			,AvgSalesAmt
			,SoldAtHalf
			,PctSoldAtHalf
			)
		SELECT LocationNo
			,Subject
			--,SUM(CASE 
			--		WHEN  Active <> 'B' --ones with Status other that B were price at BookSmarter location
			--		THEN 1
			--		ELSE 0
			--		END) AS QtyPriced
			,COUNT(*) AS QtyPriced
			,SUM(CASE 
					WHEN Itemcode IS NULL
						AND Active IN (
							'Y'
							,'B'
							)
						THEN 1
					ELSE 0
					END) AS QtyOnHand
			,
			--days in section
			SUM(CASE 
					WHEN Itemcode IS NOT NULL
						AND Active IN (
							'Y'
							,'B'
							)
						THEN 1
					ELSE 0
					END) AS SoldCount
			,SUM(CASE 
					WHEN Active = 'D'
						THEN 1
					ELSE 0
					END) AS Donates
			,SUM(CASE 
					WHEN Active = 'T'
						THEN 1
					ELSE 0
					END) AS Trash
			,
			--pct sold
			CASE 
				WHEN SUM(CASE 
							WHEN Itemcode IS NOT NULL
								AND Active IN (
									'Y'
									,'B'
									)
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(CASE 
								WHEN Itemcode IS NOT NULL
									AND Active IN (
										'Y'
										,'B'
										)
									THEN 1
								ELSE 0
								END) / CAST(count(*) AS MONEY) * 100
				ELSE 0
				END AS SoldPct
			,
			--AvgDaysToSell
			SUM(datediff(day, DateInStock, BusinessDate)) / CAST(count(*) AS MONEY) AS AvgDaysToSell
			,--only for items that have sold!
			--shelf life
			--For all priced items that have not been trashed or donated
			--days on shelf/divided by number priced
			CASE 
				WHEN SUM(CASE 
							WHEN Active NOT IN (
									'D'
									,'T'
									)
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(datediff(day, DateInStock, ISNULL(BusinessDate, GETDATE()))) / CAST(SUM(CASE 
									WHEN Active NOT IN (
											'D'
											,'T'
											)
										THEN 1
									ELSE 0
									END) AS MONEY)
				ELSE 0
				END AS AvgShelfLife
			,SUM(RegisterPrice) AS TotalSales
			,SUM(CASE 
					WHEN RegisterPrice < Price
						THEN 1
					ELSE 0
					END) AS SoldMarkedDown
			,
			--PctSoldMarkedDown
			CASE 
				WHEN SUM(CASE 
							WHEN Itemcode IS NOT NULL
								AND Active IN (
									'Y'
									,'B'
									)
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(CASE 
								WHEN RegisterPrice < Price
									THEN 1
								ELSE 0
								END) / CAST(SUM(CASE 
									WHEN Itemcode IS NOT NULL
										AND Active IN (
											'Y'
											,'B'
											)
										THEN 1
									ELSE 0
									END) AS MONEY) * 100
				ELSE 0
				END AS PctSoldMarkedDown
			,
			--RTHOMAS - Divide by zero fix incase none were sold
			CASE 
				WHEN SUM(CASE 
							WHEN Itemcode IS NOT NULL
								AND Active IN (
									'Y'
									,'B'
									)
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(RegisterPrice) / SUM(CASE 
								WHEN Itemcode IS NOT NULL
									AND Active IN (
										'Y'
										,'B'
										)
									THEN 1
								ELSE 0
								END)
				ELSE 0
				END AS AvgSalesAmt
			,
			--# sold at half
			SUM(CASE 
					WHEN RegisterPrice >= ((MfgSuggestedPrice / 2) - .02)
						THEN 1
					ELSE 0
					END) AS SoldAtHalf
			,
			--PctSoldAtHalf
			CASE 
				WHEN SUM(CASE 
							WHEN Itemcode IS NOT NULL
								AND Active IN (
									'Y'
									,'B'
									)
								THEN 1
							ELSE 0
							END) > 0
					THEN SUM(CASE 
								WHEN RegisterPrice >= ((MfgSuggestedPrice / 2) - .02)
									THEN 1
								ELSE 0
								END) / CAST(SUM(CASE 
									WHEN Itemcode IS NOT NULL
										AND Active IN (
											'Y'
											,'B'
											)
										THEN 1
									ELSE 0
									END) AS MONEY) * 100
				ELSE 0
				END AS PctSoldAtHalf
		FROM #RawData
		GROUP BY LocationNo
			,Subject
		HAVING COUNT(*) > 0

		DROP TABLE #SIPS
		DROP TABLE #RawData
	END

	SELECT LocationNo
		,Subject
		,QtyPriced
		,QtyOnHand
		,SoldCount
		,Donates
		,Trash
		,SoldPct
		,AvgDaysToSell
		,AvgShelfLife
		,TotalSales
		,SoldMarkedDown
		,PctSoldMarkedDown
		,AvgSalesAmt
		,SoldAtHalf
		,PctSoldAtHalf
	FROM #Results
	ORDER BY LocationNo
		,Subject

	

	DROP TABLE #Results
END
GO


