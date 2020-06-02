USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[Monsoon_SalesByStore_DetailV2]    Script Date: 4/23/2018 1:26:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--1/4/2010 - RTHOMAS - Added monsoon location, this is for any location that is participating in booksmarter and the in store sales.
--RTHOMAS updated to the new View
--1/2/2017   - Tracy Dennis Total rewrite
--11/22/2017 - Tracy Dennis Changes to use Monsoon..Refunds.  Had found returns where the LastStatusModified was not updated so going back to using Monsoon..Refunds.
--Both the above changes were implemented 12/28/2017 Tracy Dennis.
CREATE PROCEDURE [dbo].[Monsoon_SalesByStore_DetailV2]
	--DECLARE 
	@locations VARCHAR(MAX) --= '*'
	--='THICKET-08'
	--= 'At Location Sales'
	--= 'Dallas BookSmarter'
	--='California'
	--='iStore'
	--='THICKET-08,iStore, California'
	--='Ohio BookSmarter'
	,@market VARCHAR(50) --= '*'
	--= 'AmazonMarketplaceUS'
	--= 'Alibris'
	,@startdate DATETIME
	--= '9/2/2017'
	,@enddate DATETIME
	--= '9/2/2017'
AS
IF OBJECT_ID('tempDB..#ReturnShipping') IS NOT NULL
	DROP TABLE #ReturnShipping

IF OBJECT_ID('tempDB..#Monsoon') IS NOT NULL
	DROP TABLE #Monsoon

IF OBJECT_ID('tempDB..#OnlineSales') IS NOT NULL
	DROP TABLE #OnlineSales

IF OBJECT_ID('tempDB..#OnlineSalesReporting') IS NOT NULL
	DROP TABLE #OnlineSalesReporting

IF OBJECT_ID('tempDB..#markets') IS NOT NULL
	DROP TABLE #markets

IF OBJECT_ID('tempDB..#locs') IS NOT NULL
	DROP TABLE #locs

IF OBJECT_ID('tempDB..#ListingInstance') IS NOT NULL
	DROP TABLE #ListingInstance

DECLARE @locsCount SMALLINT = 0
	,@ListingInstanceCount SMALLINT = 0

BEGIN
	CREATE TABLE #markets (
		marketname VARCHAR(50)
		,marketdisplay VARCHAR(50)
		)

	IF @market = '*'
	BEGIN
		INSERT #markets
		SELECT marketname
			,marketdisplay
		FROM monsoon..markets
		WHERE STATUS = 'A'
	END

	IF @market <> '*'
	BEGIN
		INSERT #markets
		SELECT marketname
			,marketdisplay
		FROM monsoon..markets
		WHERE STATUS = 'A'
			AND marketname = @market
	END

	CREATE TABLE #locs (
		ServerID INT
		,Location VARCHAR(50)
		)

	CREATE TABLE #ListingInstance (
		ListingInstanceID SMALLINT
		,ServerName VARCHAR(50)
		)

	IF @locations = '*'
	BEGIN
		INSERT #locs
		SELECT ServerID
			,CASE --Want to use longer name that than the source table allows
				WHEN Location = 'California'
					THEN 'California BookSmarter'
				WHEN Location = 'Washington'
					THEN 'Washington BookSmarter'
				ELSE Location
				END [Location]
		FROM Monsoon.dbo.MonsoonServers
		WHERE ServerID <> 9 --At Location Sales on Monsoon now on ISIS

		INSERT #ListingInstance
		SELECT ListingInstanceID
			,CASE --Want to consolidate all the individual iStore servers as one location iStore
				WHEN Category = 'iStore'
					THEN Category
				ELSE ServerName
				END [ServerName]
		FROM OnlineSalesReporting..App_ListingInstances
		WHERE Category IN (
				'iStore'
				,'CON iStore'
				,'BookSmarter'
				)
	END

	IF @locations <> '*'
	BEGIN
		INSERT #locs
		SELECT ServerID
			,CASE --Want to use longer name that than the source table allows
				WHEN Location = 'California'
					THEN 'California BookSmarter'
				WHEN Location = 'Washington'
					THEN 'Washington BookSmarter'
				ELSE Location
				END [Location]
		FROM Monsoon.dbo.MonsoonServers
		WHERE Location IN (
				SELECT DISTINCT sID
				FROM dbo.FN_CDC_ListStringToTable(@locations)
				)

		INSERT #ListingInstance
		SELECT ListingInstanceID
			,CASE --Want to consolidate all the individual iStore servers as one location iStore
				WHEN Category = 'iStore'
					THEN Category
				ELSE ServerName
				END [ServerName]
		FROM OnlineSalesReporting..App_ListingInstances
		WHERE Category IN (
				SELECT DISTINCT sID
				FROM dbo.FN_CDC_ListStringToTable(@locations)
				)
			OR ServerName IN (
				SELECT DISTINCT sID
				FROM dbo.FN_CDC_ListStringToTable(@locations)
				)
	END

	SET @locsCount = (
			SELECT count(*)
			FROM #locs
			)
	SET @ListingInstanceCount = (
			SELECT Count(*)
			FROM #ListingInstance
			)

	CREATE TABLE #OnlineSales (
		LocationNo NCHAR(5)
		,Location NVARCHAR(50)
		,MarketName VARCHAR(256)
		,OrderNumber VARCHAR(50)
		,MarketOrderID VARCHAR(63)
		,MarketOrderItemID VARCHAR(63)
		,SKU VARCHAR(63)
		,ShipMethod VARCHAR(23)
		,Category VARCHAR(50)
		,Channel VARCHAR(255)
		,Title VARCHAR(450)
		,STATUS VARCHAR(11)
		,Country VARCHAR(255)
		,OrderDate SMALLDATETIME
		,ShipDate SMALLDATETIME
		,RefundDate SMALLDATETIME
		,OrderedQuantity SMALLINT
		,ShippedQuantity SMALLINT
		,Price MONEY
		,ShippingCredit MONEY
		,TotalPrice MONEY
		,RefundAmount MONEY
		,RefundType VARCHAR(15)
		,ReturnShipping MONEY
		,ShipCost MONEY
		,WeightLb FLOAT
		,AbebooksMktComm MONEY
		,AbebooksMktCommPct MONEY
		,AlibrisMktComm MONEY
		,AlibrisMktCommPct MONEY
		,AmazonMktComm MONEY
		,AmazonMktCommPct MONEY
		,EbayMktComm MONEY
		,EbayMktCommPct MONEY
		,HalfMktComm MONEY
		,HalfMktCommPct MONEY
		,MonsoonCommission MONEY
		,RefundMarketplace MONEY
		,RefundMonsoon MONEY
		)

	IF @locsCount >= 1
		--Monsoon Servers Booksmarter and Outlet stores
	BEGIN
		CREATE TABLE #Monsoon (
			LocationNo NCHAR(5)
			,Location NVARCHAR(50)
			,MarketName VARCHAR(256)
			,OrderNumber INT
			,STATUS VARCHAR(11)
			,Country VARCHAR(255)
			,ShipMethod VARCHAR(23)
			,Category VARCHAR(50)
			,Channel VARCHAR(255)
			,MarketOrderID VARCHAR(63)
			,MarketOrderItemID VARCHAR(63)
			,SKU VARCHAR(63)
			,OrderDate SMALLDATETIME
			,ShipDate SMALLDATETIME
			,RefundDate SMALLDATETIME
			,Title VARCHAR(450)
			,Price MONEY
			,ShippingCredit MONEY
			,ShipCost MONEY
			,WeightLb FLOAT
			,RefundAmount MONEY
			,RefundType VARCHAR(15)
			,ReturnShipping MONEY
			,OrderedQuantity SMALLINT
			,ShippedQuantity SMALLINT
			,TotalPrice MONEY
			,MktCommission MONEY
			,MktCommissionPct MONEY
			,MonsoonCommission MONEY
			,RefundMarketplace MONEY
			,RefundMonsoon MONEY
			)

		CREATE NONCLUSTERED INDEX MonsoonNDX ON #Monsoon (RefundAmount) include (
			MarketName
			,STATUS
			,Country
			,ShipMethod
			,Category
			,OrderDate
			,ShipDate
			,RefundDate
			,Title
			,Price
			,ShippingCredit
			,ShipCost
			,MktCommission
			,MktCommissionPct
			,MonsoonCommission
			)

		INSERT INTO #Monsoon (
			LocationNo
			,Location
			,MarketName
			,OrderNumber
			,STATUS
			,Country
			,ShipMethod
			,Category
			,Channel
			,MarketOrderID
			,MarketOrderItemID
			,SKU
			,OrderDate
			,ShipDate
			,RefundDate
			,Title
			,Price
			,ShippingCredit
			,ShipCost
			,WeightLb
			,RefundAmount
			,RefundType
			,ReturnShipping
			,OrderedQuantity
			,ShippedQuantity
			,TotalPrice
			,MktCommission
			,MktCommissionPct
			,MonsoonCommission
			,RefundMarketplace
			,RefundMonsoon
			)
		SELECT ('00' + o.LocationNo) [LocationNo]
			,l.location
			,o.marketname
			,o.OrderNumber
			,o.STATUS
			,o.Country
			,o.shipmethod
			,o.Category
			,o.MarketOrderInfo1 [Channel]
			,o.marketorderid
			,o.marketorderitemid
			,o.SKU
			,o.OrderDate
			,o.ShipDate
			,CASE 
				WHEN (
						r.RefundDate >= @startdate
						AND r.RefundDate < dateadd(dd, 1, @enddate)
						AND abs(r.RefundAmount) > 0 --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive.
						)
					--only want populate date of refunds during this time period		
					THEN r.RefundDate
				ELSE NULL
				END [RefundDate]
			,o.title
			,isnull(o.price, 0) [Price]
			,isnull(o.shippingfee, 0) [ShippingCredit]
			,isnull(o.actualpostage, 0) [ShipCost]
			,0 [WeightLb]
			,CASE 
				WHEN (
						r.RefundDate >= @startdate
						AND r.RefundDate < dateadd(dd, 1, @enddate)
						AND abs(r.RefundAmount) > 0 --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive.
						)
					--only want refunds during this time period
					THEN abs(r.RefundAmount) --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive.
				ELSE 0
				END [RefundAmount]
			,CASE 
				WHEN (
						abs(r.RefundAmount) = 0
						OR r.RefundAmount IS NULL
						)
					OR (
						(
							r.RefundDate < @startdate
							OR r.RefundDate >= dateadd(dd, 1, @enddate)
							)
						AND abs(r.RefundAmount) > 0
						) --Refund in a different time period
					THEN 'No Refund'
				WHEN abs(r.RefundAmount) >= (Price + ShippingFee)
					THEN 'Full Refund'
				ELSE 'Partial Refund'
				END [RefundType]
			,0 [ReturnShipping]
			,ISNULL(o.OrderedQuantity, 0) [OrderedQuantity]
			,isnull(o.shippedquantity, 0) [ShippedQuantity]
			,isnull(o.price, 0) + isnull(o.shippingfee, 0) [TotalPrice]
			,(
				SELECT MarketCommission
				FROM OnlineSalesReporting..ReturnMarketPlaceFees(o.MarketName, o.Category, o.OrderDate, o.Price, o.shipmethod, o.ShippingFee, o.marketorderinfo1, o.MarketOrderID, o.MarketOrderItemID, o.Title, o.STATUS, CASE 
							WHEN (
									r.RefundDate >= @startdate
									AND r.RefundDate < dateadd(dd, 1, @enddate)
									AND abs(r.RefundAmount) > 0 --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive.
									) --make sure that refunds are only this time period
								THEN r.RefundDate
							ELSE NULL
							END, 0, Country, o.ShipDate)
				) [MktCommission]
			,(
				SELECT MarketCommissionPercent
				FROM OnlineSalesReporting..ReturnMarketPlaceFees(o.MarketName, o.Category, o.OrderDate, o.Price, o.shipmethod, o.ShippingFee, o.marketorderinfo1, o.MarketOrderID, o.MarketOrderItemID, o.Title, o.STATUS, CASE 
							WHEN (
									r.RefundDate >= @startdate
									AND r.RefundDate < dateadd(dd, 1, @enddate)
									AND abs(r.RefundAmount) > 0 --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive.
									) --make sure that refunds are only this time period
								THEN r.RefundDate
							ELSE NULL
							END, 0, Country, o.ShipDate)
				) [MktCommissionPct]
			,(
				SELECT MonsoonCommission
				FROM OnlineSalesReporting..ReturnMarketPlaceFees(o.MarketName, o.Category, o.OrderDate, o.Price, o.shipmethod, o.ShippingFee, o.marketorderinfo1, o.MarketOrderID, o.MarketOrderItemID, o.Title, o.STATUS, CASE 
							WHEN (
									r.RefundDate >= @startdate
									AND r.RefundDate < dateadd(dd, 1, @enddate)
									AND abs(r.RefundAmount) > 0 --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive.
									) --make sure that refunds are only this time period
								THEN r.RefundDate
							ELSE NULL
							END, 0, Country, o.ShipDate)
				) [MonsoonCommission]
			,0.00 [RefundMarketplace]
			,0.00 [RefundMonsoon]
		FROM Monsoon..OrderDetailsReporting o WITH (NOLOCK)
		LEFT JOIN monsoon..refunds r ON r.ServerID = o.ServerID
			AND o.OrderNumber = r.OrderNumber
			AND o.MarketOrderItemID = r.MarketOrderItemID
		JOIN #markets mt ON mt.marketname = o.marketname
		JOIN #locs l ON o.ServerID = l.ServerID
		WHERE (
				o.shipdate >= @startdate
				AND o.shipdate < dateadd(dd, 1, @enddate)
				AND o.STATUS = 'Shipped'
				)
			OR (
				r.RefundDate >= @startdate
				AND r.RefundDate < dateadd(dd, 1, @enddate)
				AND abs(r.RefundAmount) > 0 --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive.
				)

		--Get the commission fee refunds
		UPDATE #Monsoon
		SET RefundMarketplace = (
				SELECT RefundMarketplace
				FROM OnlineSalesReporting..ReturnMarketPlaceRefunds(MarketName, Category, OrderDate, Price, ShipMethod, ShippingCredit, Title, RefundAmount, STATUS, MktCommission, MktCommissionPct, MonsoonCommission, RefundDate)
				)
			,RefundMonsoon = (
				SELECT RefundMonsoon
				FROM OnlineSalesReporting..ReturnMarketPlaceRefunds(MarketName, Category, OrderDate, Price, ShipMethod, ShippingCredit, Title, RefundAmount, STATUS, MktCommission, MktCommissionPct, MonsoonCommission, RefundDate)
				)
		WHERE RefundAmount > 0;

		--Since refunds can happen in different periods need to zero out fields so they don't get counted twice.  This doesn't apply to canceled refunds or those 
		--that happened during this period. Needed to be after the refunds were done.  The fields were needed to calculate the Refund of the fees.
		UPDATE #Monsoon
		SET price = 0
			,ShippingCredit = 0
			,ShipCost = 0
			,TotalPrice = 0
			,OrderedQuantity = 0
			,ShippedQuantity = 0
			,MktCommission = 0
			,MktCommissionpct = 0
			,MonsoonCommission = 0
		WHERE RefundAmount > 0
			AND STATUS = 'Shipped'
			AND (
				shipdate < @startdate
				OR shipdate >= dateadd(dd, 1, @enddate)
				)

		INSERT INTO #OnlineSales (
			LocationNo
			,Location
			,MarketName
			,OrderNumber
			,MarketOrderID
			,MarketOrderItemID
			,SKU
			,ShipMethod
			,Category
			,Channel
			,Title
			,STATUS
			,Country
			,OrderDate
			,ShipDate
			,RefundDate
			,OrderedQuantity
			,ShippedQuantity
			,Price
			,ShippingCredit
			,TotalPrice
			,RefundAmount
			,RefundType
			,ReturnShipping
			,ShipCost
			,WeightLb
			,AbebooksMktComm
			,AbebooksMktCommPct
			,AlibrisMktComm
			,AlibrisMktCommPct
			,AmazonMktComm
			,AmazonMktCommPct
			,EbayMktComm
			,EbayMktCommPct
			,HalfMktComm
			,HalfMktCommPct
			,MonsoonCommission
			,RefundMarketplace
			,RefundMonsoon
			)
		SELECT LocationNo
			,Location
			,MarketName
			,OrderNumber
			,MarketOrderID
			,MarketOrderItemID
			,SKU
			,ShipMethod
			,Category
			,Channel
			,Title
			,STATUS [Status]
			,Country
			,OrderDate
			,ShipDate
			,RefundDate
			,OrderedQuantity
			,ShippedQuantity
			,Price
			,ShippingCredit
			,TotalPrice
			,RefundAmount
			,RefundType
			,ReturnShipping
			,ShipCost
			,WeightLb
			,CASE 
				WHEN MarketName = 'Abebooks'
					THEN MktCommission
				END [AbebooksMktComm]
			,CASE 
				--Abebooks
				WHEN MarketName = 'Abebooks'
					THEN MktCommissionPct
				END [AbebooksMktCommPct]
			,CASE 
				--Alibris
				WHEN MarketName = 'Alibris'
					THEN MktCommission
				END [AlibrisMktComm]
			,CASE 
				--Alibris 
				WHEN MarketName = 'Alibris'
					THEN MktCommissionPct
				END [AlibrisMktCommPct]
			,CASE 
				--Amazon.com 
				WHEN MarketName = 'AmazonMarketplaceUS'
					THEN MktCommission
				END [AmazonMktComm]
			,CASE 
				--Amazon.com 
				WHEN MarketName = 'AmazonMarketplaceUS'
					THEN MktCommissionPct
				END [AmazonMktCommPct]
			,CASE 
				--Ebay
				WHEN MarketName = 'Ebay'
					THEN MktCommission
				END [EbayMktComm]
			,CASE 
				--Ebay
				WHEN MarketName = 'Ebay'
					THEN MktCommissionPct
				END [EbayMktCommPct]
			,CASE 
				--Half.Com
				WHEN MarketName = 'HalfDotCom'
					THEN MktCommission
				END [HalfMktComm]
			,CASE 
				--Half.com 
				WHEN MarketName = 'HalfDotCom'
					THEN MktCommissionPct
				END [HalfMktCommPct]
			,MonsoonCommission
			,RefundMarketplace
			,RefundMonsoon
		FROM #Monsoon
		ORDER BY LocationNo
			,Location
			,MarketName
			,CASE 
				WHEN ShipDate = '1900-01-01 00:00:00' --Most canceled refunds default to this date.
					THEN RefundDate
				WHEN ShipDate IS NULL --Some canceled refunds have this.
					THEN RefundDate
				ELSE ShipDate
				END
	END -- Monsoon 

	IF @ListingInstanceCount >= 1
		--OnlineSalesReporting is from the ISIS Servers, It is the Retail Locations
	BEGIN
		CREATE TABLE #OnlineSalesReporting (
			ISIS_OrderID INT
			,LocationNo NCHAR(5)
			,Location NVARCHAR(50)
			,MarketName VARCHAR(256)
			,OrderNumber INT
			,STATUS VARCHAR(11)
			,Country VARCHAR(255)
			,ShipMethod VARCHAR(23)
			,Category VARCHAR(50)
			,Channel VARCHAR(255)
			,MarketOrderID VARCHAR(63)
			,MarketOrderItemID VARCHAR(63)
			,SKU VARCHAR(50)
			,OrderDate SMALLDATETIME
			,ShipDate SMALLDATETIME
			,RefundDate SMALLDATETIME
			,Title VARCHAR(450)
			,Price MONEY
			,ShippingCredit MONEY
			,ShipCost MONEY
			,WeightLb FLOAT
			,RefundAmount MONEY
			,RefundType VARCHAR(15)
			,ReturnShipping MONEY
			,OrderedQuantity SMALLINT
			,ShippedQuantity SMALLINT
			,TotalPrice MONEY
			,MktCommission MONEY
			,MktCommissionPct MONEY
			,MonsoonCommission MONEY
			,RefundMarketplace MONEY
			,RefundMonsoon MONEY
			)

		CREATE NONCLUSTERED INDEX OnlineSalesReportingNDX ON #OnlineSalesReporting (RefundAmount) include (
			MarketName
			,STATUS
			,Country
			,ShipMethod
			,Category
			,OrderDate
			,ShipDate
			,RefundDate
			,Title
			,Price
			,ShippingCredit
			,ShipCost
			,MktCommission
			,MktCommissionPct
			,MonsoonCommission
			)

		INSERT INTO #OnlineSalesReporting (
			ISIS_OrderID
			,LocationNo
			,Location
			,MarketName
			,OrderNumber
			,STATUS
			,Country
			,ShipMethod
			,Category
			,Channel
			,MarketOrderID
			,MarketOrderItemID
			,SKU
			,OrderDate
			,ShipDate
			,RefundDate
			,Title
			,Price
			,ShippingCredit
			,ShipCost
			,WeightLb
			,RefundAmount
			,RefundType
			,ReturnShipping
			,OrderedQuantity
			,ShippedQuantity
			,TotalPrice
			,MktCommission
			,MktCommissionPct
			,MonsoonCommission
			,RefundMarketplace
			,RefundMonsoon
			)
		SELECT o.ISIS_OrderID
			,f.HPBLocationNo [LocationNo]
			,li.ServerName [Location]
			,o.marketname
			,o.MonsoonOrderID [OrderNumber]
			,o.OrderStatus [Status]
			,o.Country
			,o.shipmethod
			,o.Category
			,o.Channel [Channel]
			,o.marketorderid
			,o.marketorderitemid
			,o.SKU
			,o.OrderDate
			,o.ShipDate
			,CASE 
				WHEN (
						o.RefundDate >= @startdate
						AND o.RefundDate < dateadd(dd, 1, @enddate)
						AND o.RefundAmount > 0
						)
					--only want populate date of refunds during this time period		
					THEN RefundDate
				ELSE NULL
				END [RefundDate]
			,o.title
			,isnull(o.price, 0) [Price]
			,isnull(o.shippingfee, 0) [ShippingCredit]
			,isnull(o.actualpostage, 0) [ShipCost]
			,CASE 
				WHEN o.Weight IS NULL
					OR Weight = ''
					THEN 0
				WHEN o.Weight LIKE '%pounds%' --need to strip off pounds constant
					THEN cast(replace(o.weight, ' pounds', 0) AS FLOAT)
				ELSE o.weight
				END [WeightLb]
			,CASE 
				WHEN (
						o.RefundDate >= @startdate
						AND o.RefundDate < dateadd(dd, 1, @enddate)
						AND o.RefundAmount > 0
						)
					--only want refunds during this time period
					THEN o.RefundAmount
				ELSE 0
				END [RefundAmount]
			,CASE 
				WHEN RefundAmount = 0
					OR (
						(
							RefundDate < @startdate
							OR RefundDate >= dateadd(dd, 1, @enddate)
							)
						AND RefundAmount > 0
						) --don't want to count out of period refunds
					THEN 'No Refund'
				WHEN RefundAmount >= (o.Price + o.ShippingFee)
					THEN 'Full Refund'
				ELSE 'Partial Refund'
				END [RefundType]
			,0 [ReturnShipping]
			,ISNULL(o.OrderedQuantity, 0) [OrderedQuantity]
			,isnull(o.shippedquantity, 0) [ShippedQuantity]
			,isnull(o.price, 0) + isnull(o.shippingfee, 0) [TotalPrice]
			,(
				SELECT MarketCommission
				FROM OnlineSalesReporting..ReturnMarketPlaceFees(o.MarketName, o.Category, o.OrderDate, o.Price, o.shipmethod, o.ShippingFee, o.Channel, o.MarketOrderID, o.MarketOrderItemID, o.Title, o.OrderStatus, CASE 
							WHEN (
									o.RefundDate >= @startdate
									AND o.RefundDate < dateadd(dd, 1, @enddate)
									AND o.RefundAmount > 0
									)
								THEN o.RefundDate
							ELSE NULL
							END, CASE 
							WHEN o.Weight IS NULL
								OR o.Weight = ''
								THEN 0
							WHEN o.Weight LIKE '%pounds%' --need to strip off pounds constant
								THEN cast(replace(o.weight, ' pounds', 0) AS FLOAT)
							ELSE o.weight
							END, Country, o.ShipDate)
				) [MktCommission]
			,(
				SELECT MarketCommissionPercent
				FROM OnlineSalesReporting..ReturnMarketPlaceFees(o.MarketName, o.Category, o.OrderDate, o.Price, o.shipmethod, o.ShippingFee, o.Channel, o.MarketOrderID, o.MarketOrderItemID, o.Title, o.OrderStatus, CASE 
							WHEN (
									o.RefundDate >= @startdate
									AND o.RefundDate < dateadd(dd, 1, @enddate)
									AND o.RefundAmount > 0
									)
								THEN o.RefundDate
							ELSE NULL
							END, CASE 
							WHEN o.Weight IS NULL
								OR o.Weight = ''
								THEN 0
							WHEN o.Weight LIKE '%pounds%' --need to strip off pounds constant
								THEN cast(replace(o.weight, ' pounds', 0) AS FLOAT)
							ELSE o.weight
							END, Country, o.ShipDate)
				) [MktCommissionPct]
			,(
				SELECT MonsoonCommission
				FROM OnlineSalesReporting..ReturnMarketPlaceFees(o.MarketName, o.Category, o.OrderDate, o.Price, o.shipmethod, o.ShippingFee, o.Channel, o.MarketOrderID, o.MarketOrderItemID, o.Title, o.OrderStatus, CASE 
							WHEN (
									o.RefundDate >= @startdate
									AND o.RefundDate < dateadd(dd, 1, @enddate)
									AND o.RefundAmount > 0
									)
								THEN o.RefundDate
							ELSE NULL
							END, CASE 
							WHEN o.Weight IS NULL
								OR o.Weight = ''
								THEN 0
							WHEN o.Weight LIKE '%pounds%' --need to strip off pounds constant
								THEN cast(replace(o.weight, ' pounds', 0) AS FLOAT)
							ELSE o.weight
							END, Country, o.ShipDate)
				) [MonsoonCommission]
			,0.00 [RefundMarketplace]
			,0.00 [RefundMonsoon]
		FROM OnlineSalesReporting..Order_Monsoon o WITH (NOLOCK)
		JOIN #markets mt ON mt.marketname = o.marketname
		JOIN #ListingInstance li ON o.ListingInstanceID = li.ListingInstanceID
		JOIN OnlineSalesReporting..App_Facilities f WITH (NOLOCK) ON o.FacilityID = f.FacilityID
		WHERE (
				o.shipdate >= @startdate
				AND o.shipdate < dateadd(dd, 1, @enddate)
				AND o.OrderStatus = 'Shipped'
				)
			OR (
				o.RefundDate >= @startdate
				AND o.RefundDate < dateadd(dd, 1, @enddate)
				AND o.RefundAmount > 0
				)

		--Get the commission fee refunds
		UPDATE #OnlineSalesReporting
		SET RefundMarketplace = (
				SELECT RefundMarketplace
				FROM OnlineSalesReporting..ReturnMarketPlaceRefunds(MarketName, Category, OrderDate, Price, ShipMethod, ShippingCredit, Title, RefundAmount, STATUS, MktCommission, MktCommissionPct, MonsoonCommission, RefundDate)
				)
			,RefundMonsoon = (
				SELECT RefundMonsoon
				FROM OnlineSalesReporting..ReturnMarketPlaceRefunds(MarketName, Category, OrderDate, Price, ShipMethod, ShippingCredit, Title, RefundAmount, STATUS, MktCommission, MktCommissionPct, MonsoonCommission, RefundDate)
				)
		WHERE RefundAmount > 0;

		--Since refunds can happen in different periods need to zero out fields so they don't get counted twice.  This doesn't apply to canceled refunds or those 
		--that happened during this period. Needed to be after the refunds were done.  The fields were needed to calculate the Refund of the fees.		
		UPDATE #OnlineSalesReporting
		SET price = 0
			,ShippingCredit = 0
			,ShipCost = 0
			,TotalPrice = 0
			,OrderedQuantity = 0
			,ShippedQuantity = 0
			,MktCommission = 0
			,MktCommissionpct = 0
			,MonsoonCommission = 0
		WHERE RefundAmount > 0
			AND STATUS = 'Shipped'
			AND (
				shipdate < @startdate
				OR shipdate >= dateadd(dd, 1, @enddate)
				)

		--Need to get return postage that is sent to customers.  It is only available for USPS customers.  Only want for item that return labels were printed during the 
		--current time period. Have to use sum since sometimes multiple lables are printed.  Since return postage can happen in different periods need to zero out fields so they don't get counted twice. 
		SELECT o.ISIS_OrderID
			,f.HPBLocationNo [LocationNo]
			,li.ServerName [Location]
			,o.marketname
			,o.MonsoonOrderID [OrderNumber]
			,o.OrderStatus [Status]
			,o.Country
			,o.shipmethod
			,o.Category
			,o.Channel [Channel]
			,o.marketorderid
			,o.marketorderitemid
			,o.SKU
			,o.OrderDate
			,o.ShipDate
			,NULL [RefundDate]
			,o.title
			,0 [Price]
			,0 [ShippingCredit]
			,0 [ShipCost]
			,0 [WeightLb]
			,0 [RefundAmount]
			,'Postage Refund' [RefundType]
			,sum(sl.FinalPostage) [ReturnShipping]
			,0 [OrderedQuantity]
			,0 [ShippedQuantity]
			,0 [TotalPrice]
			,0 [MktCommission]
			,0 [MktCommissionPct]
			,0 [MonsoonCommission]
			,0.00 [RefundMarketplace]
			,0.00 [RefundMonsoon]
		INTO #ReturnShipping
		FROM OnlineSalesReporting..Order_Monsoon o WITH (NOLOCK)
		JOIN #markets mt ON mt.marketname = o.marketname
		JOIN #ListingInstance li ON o.ListingInstanceID = li.ListingInstanceID
		JOIN OnlineSalesReporting..App_Facilities f WITH (NOLOCK) ON o.FacilityID = f.FacilityID
		JOIN ReportsData..OFS_Order_Header oh WITH (NOLOCK) ON o.ISIS_OrderID = oh.ISISOrderID
			AND oh.OrderSystem = 'MON' --Monsoon 
			--It can be in both status because it is not always update to returned or could be in process of happening.  Joining to the ReportsData..CS_PostageMapping is saying that 
			--Customer Service (iCS) issued a return.
			AND oh.STATUS IN (
				3
				,5
				) --3 Shipped, 5 Refunded
		JOIN ReportsData..CS_PostageMapping m ON oh.orderid = m.orderid
		JOIN ReportsData..PostS_Shipping_Labels sl ON m.LabelID = sl.LabelID
			AND sl.PostalID = 1 --1 USPS , only USPS has FinalPostage 
		WHERE m.PostDate >= @startdate
			AND m.PostDate < dateadd(dd, 1, @enddate)
			AND o.OrderStatus = 'shipped' --Only want items that have been shipped	
		GROUP BY o.ISIS_OrderID
			,f.HPBLocationNo
			,li.ServerName
			,o.marketname
			,o.MonsoonOrderID
			,o.OrderStatus
			,o.Country
			,o.shipmethod
			,o.Category
			,o.Channel
			,o.marketorderid
			,o.marketorderitemid
			,o.SKU
			,o.OrderDate
			,o.ShipDate
			,o.title

		--Need to merge #ReturnShipping into #OnlineSalesReporting where row exits and add it into #OnlineSalesReporting, if it doesn't.
		MERGE INTO #OnlineSalesReporting AS TGT
		USING #ReturnShipping AS SRC
			ON TGT.ISIS_OrderID = SRC.ISIS_OrderID
		WHEN MATCHED
			THEN
				UPDATE
				SET TGT.ReturnShipping = SRC.ReturnShipping
		WHEN NOT MATCHED
			THEN
				INSERT (
					ISIS_OrderID
					,LocationNo
					,Location
					,MarketName
					,OrderNumber
					,STATUS
					,Country
					,ShipMethod
					,Category
					,Channel
					,MarketOrderID
					,MarketOrderItemID
					,SKU
					,OrderDate
					,ShipDate
					,RefundDate
					,Title
					,Price
					,ShippingCredit
					,ShipCost
					,WeightLb
					,RefundAmount
					,RefundType
					,ReturnShipping
					,OrderedQuantity
					,ShippedQuantity
					,TotalPrice
					,MktCommission
					,MktCommissionPct
					,MonsoonCommission
					,RefundMarketplace
					,RefundMonsoon
					)
				VALUES (
					SRC.ISIS_OrderID
					,SRC.LocationNo
					,SRC.Location
					,SRC.MarketName
					,SRC.OrderNumber
					,SRC.STATUS
					,SRC.Country
					,SRC.ShipMethod
					,SRC.Category
					,SRC.Channel
					,SRC.MarketOrderID
					,SRC.MarketOrderItemID
					,SRC.SKU
					,SRC.OrderDate
					,SRC.ShipDate
					,SRC.RefundDate
					,SRC.Title
					,SRC.Price
					,SRC.ShippingCredit
					,SRC.ShipCost
					,SRC.WeightLb
					,SRC.RefundAmount
					,SRC.RefundType
					,SRC.ReturnShipping
					,SRC.OrderedQuantity
					,SRC.ShippedQuantity
					,SRC.TotalPrice
					,SRC.MktCommission
					,SRC.MktCommissionPct
					,SRC.MonsoonCommission
					,SRC.RefundMarketplace
					,SRC.RefundMonsoon
					);

		INSERT INTO #OnlineSales (
			LocationNo
			,Location
			,MarketName
			,OrderNumber
			,MarketOrderID
			,MarketOrderItemID
			,SKU
			,ShipMethod
			,Category
			,Channel
			,Title
			,STATUS
			,Country
			,OrderDate
			,ShipDate
			,RefundDate
			,OrderedQuantity
			,ShippedQuantity
			,Price
			,ShippingCredit
			,TotalPrice
			,RefundAmount
			,RefundType
			,ReturnShipping
			,ShipCost
			,WeightLb
			,AbebooksMktComm
			,AbebooksMktCommPct
			,AlibrisMktComm
			,AlibrisMktCommPct
			,AmazonMktComm
			,AmazonMktCommPct
			,EbayMktComm
			,EbayMktCommPct
			,HalfMktComm
			,HalfMktCommPct
			,MonsoonCommission
			,RefundMarketplace
			,RefundMonsoon
			)
		SELECT LocationNo
			,Location
			,MarketName
			,OrderNumber
			,MarketOrderID
			,MarketOrderItemID
			,SKU
			,ShipMethod
			,Category
			,Channel
			,Title
			,STATUS [Status]
			,Country
			,OrderDate
			,ShipDate
			,RefundDate
			,OrderedQuantity
			,ShippedQuantity
			,Price
			,ShippingCredit
			,TotalPrice
			,RefundAmount
			,RefundType
			,ReturnShipping
			,ShipCost
			,WeightLb
			--Abebooks 
			,CASE 
				WHEN MarketName = 'Abebooks'
					THEN MktCommission
				END [AbebooksMktComm]
			,CASE 
				--Abebooks
				WHEN MarketName = 'Abebooks'
					THEN MktCommissionPct
				END [AbebooksMktCommPct]
			,CASE 
				--Alibris
				WHEN MarketName = 'Alibris'
					THEN MktCommission
				END [AlibrisMktComm]
			,CASE 
				--Alibris 
				WHEN MarketName = 'Alibris'
					THEN MktCommissionPct
				END [AlibrisMktCommPct]
			,CASE 
				--Amazon.com 
				WHEN MarketName = 'AmazonMarketplaceUS'
					THEN MktCommission
				END [AmazonMktComm]
			,CASE 
				--Amazon.com 
				WHEN MarketName = 'AmazonMarketplaceUS'
					THEN MktCommissionPct
				END [AmazonMktCommPct]
			,CASE 
				--Ebay
				WHEN MarketName = 'Ebay'
					THEN MktCommission
				END [EbayMktComm]
			,CASE 
				--Ebay
				WHEN MarketName = 'Ebay'
					THEN MktCommissionPct
				END [EbayMktCommPct]
			,CASE 
				--Half.Com
				WHEN MarketName = 'HalfDotCom'
					THEN MktCommission
				END [HalfMktComm]
			,CASE 
				--Half.com 
				WHEN MarketName = 'HalfDotCom'
					THEN MktCommissionPct
				END [HalfMktCommPct]
			,MonsoonCommission
			,RefundMarketplace
			,RefundMonsoon
		FROM #OnlineSalesReporting
		ORDER BY LocationNo
			,Location
			,MarketName
			,CASE 
				WHEN ShipDate = '1900-01-01 00:00:00'
					THEN RefundDate
				WHEN ShipDate IS NULL
					THEN RefundDate
				ELSE ShipDate
				END
	END -- OnlineSalesReporting 

	SELECT LocationNo
		,Location
		,CASE 
			WHEN MarketName = 'AmazonMarketplaceUS'
				THEN 'Amazon'
			ELSE MarketName
			END [MarketName]
		,OrderNumber
		,MarketOrderID
		,MarketOrderItemID
		,SKU
		,ShipMethod
		,Category
		,Channel
		,Title
		,STATUS [Status]
		,Country
		,OrderDate
		,ShipDate
		,RefundDate
		,OrderedQuantity
		,ShippedQuantity
		,Price
		,ShippingCredit
		,TotalPrice
		,RefundAmount
		,RefundType
		,ReturnShipping
		,ShipCost
		,WeightLb
		,AbebooksMktComm
		,AbebooksMktCommPct
		,AlibrisMktComm
		,AlibrisMktCommPct
		,AmazonMktComm
		,AmazonMktCommPct
		,EbayMktComm
		,EbayMktCommPct
		,HalfMktComm
		,HalfMktCommPct
		,MonsoonCommission
		,RefundMarketplace
		,RefundMonsoon
	FROM #OnlineSales
	ORDER BY LocationNo
		,Location
		,CASE 
			WHEN MarketName = 'AmazonMarketplaceUS'
				THEN 'Amazon'
			ELSE MarketName
			END
		,CASE 
			WHEN ShipDate = '1900-01-01 00:00:00'
				THEN RefundDate
			WHEN ShipDate IS NULL
				THEN RefundDate
			ELSE ShipDate
			END

	IF OBJECT_ID('tempDB..#Monsoon') IS NOT NULL
		DROP TABLE #Monsoon

	IF OBJECT_ID('tempDB..#OnlineSales') IS NOT NULL
		DROP TABLE #OnlineSales

	IF OBJECT_ID('tempDB..#OnlineSalesReporting') IS NOT NULL
		DROP TABLE #OnlineSalesReporting

	IF OBJECT_ID('tempDB..#ReturnShipping') IS NOT NULL
		DROP TABLE #ReturnShipping

	IF OBJECT_ID('tempDB..#markets') IS NOT NULL
		DROP TABLE #markets

	IF OBJECT_ID('tempDB..#locs') IS NOT NULL
		DROP TABLE #locs

	IF OBJECT_ID('tempDB..#ListingInstance') IS NOT NULL
		DROP TABLE #ListingInstance
END


GO

