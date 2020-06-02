USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[SIPS_UsedInventory]    Script Date: 10/18/2019 4:00:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[SIPS_UsedInventory]
/***************************
RThomas
Sips report to view stores current SIPS inventory.
6/3/2008

RThomas - 7/15/2011 - SW#38053
Added create user to the query

RThomas - 7/27/2011 - SW#38449
Added product types

Tracy Dennis - 10/21/2019 #10273 Outlet / BookSmarter Transfer project
Copied from Weirwood SIPS..RPT_UsedInventory.  Modified to run on Orange.  Changed the name to SIPS_UsedInventory. Commented out the All logic.  
This report is to big to be run for All Locations.  Limited by date in stock and transfer date.  Added logic for BoookSmarter reports.  BookSmarter 
transfers still show as the location that sent it in sipsProductinventory.  They have a status of B when it has been sent to BookSmarter.  We have 
to look up the items trasfer tables (rIls_Data..Shipment_Header and rIls_Data..Shipment_Detail) to determine what BookSmarter location it was sent to. 
We also have to get any items directly priced in BookSmarter.  Added Publisher and Shelfid and logic to get the shelf.
****************************/
--DECLARE 
     @Location CHAR(5) --= '00290'
	,@StartDate DATE --= '10/1/2019'
	,@EndDate DATE --= '10/31/2019'

AS
BEGIN
	--DECLARE @Location char(5)
	--SET @Location = '00001'
	SET @EndDate = dateadd(dd, 1, @EndDate)

	--Location Filtering
	DECLARE @LOCS TABLE (
		LocationNo CHAR(5)
		,LocationName CHAR(30)
		,RptBookSmarter CHAR(1)
		)

	--too much data to run for all can only be run by store.
	--IF @Location = 'All'
	--	BEGIN
	--	INSERT INTO @LOCS
	--	SELECT 
	--		LocationNo, [Name]
	--		FROM Locations 
	--		WHERE LocationType = 'S'
	--			AND RetailStore = 'Y'
	--			AND Status = 'A'
	--	ORDER BY LocationNo
	--	END
	BEGIN
		INSERT INTO @LOCS
		SELECT LocationNo
			,[Name]
			,RptBookSmarter
		FROM ReportsData..Locations l
		JOIN ReportsData..LocationsDist ld ON l.LocationID = ld.LocationID
		WHERE l.LocationNo = @Location
			AND l.STATUS = 'A'
	END

	/*
IF @FilterType = 'District'
	BEGIN
	INSERT INTO @LOCS
	SELECT 
	LocationNo, [Name]
		FROM ReportsData..Locations WHERE DistrictCode = @Location
	END
*/
	DECLARE @RptBookSmarter CHAR(1) = (
			SELECT RptBookSmarter
			FROM @LOCS
			)

--Get last scan for shelf
select s.shelfid
,locs.locationno
,max(shelfscanid)[shelfscanid]
into #shelf
from ReportsData..shelfscan sc with (nolock)
join ReportsData..shelf s on sc.shelfid = s.shelfid
join ReportsData..locations l on l.locationid = s.locationid
join @locs locs on l.locationno = locs.locationno
group by s.shelfid, locs.locationno
	/********************************/
	IF @RptBookSmarter = 'N' --Stores, Alt Stores, Outlet
	BEGIN
		SELECT spi.SipsID
			,spi.ItemCode
			,spi.DateInStock
			,spm.Author
			,spm.Title
			,ss.Subject
			,spi.ProductType
			,spi.Price
			,spi.LocationNo
			,replace(spi.CreateUser, 'HPB\', '') [CreateUser]
			,spm.PublisherName
			,sh.ShelfProxyID
		FROM ReportsData..sipsProductinventory spi WITH (NOLOCK)
		JOIN ReportsData..subjectsummary ss WITH (NOLOCK) ON ss.SubjectKey = spi.SubjectKey
		JOIN ReportsData..SipsProductMaster spm WITH (NOLOCK) ON spm.SipsID = spi.SipsID
		LEFT JOIN ReportsData..sipssaleshistory ssh WITH (NOLOCK) ON ssh.SipsItemCode = spi.ItemCode
			AND ssh.IsReturn = 'N'
		JOIN @LOCS locs ON spi.LocationNo = locs.LocationNo
		left join ReportsData..ShelfItemScan sis WITH (NOLOCK) on spi.itemcode = sis.itemcodesips
		left join #shelf s on sis.shelfscanid=s.shelfscanid
		left join Reportsdata..shelf sh WITH (NOLOCK) ON s.ShelfID=sh.ShelfID

		WHERE --spi.LocationNo = '00043'
			spi.DateInStock >= @StartDate
			AND spi.DateInStock < @EndDate
			AND spi.Active = 'Y'
			AND ssh.Itemcode IS NULL
		ORDER BY ss.Subject
			,spm.Title
	END
	ELSE IF @RptBookSmarter = 'Y' --BookSmarter
	BEGIN
		--Items that have been sent to BookSmarter
		SELECT spi.SipsID
			,spi.ItemCode
			,spi.DateInStock
			,spm.Author
			,spm.Title
			,ss.Subject
			,spi.ProductType
			,spi.Price
			,spi.LocationNo
			,replace(spi.CreateUser, 'HPB\', '') [CreateUser]
			,spm.PublisherName
		INTO #Sips
		FROM ReportsData..sipsProductinventory spi WITH (NOLOCK)
		JOIN ReportsData..subjectsummary ss WITH (NOLOCK) ON ss.SubjectKey = spi.SubjectKey
		JOIN ReportsData..SipsProductMaster spm WITH (NOLOCK) ON spm.SipsID = spi.SipsID
		LEFT JOIN ReportsData..sipssaleshistory ssh WITH (NOLOCK) ON ssh.SipsItemCode = spi.ItemCode
			AND ssh.IsReturn = 'N'
		WHERE spi.DateInStock >= @StartDate
			AND spi.DateInStock < @EndDate
			AND spi.Active = 'B' ---Transfered to BookSmarter location
			AND ssh.Itemcode IS NULL
		ORDER BY ss.Subject
			,spm.Title

		--Of the items sent to BookSmarter determine where it was transfered to
		SELECT s.SipsID
			,s.ItemCode
			,s.DateInStock
			,s.Author
			,s.Title
			,s.Subject
			,s.ProductType
			,s.Price
			,sh.ToLocationNo [LocationNo]
			,s.CreateUser
			,s.PublisherName
		FROM rIls_Data..Shipment_Header sh
		JOIN rIls_Data..Shipment_Detail sd ON sh.ShipmentNo = sd.ShipmentNo
			AND sh.ShipmentType = sd.ShipmentType
		JOIN #Sips S ON sd.sipsitemcode  = s.itemcode 
		WHERE sh.datetransferred >= @StartDate
			AND sh.datetransferred < @EndDate
			AND sh.ToLocationNo = @Location
			AND sh.ShipmentType = 'B'
		
		UNION
		
		--get items that were priced at the BookSmarter location
		SELECT spi.SipsID
			,spi.ItemCode
			,spi.DateInStock
			,spm.Author
			,spm.Title
			,ss.Subject
			,spi.ProductType
			,spi.Price
			,spi.LocationNo
			,replace(spi.CreateUser, 'HPB\', '') [CreateUser]
			,spm.PublisherName
		FROM ReportsData..sipsProductinventory spi WITH (NOLOCK)
		JOIN ReportsData..subjectsummary ss WITH (NOLOCK) ON ss.SubjectKey = spi.SubjectKey
		JOIN ReportsData..SipsProductMaster spm WITH (NOLOCK) ON spm.SipsID = spi.SipsID
		LEFT JOIN ReportsData..sipssaleshistory ssh WITH (NOLOCK) ON ssh.SipsItemCode = spi.ItemCode
			AND ssh.IsReturn = 'N'
		JOIN @LOCS locs ON spi.LocationNo = locs.LocationNo --Items that were SIPS at BookSmarter location
		WHERE spi.DateInStock >= @StartDate
			AND spi.DateInStock < @EndDate
			AND spi.Active = 'Y' --Active status
			AND ssh.Itemcode IS NULL
		ORDER BY Subject
			,Title

		DROP TABLE #Sips
	END

	DROP TABLE #Shelf
END
GO


