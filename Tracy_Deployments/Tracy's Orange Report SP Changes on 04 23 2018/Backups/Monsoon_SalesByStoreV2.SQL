USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[Monsoon_SalesByStoreV2]    Script Date: 4/23/2018 1:25:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--1/4/2010 - RTHOMAS - Added monsoon location, this is for any location that is participating in booksmarter and the in store sales.
--RTHOMAS updated to the new View
--1/27/2017 Implemented 12/28/2017 - Tracy Dennis Total rewrite
--12/29/2017 - Tracy Dennis Removed Ship Cost. It is inaccurate. Added Total Fee, (Item) Tax, and Ship Tax.
CREATE PROCEDURE [dbo].[Monsoon_SalesByStoreV2]
	--DECLARE 
	@locations VARCHAR(MAX) --= '*'
	--='THICKET-08'
	--= 'At Location Sales'
	--= 'Dallas BookSmarter'
	--='California'
	--='iStore'
	--='THICKET-08,iStore, California'
	,@market VARCHAR(50) --= '*'
	--= 'AmazonMarketplaceUS'
	--= 'Alibris'
	,@startdate DATETIME --= '9/2/2017'
	,@enddate DATETIME --= '9/2/2017'
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
		,Quantity SMALLINT
		,Price MONEY
		,Tax MONEY
		,ShippingCredit MONEY
		,ShippingTax MONEY
		,RefundAmount MONEY
		,ReturnShipping MONEY
		--,ShipCost MONEY
		,AbebooksFee MONEY
		,AbebooksRefundFee MONEY
		,AlibrisFee MONEY
		,AlibrisRefundFee MONEY
		,AmazonFee MONEY
		,AmazonRefundFee MONEY
		,EbayFee MONEY
		,EbayRefundFee MONEY
		,HalfFee MONEY
		,HalfRefundFee MONEY
		,MonsoonCommission MONEY
		--,RefundMarketplace MONEY
		,RefundMonsoon MONEY
		,TotalFee MONEY
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
			,ShipMethod VARCHAR(23)
			,Category VARCHAR(50)
			,Channel VARCHAR(255)
			,MarketOrderID VARCHAR(63)
			,MarketOrderItemID VARCHAR(63)
			,OrderDate SMALLDATETIME
			,ShipDate SMALLDATETIME
			,RefundDate SMALLDATETIME
			,Title VARCHAR(450)
			,Price MONEY
			,Tax MONEY
			,ShippingCredit MONEY
			,ShippingTax MONEY
			--,ShipCost MONEY
			,WeightLb FLOAT
			,RefundAmount MONEY
			,ReturnShipping MONEY
			,Quantity SMALLINT
			,MktCommission MONEY
			,MktCommissionPct MONEY
			,MonsoonCommission MONEY
			,RefundMarketplace MONEY
			,RefundMonsoon MONEY
			)

		--,TotalFee MONEY
		--Last tests didn't show improvement with this or (STATUS, ShipDate, RefundAmount) 
		--CREATE NONCLUSTERED INDEX MonsoonNDX ON #Monsoon (RefundAmount) include (
		--	MarketName
		--	,STATUS
		--	,ShipMethod
		--	,Category
		--	,OrderDate
		--	,ShipDate
		--	,RefundDate
		--	,Title
		--	,Price
		--	,Tax
		--	,ShippingCredit
		--	,ShippingTax
		--	--,ShipCost
		--	,MktCommission
		--	,MktCommissionPct
		--	,MonsoonCommission
		--	)
		INSERT INTO #Monsoon (
			LocationNo
			,Location
			,MarketName
			,OrderNumber
			,STATUS
			,ShipMethod
			,Category
			,Channel
			,MarketOrderID
			,MarketOrderItemID
			,OrderDate
			,ShipDate
			,RefundDate
			,Title
			,Price
			,Tax
			,ShippingCredit
			,ShippingTax
			--,ShipCost
			,WeightLb
			,RefundAmount
			,ReturnShipping
			,Quantity
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
			,o.shipmethod
			,o.Category
			,o.MarketOrderInfo1 [Channel]
			,o.marketorderid
			,o.marketorderitemid
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
			,ISNULL(o.Tax, 0) [Tax]
			,isnull(o.shippingfee, 0) [ShippingCredit]
			,ISNULL(o.ShippingTax, 0) [ShippingTax]
			--,isnull(o.actualpostage, 0) [ShipCost]
			,0 [WeightLb]
			,CASE 
				WHEN (
						r.RefundDate >= @startdate
						AND r.RefundDate < dateadd(dd, 1, @enddate)
						AND abs(r.RefundAmount) > 0 --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive.
						)
					--only want refunds during this time period
					THEN abs(r.RefundAmount) --Saw 58 instances of negatives.  Since they were postive in iCS and Order_Monsoon think they realy should be postive. 
						--o.RefundAmount
				ELSE 0
				END [RefundAmount]
			,0 [ReturnShipping]
			,1 [Quantity]
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
			,Tax = 0
			,ShippingCredit = 0
			--,ShipCost = 0
			,ShippingTax = 0
			,Quantity = 0
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
			,Quantity
			,Price
			,Tax
			,ShippingCredit
			,ShippingTax
			,RefundAmount
			,ReturnShipping
			--,ShipCost
			,AbebooksFee
			,AbebooksRefundFee
			,AlibrisFee
			,AlibrisRefundFee
			,AmazonFee
			,AmazonRefundFee
			,EbayFee
			,EbayRefundFee
			,HalfFee
			,HalfRefundFee
			,MonsoonCommission
			--,TotalFee
			--,RefundMarketplace
			,RefundMonsoon
			,TotalFee
			)
		SELECT LocationNo
			,Location
			,MarketName
			,Quantity
			,Price
			,Tax
			,ShippingCredit
			,ShippingTax
			,RefundAmount
			,ReturnShipping
			--,ShipCost
			,CASE 
				--Abebooks
				WHEN MarketName = 'Abebooks'
					THEN MktCommission + MktCommissionPct
				END [AbebooksFee]
			,CASE 
				--Abebooks
				WHEN MarketName = 'Abebooks'
					THEN RefundMarketplace
				END [AbebooksRefundFee]
			,CASE 
				--Alibris
				WHEN MarketName = 'Alibris'
					THEN MktCommission + MktCommissionPct
				END [AlibrisFee]
			,CASE 
				--Alibris 
				WHEN MarketName = 'Alibris'
					THEN RefundMarketplace
				END [AlibrisRefundFee]
			,CASE 
				--Amazon.com 
				WHEN MarketName = 'AmazonMarketplaceUS'
					THEN MktCommission + MktCommissionPct
				END [AmazonFee]
			,CASE 
				--Amazon.com 
				WHEN MarketName = 'AmazonMarketplaceUS'
					THEN RefundMarketplace
				END [AmazonRefundFee]
			,CASE 
				--Ebay
				WHEN MarketName = 'Ebay'
					THEN MktCommission + MktCommissionPct
				END [EbayFee]
			,CASE 
				--Ebay
				WHEN MarketName = 'Ebay'
					THEN RefundMarketplace
				END [EbayRefundFee]
			,CASE 
				--Half.Com
				WHEN MarketName = 'HalfDotCom'
					THEN MktCommission + MktCommissionPct
				END [HalfFee]
			,CASE 
				--Half.com 
				WHEN MarketName = 'HalfDotCom'
					THEN RefundMarketplace
				END [HalfRefundFee]
			,MonsoonCommission [MonsoonCommission]
			--,MktCommission + MktCommissionPct + MonsoonCommission [TotalFee]
			--,RefundMarketplace
			,RefundMonsoon
			,MktCommission + MktCommissionPct + MonsoonCommission - RefundMarketplace - RefundMonsoon [TotalFee]
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
		--OnlineSalesReporting ISIS Servers, Retail Locations
	BEGIN
		CREATE TABLE #OnlineSalesReporting (
			ISIS_OrderID INT
			,LocationNo NCHAR(5)
			,Location NVARCHAR(50)
			,MarketName VARCHAR(256)
			,OrderNumber INT
			,STATUS VARCHAR(11)
			,ShipMethod VARCHAR(23)
			,Category VARCHAR(50)
			,Channel VARCHAR(255)
			,MarketOrderID VARCHAR(63)
			,MarketOrderItemID VARCHAR(63)
			,OrderDate SMALLDATETIME
			,ShipDate SMALLDATETIME
			,RefundDate SMALLDATETIME
			,Title VARCHAR(450)
			,Price MONEY
			,Tax MONEY
			,ShippingCredit MONEY
			,ShippingTax MONEY
			,ShipCost MONEY
			,WeightLb FLOAT
			,RefundAmount MONEY
			,ReturnShipping MONEY
			,Quantity SMALLINT
			,MktCommission MONEY
			,MktCommissionPct MONEY
			,MonsoonCommission MONEY
			,RefundMarketplace MONEY
			,RefundMonsoon MONEY
			)

		--Last tests didn't show improvement with this or (STATUS, ShipDate, RefundAmount) 
		--CREATE NONCLUSTERED INDEX OnlineSalesReportingNDX ON #OnlineSalesReporting (RefundAmount) include (
		--	MarketName
		--	,STATUS
		--	,ShipMethod
		--	,Category
		--	,OrderDate
		--	,ShipDate
		--	,RefundDate
		--	,Title
		--	,Price
		--	,ShippingCredit
		--	,ShipCost
		--	,MktCommission
		--	,MktCommissionPct
		--	,MonsoonCommission
		--	)
		INSERT INTO #OnlineSalesReporting (
			ISIS_OrderID
			,LocationNo
			,Location
			,MarketName
			,OrderNumber
			,STATUS
			,ShipMethod
			,Category
			,Channel
			,MarketOrderID
			,MarketOrderItemID
			,OrderDate
			,ShipDate
			,RefundDate
			,Title
			,Price
			,Tax
			,ShippingCredit
			,ShippingTax
			--,ShipCost
			,WeightLb
			,RefundAmount
			,ReturnShipping
			,Quantity
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
			,o.shipmethod
			,o.Category
			,o.Channel [Channel]
			,o.marketorderid
			,o.marketorderitemid
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
			,ISNULL(o.Tax, 0) [Tax]
			,isnull(o.shippingfee, 0) [ShippingCredit]
			,ISNULL(o.ShippingTax, 0) [ShippingTax]
			--,isnull(o.actualpostage, 0) [ShipCost]
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
			,0 [ReturnShipping]
			,1 [Quantity]
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
			,Tax = 0
			,ShippingCredit = 0
			,ShippingTax = 0
			,ShipCost = 0
			,Quantity = 0
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
		INSERT INTO #OnlineSalesReporting (
			ISIS_OrderID
			,LocationNo
			,Location
			,MarketName
			,OrderNumber
			,STATUS
			,ShipMethod
			,Category
			,Channel
			,MarketOrderID
			,MarketOrderItemID
			,OrderDate
			,ShipDate
			,RefundDate
			,Title
			,Price
			,Tax
			,ShippingCredit
			,ShippingTax
			--,ShipCost
			,WeightLb
			,RefundAmount
			,ReturnShipping
			,Quantity
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
			,o.shipmethod
			,o.Category
			,o.Channel [Channel]
			,o.marketorderid
			,o.marketorderitemid
			,o.OrderDate
			,o.ShipDate
			,NULL [RefundDate]
			,o.title
			,0 [Price]
			,0 [Tax]
			,0 [ShippingCredit]
			,0 [ShippingTax]
			--,0 [ShipCost]
			,0 [WeightLb]
			,0 [RefundAmount]
			,sum(sl.FinalPostage) [ReturnShipping]
			,0 [Quantity]
			,0 [MktCommission]
			,0 [MktCommissionPct]
			,0 [MonsoonCommission]
			,0.00 [RefundMarketplace]
			,0.00 [RefundMonsoon]
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
			,o.shipmethod
			,o.Category
			,o.Channel
			,o.marketorderid
			,o.marketorderitemid
			,o.OrderDate
			,o.ShipDate
			,o.title

		--don't need to merge since going to do sum.
		INSERT INTO #OnlineSales (
			LocationNo
			,Location
			,MarketName
			,Quantity
			,Price
			,Tax
			,ShippingCredit
			,ShippingTax
			,RefundAmount
			,ReturnShipping
			--,ShipCost
			,AbebooksFee
			,AbebooksRefundFee
			,AlibrisFee
			,AlibrisRefundFee
			,AmazonFee
			,AmazonRefundFee
			,EbayFee
			,EbayRefundFee
			,HalfFee
			,HalfRefundFee
			,MonsoonCommission
			--,TotalFee
			--,RefundMarketplace
			,RefundMonsoon
			,TotalFee
			)
		SELECT LocationNo
			,Location
			,MarketName
			,Quantity
			,Price
			,Tax
			,ShippingCredit
			,ShippingTax
			,RefundAmount
			,ReturnShipping
			--,ShipCost
			,CASE 
				--Abebooks
				WHEN MarketName = 'Abebooks'
					THEN MktCommission + MktCommissionPct
				END [AbebooksFee]
			,CASE 
				--Abebooks
				WHEN MarketName = 'Abebooks'
					THEN RefundMarketplace
				END [AbebooksRefundFee]
			,CASE 
				--Alibris
				WHEN MarketName = 'Alibris'
					THEN MktCommission + MktCommissionPct
				END [AlibrisFee]
			,CASE 
				--Alibris 
				WHEN MarketName = 'Alibris'
					THEN RefundMarketplace
				END [AlibrisRefundFee]
			,CASE 
				--Amazon.com 
				WHEN MarketName = 'AmazonMarketplaceUS'
					THEN MktCommission + MktCommissionPct
				END [AmazonFee]
			,CASE 
				--Amazon.com 
				WHEN MarketName = 'AmazonMarketplaceUS'
					THEN RefundMarketplace
				END [AmazonRefundFee]
			,CASE 
				--Ebay
				WHEN MarketName = 'Ebay'
					THEN MktCommission + MktCommissionPct
				END [EbayFee]
			,CASE 
				--Ebay
				WHEN MarketName = 'Ebay'
					THEN RefundMarketplace
				END [EbayRefundFee]
			,CASE 
				--Half.Com
				WHEN MarketName = 'HalfDotCom'
					THEN MktCommission + MktCommissionPct
				END [HalfFee]
			,CASE 
				--Half.com 
				WHEN MarketName = 'HalfDotCom'
					THEN RefundMarketplace
				END [HalfRefundFee]
			,MonsoonCommission [MonsoonCommission]
			--,MktCommission + MktCommissionPct + MonsoonCommission [TotalFee]
			--,RefundMarketplace
			,RefundMonsoon
			,MktCommission + MktCommissionPct + MonsoonCommission - RefundMarketplace - RefundMonsoon [TotalFee]
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
		,sum(isnull(Quantity, 0)) Quantity
		,sum(isnull(Price, 0)) [GrossSales]
		,SUM(isnull(Tax, 0)) [Tax]
		,sum(isnull(ShippingCredit, 0)) [ShippingCredit]
		,SUM(isnull(ShippingTax, 0)) [ShippingTax]
		,sum(isnull(RefundAmount, 0)) [RefundAmount]
		,sum(isnull(ReturnShipping, 0)) [ReturnShipping]
		--,sum(isnull(ShipCost, 0)) [ShipCost]
		,sum(isnull(AbebooksFee, 0) - (isnull(AbebooksRefundFee, 0))) [AbebooksFee]
		,sum(isnull(AlibrisFee, 0) - (isnull(AlibrisRefundFee, 0))) [AlibrisFee]
		,sum(isnull(AmazonFee, 0) - (isnull(AmazonRefundFee, 0))) [AmazonFee]
		,sum(isnull(EbayFee, 0) - (isnull(EbayRefundFee, 0))) [EbayFee]
		,sum(isnull(HalfFee, 0) - (isnull(HalfRefundFee, 0))) [HalfFee]
		,sum(isnull(MonsoonCommission, 0) - (isnull(RefundMonsoon, 0))) [MonsoonCommission]
		,sum(isnull(Price, 0) + isnull(ShippingCredit, 0) - isnull(RefundAmount, 0) - (isnull(AbebooksFee, 0) - (isnull(AbebooksRefundFee, 0))) - (isnull(AlibrisFee, 0) - (isnull(AlibrisRefundFee, 0))) - (isnull(AmazonFee, 0) - (isnull(AmazonRefundFee, 0))) - (isnull(EbayFee, 0) - (isnull(EbayRefundFee, 0))) - (isnull(HalfFee, 0) - (isnull(HalfRefundFee, 0))) - (isnull(MonsoonCommission, 0) - (isnull(RefundMonsoon, 0)))) [NetSales]
		,SUM(isnull(TotalFee, 0)) [TotalFee]
	FROM #OnlineSales
	GROUP BY LocationNo
		,Location
	ORDER BY LocationNo
		,Location

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

