USE [Reports]
GO
/****** Object:  StoredProcedure [dbo].[RDA_MGT_EmployeeMetrics]    Script Date: 7/22/2019 10:44:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 2/28/19
-- Description:	Get employee metrics data from roll-up table
-- =============================================
ALTER PROCEDURE [dbo].[RDA_MGT_EmployeeMetrics]
	-- Add the parameters for the stored procedure here
	@LocationNo CHAR(5),
	@Employee_Login VARCHAR(20),
	@StartDate DATE,
	@EndDate DATE
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--Store location data in temp table
SELECT
	LocationNo,
	Employee_Login,
	BusinessMonth,
	
	--Register data
	reg_count_SalesTrans,
	reg_count_SalesReturns,
	reg_count_SalesVoids,
	
	--Buy data (buy level)
	buys_count_BuyTrans,
	buys_count_TotalQty,
	buys_total_TotalOffer,
	buys_total_BuyScans,
	buys_total_BuyWait,
	
	--Buy data (item level)
	buys_total_qtyHB,
	buys_total_amtHB,
	buys_total_qtyPB,
	buys_total_amtPB,
	buys_total_qtyDVD,
	buys_total_amtDVD,
	buys_total_qtyCD,
	buys_total_amtCD,
	buys_total_qtyLP,
	buys_total_amtLP,
	
	--Scan data
	scans_count_SingleScans,
	scans_count_FullScans,
	
	--Pricing data
		--All SIPS
	SIPS_count_qtyAll,
	SIPS_total_amtAll,
	
		--UN SIPS
	SIPS_count_qtyUN,
	SIPS_total_amtUN,
	
		--PB SIPS
	SIPS_count_qtyPB,
	SIPS_total_amtPB,
	
		--NOST SIPS
	SIPS_count_qtyNOST,
	SIPS_total_amtNOST,
	
		--DVD SIPS
	SIPS_count_qtyDVD,
	SIPS_total_amtDVD,
	
		--CD SIPS
	SIPS_count_qtyCD,
	SIPS_total_amtCD,
	
		--LP SIPS
	SIPS_count_qtyLP,
	SIPS_total_amtLP,
	
		--BDGU SIPS
	SIPS_count_qtyBDGU,
	SIPS_total_amtBDGU,
	
		--ELTU SIPS
	SIPS_count_qtyELTU,
	SIPS_total_amtELTU,
	
		--OrdersData
	orders_count_SAS,
	orders_count_XFR,
	orders_amt_SAS,
	orders_amt_XFR
INTO #LocationMetrics
FROM Sandbox..RU_EmployeeMetrics 
WHERE 
		LocationNo = @LocationNo
	AND Employee_Login = @LocationNo
	AND BusinessMonth >= @StartDate
	AND BusinessMonth <= @EndDate

--Compare employee and location metrics.
--Notes:
--1) Means of means are not true means.
--2) *ISNULL not yet included.* All divisions implement ISNULL(n/NULLIF(d, 0), " ") logic. The end " ", which anywhere else is bad practice, 
--		is to display a blank cell instead of NaN in the report resulting from this query. 
--3) Percentage calculation between employee and location means are simplified as follows.
--		V=values, N=number of values, _e=employee numbers, _l=location numbers
--		For example: 
--			V_e / N_e is an employee mean
--			V_l / N_l is a location mean
--		(V_e / N_e) / (V_l / N_l) is equivalent to (V_e * N_l) / (V_l * N_e)
-- This simplifies the SQL by reducing the number of NULLIFs the first statement would require.
SELECT
	em.LocationNo,
	em.Employee_Login,
	
	--Employee Register Metrics
	SUM(em.reg_count_SalesTrans)	[reg_count_EmpSalesTrans],
	SUM(em.reg_count_SalesReturns)	[reg_count_EmpSalesReturns],
	SUM(em.reg_count_SalesVoids)	[reg_count_EmpSalesVoids],
	
	--Location Register Metrics
	SUM(lm.reg_count_SalesTrans)	[reg_count_LocSalesTrans],
	SUM(lm.reg_count_SalesReturns)	[reg_count_LocSalesReturns],
	SUM(lm.reg_count_SalesVoids)	[reg_count_LocSalesVoids],
	
	--Pct Comp Register Metrics
	SUM(CAST(em.reg_count_SalesTrans AS FLOAT))/
		NULLIF(SUM(CAST(lm.reg_count_SalesTrans AS FLOAT)), 0)		[reg_pctof_SalesTrans],

	SUM(CAST(em.reg_count_SalesReturns AS FLOAT))/
		NULLIF(SUM(CAST(lm.reg_count_SalesReturns AS FLOAT)), 0)	[reg_pctof_SalesReturns],

	SUM(CAST(em.reg_count_SalesVoids AS FLOAT))/
		NULLIF(SUM(CAST(lm.reg_count_SalesVoids AS FLOAT)), 0)		[reg_pctof_SalesVoids],
	
	--Employee Buy Metrics
	SUM(em.buys_count_BuyTrans)												[buys_ttl_EmpBuyTrans],
	SUM(em.buys_count_TotalQty)												[buys_ttl_EmpBuyQty],
	SUM(em.buys_total_TotalOffer)/NULLIF(SUM(em.buys_count_BuyTrans), 0)	[buys_avg_EmpTotalOffer],
	SUM(em.buys_total_TotalOffer)/NULLIF(SUM(em.buys_count_TotalQty), 0)	[buys_avg_EmpItemOffer],
	CAST(SUM(em.buys_count_TotalQty) AS FLOAT)/
		NULLIF(CAST(SUM(em.buys_count_BuyTrans) AS FLOAT), 0)				[buys_avg_EmpItemsPerBuy],
	SUM(em.buys_total_BuyScans)/NULLIF(SUM(em.buys_count_BuyTrans), 0)		[buys_avg_EmpScansPerBuy],
	SUM(em.buys_total_BuyWait)/NULLIF(SUM(em.buys_count_BuyTrans), 0)		[buys_avg_EmpBuyWait], -- In minutes
	(SUM(em.buys_total_BuyWait)/NULLIF(SUM(em.buys_count_TotalQty), 0))*60	[buys_avg_EmpItemWait], -- In seconds
	
	--Location Buy Metrics
	SUM(lm.buys_count_BuyTrans)												[buys_ttl_LocBuyTrans],
	SUM(lm.buys_count_TotalQty)												[buys_ttl_LocBuyQty],
	SUM(lm.buys_total_TotalOffer)/NULLIF(SUM(lm.buys_count_BuyTrans), 0)	[buys_avg_LocTotalOffer],
	SUM(lm.buys_total_TotalOffer)/NULLIF(SUM(lm.buys_count_TotalQty), 0)	[buys_avg_LocItemOffer],
	CAST(SUM(lm.buys_count_TotalQty) AS FLOAT)/
		NULLIF(CAST(SUM(lm.buys_count_BuyTrans) AS FLOAT), 0)				[buys_avg_LocItemsPerBuy],
	SUM(lm.buys_total_BuyScans)/NULLIF(SUM(lm.buys_count_BuyTrans), 0)		[buys_avg_LocScansPerBuy],
	SUM(lm.buys_total_BuyWait)/NULLIF(SUM(lm.buys_count_BuyTrans), 0)		[buys_avg_LocBuyWait], -- In minutes
	(SUM(lm.buys_total_BuyWait)/NULLIF(SUM(lm.buys_count_TotalQty), 0))*60	[buys_avg_LocItemWait], -- In seconds
	
	--Pct Comp Buy Metrics
	CAST(SUM(em.buys_count_BuyTrans) AS FLOAT)/
		NULLIF(CAST(SUM(lm.buys_count_BuyTrans) AS FLOAT), 0)										[buys_ttl_PctOfBuyTrans],

	CAST(SUM(em.buys_count_TotalQty) AS FLOAT)/
		NULLIF(CAST(SUM(lm.buys_count_TotalQty) AS FLOAT), 0)										[buys_ttl_PctOfTotalQty],	
	
	(SUM(em.buys_total_TotalOffer)*SUM(lm.buys_count_BuyTrans))/
		NULLIF((SUM(lm.buys_total_TotalOffer)*SUM(em.buys_count_BuyTrans)), 0) - 1					[buys_avg_PctDiffTotalOffer],
	
	(SUM(em.buys_total_TotalOffer)*SUM(lm.buys_count_TotalQty))/
		NULLIF((SUM(lm.buys_total_TotalOffer)*SUM(em.buys_count_TotalQty)), 0) - 1					[buys_avg_PctDiffItemOffer],

	CAST(SUM(em.buys_count_TotalQty)*SUM(lm.buys_count_BuyTrans) AS FLOAT)/
		NULLIF(CAST(SUM(lm.buys_count_TotalQty)*SUM(em.buys_count_BuyTrans) AS FLOAT), 0) - 1		[buys_avg_PctDiffItemsPerBuy],
	--	
	CAST(SUM(em.buys_total_BuyScans)*SUM(lm.buys_count_BuyTrans) AS FLOAT)/
		NULLIF(CAST(SUM(lm.buys_total_BuyScans)*SUM(em.buys_count_BuyTrans) AS FLOAT), 0) - 1		[buys_avg_PctDiffScansPerBuy],
	
	(SUM(em.buys_total_BuyWait)*SUM(lm.buys_count_BuyTrans))/
		NULLIF((SUM(lm.buys_total_BuyWait)*SUM(em.buys_count_BuyTrans)), 0) - 1						[buys_avg_PctDiffEmpBuyWait],
	
	(SUM(em.buys_total_BuyWait)*SUM(lm.buys_count_TotalQty))/
		NULLIF((SUM(lm.buys_total_BuyWait)*SUM(em.buys_count_TotalQty)), 0) - 1						[buys_avg_PctDiffEmpItemWait],
	
	--Employee Buy Item Metrics
	SUM(em.buys_total_qtyHB)							[buys_total_EmpQtyHB],
	SUM(em.buys_total_amtHB)/
		NULLIF(SUM(em.buys_total_qtyHB), 0)				[buys_avg_EmpAmtHB],
	SUM(em.buys_total_qtyPB)							[buys_total_EmpQtyPB],
	SUM(em.buys_total_amtPB)/
		NULLIF(SUM(em.buys_total_qtyPB), 0)				[buys_avg_EmpAmtPB],		
	SUM(em.buys_total_qtyDVD)							[buys_total_EmpQtyDVD],
	SUM(em.buys_total_amtDVD)/
		NULLIF(SUM(em.buys_total_qtyDVD), 0)			[buys_avg_EmpAmtDVD],	
	SUM(em.buys_total_qtyCD)							[buys_total_EmpQtyCD],
	SUM(em.buys_total_amtCD)/
		NULLIF(SUM(em.buys_total_qtyCD), 0)				[buys_avg_EmpAmtCD],
	SUM(em.buys_total_qtyLP)							[buys_total_EmpQtyLP],
	SUM(em.buys_total_amtLP)/
		NULLIF(SUM(em.buys_total_qtyLP), 0)				[buys_avg_EmpAmtLP],

	--Location Buy Item Metrics
	SUM(lm.buys_total_qtyHB)							[buys_total_LocQtyHB],
	SUM(lm.buys_total_amtHB)/
		NULLIF(SUM(lm.buys_total_qtyHB), 0)				[buys_avg_LocAmtHB],
	SUM(lm.buys_total_qtyPB)							[buys_total_LocQtyPB],
	SUM(lm.buys_total_amtPB)/
		NULLIF(SUM(lm.buys_total_qtyPB), 0)				[buys_avg_LocAmtPB],
	SUM(lm.buys_total_qtyDVD)							[buys_total_LocQtyDVD],
	SUM(lm.buys_total_amtDVD)/
		NULLIF(SUM(lm.buys_total_qtyDVD), 0)			[buys_avg_LocAmtDVD],
	SUM(lm.buys_total_qtyCD)							[buys_total_LocQtyCD],
	SUM(lm.buys_total_amtCD)/
		NULLIF(SUM(lm.buys_total_qtyCD), 0)				[buys_avg_LocAmtCD],
	SUM(lm.buys_total_qtyLP)							[buys_total_LocQtyLP],
	SUM(lm.buys_total_amtLP)/
		NULLIF(SUM(lm.buys_total_qtyLP), 0)				[buys_avg_LocAmtLP],

	--Pct Comp Buy Item Metrics
	(SUM(em.buys_total_amtHB)*SUM(lm.buys_total_qtyHB))/
		NULLIF((SUM(lm.buys_total_amtHB)*SUM(em.buys_total_qtyHB)), 0) - 1		[buys_avg_PctDiffAmtHB],

	(SUM(em.buys_total_amtPB)*SUM(lm.buys_total_qtyPB))/
		NULLIF((SUM(lm.buys_total_amtPB)*SUM(em.buys_total_qtyPB)), 0) - 1		[buys_avg_PctDiffAmtPB],

	(SUM(em.buys_total_amtDVD)*SUM(lm.buys_total_qtyDVD))/
		NULLIF((SUM(lm.buys_total_amtDVD)*SUM(em.buys_total_qtyDVD)), 0) - 1	[buys_avg_PctDiffAmtDVD],

	(SUM(em.buys_total_amtCD)*SUM(lm.buys_total_qtyCD))/
		NULLIF((SUM(lm.buys_total_amtCD)*SUM(em.buys_total_qtyCD)), 0) - 1		[buys_avg_PctDiffAmtCD],	

	(SUM(em.buys_total_amtLP)*SUM(lm.buys_total_qtyLP))/
		NULLIF((SUM(lm.buys_total_amtLP)*SUM(em.buys_total_qtyLP)), 0) - 1		[buys_avg_PctDiffAmtLP],

	--Employee Scan Metrics
	SUM(em.scans_count_SingleScans) [scans_count_EmpSingleScans],
	SUM(em.scans_count_FullScans)	[scans_count_EmpFullScans],

	--Location Scan Metrics
	SUM(lm.scans_count_SingleScans) [scans_count_LocSingleScans],
	SUM(lm.scans_count_FullScans)	[scans_count_LocFullScans],
	
	--Pct Comp Scan Metrics
	CAST(SUM(em.scans_count_SingleScans) AS FLOAT)/
		NULLIF(CAST(SUM(lm.scans_count_SingleScans) AS FLOAT), 0)	[scans_count_PctOfSingleScans],
	CAST(SUM(em.scans_count_FullScans) AS FLOAT)/
		NULLIF(CAST(SUM(lm.scans_count_FullScans) AS FLOAT), 0)		[scans_count_PctOfFullScans],

	--Employee Pricing Metrics
	SUM(em.SIPS_count_qtyAll)											[SIPS_count_EmpQtyAll],
	SUM(em.SIPS_total_amtAll)/NULLIF(SUM(em.SIPS_count_qtyAll), 0)		[SIPS_avg_EmpAmtAll],
	SUM(em.SIPS_count_qtyUN)											[SIPS_count_EmpQtyUN],
	SUM(em.SIPS_total_amtUN)/NULLIF(SUM(em.SIPS_count_qtyUN), 0)		[SIPS_avg_EmpAmtUN],
	SUM(em.SIPS_count_qtyPB)											[SIPS_count_EmpQtyPB],
	SUM(em.SIPS_total_amtPB)/NULLIF(SUM(em.SIPS_count_qtyPB), 0)		[SIPS_avg_EmpAmtPB],
	SUM(em.SIPS_count_qtyNOST)											[SIPS_count_EmpQtyNOST],
	SUM(em.SIPS_total_amtNOST)/NULLIF(SUM(em.SIPS_count_qtyNOST), 0)	[SIPS_avg_EmpAmtNOST],
	SUM(em.SIPS_count_qtyDVD)											[SIPS_count_EmpQtyDVD],
	SUM(em.SIPS_total_amtDVD)/NULLIF(SUM(em.SIPS_count_qtyDVD), 0)		[SIPS_avg_EmpAmtDVD],	
	SUM(em.SIPS_count_qtyCD)											[SIPS_count_EmpQtyCD],
	SUM(em.SIPS_total_amtCD)/NULLIF(SUM(em.SIPS_count_qtyCD), 0)		[SIPS_avg_EmpAmtCD],
	SUM(em.SIPS_count_qtyLP)											[SIPS_count_EmpQtyLP],
	SUM(em.SIPS_total_amtLP)/NULLIF(SUM(em.SIPS_count_qtyLP), 0)		[SIPS_avg_EmpAmtLP],
	SUM(em.SIPS_count_qtyBDGU)											[SIPS_count_EmpQtyBDGU],
	SUM(em.SIPS_total_amtBDGU)/NULLIF(SUM(em.SIPS_count_qtyBDGU), 0)	[SIPS_avg_EmpAmtBDGU],
	SUM(em.SIPS_count_qtyELTU)											[SIPS_count_EmpQtyELTU],
	SUM(em.SIPS_total_amtELTU)/NULLIF(SUM(em.SIPS_count_qtyELTU), 0)	[SIPS_avg_EmpAmtELTU],	
	
	--Location Pricing Metrics	
	SUM(lm.SIPS_count_qtyAll)											[SIPS_count_LocQtyAll],	
	SUM(lm.SIPS_total_amtAll)/NULLIF(SUM(lm.SIPS_count_qtyAll), 0)		[SIPS_avg_LocAmtAll],
	SUM(lm.SIPS_count_qtyUN)											[SIPS_count_LocQtyUN],
	SUM(lm.SIPS_total_amtUN)/NULLIF(SUM(lm.SIPS_count_qtyUN), 0)		[SIPS_avg_LocAmtUN],
	SUM(lm.SIPS_count_qtyPB)											[SIPS_count_LocQtyPB],
	SUM(lm.SIPS_total_amtPB)/NULLIF(SUM(lm.SIPS_count_qtyPB), 0)		[SIPS_avg_LocAmtPB],
	SUM(lm.SIPS_count_qtyNOST)											[SIPS_count_LocQtyNOST],
	SUM(lm.SIPS_total_amtNOST)/NULLIF(SUM(lm.SIPS_count_qtyNOST), 0)	[SIPS_avg_LocAmtNOST],
	SUM(lm.SIPS_count_qtyDVD)											[SIPS_count_LocQtyDVD],
	SUM(lm.SIPS_total_amtDVD)/NULLIF(SUM(lm.SIPS_count_qtyDVD), 0)		[SIPS_avg_LocAmtDVD],
	SUM(lm.SIPS_count_qtyCD)											[SIPS_count_LocQtyCD],
	SUM(lm.SIPS_total_amtCD)/NULLIF(SUM(lm.SIPS_count_qtyCD), 0)		[SIPS_avg_LocAmtCD],
	SUM(lm.SIPS_count_qtyLP)											[SIPS_count_LocQtyLP],
	SUM(lm.SIPS_total_amtLP)/NULLIF(SUM(lm.SIPS_count_qtyLP), 0)		[SIPS_avg_LocAmtLP],
	SUM(lm.SIPS_count_qtyBDGU)											[SIPS_count_LocQtyBDGU],
	SUM(lm.SIPS_total_amtBDGU)/NULLIF(SUM(lm.SIPS_count_qtyBDGU), 0)	[SIPS_avg_LocAmtBDGU],
	SUM(lm.SIPS_count_qtyELTU)											[SIPS_count_LocQtyELTU],
	SUM(lm.SIPS_total_amtELTU)/NULLIF(SUM(lm.SIPS_count_qtyELTU), 0)	[SIPS_avg_LocAmtELTU],
	
	--Pct Comp Pricing Amt Metrics
	(SUM(em.SIPS_total_amtAll)*SUM(lm.SIPS_count_qtyAll))/
		NULLIF((SUM(lm.SIPS_total_amtALL)*SUM(em.SIPS_count_qtyAll)), 0) - 1	[SIPS_avg_PctDiffAmtALL],

	(SUM(em.SIPS_total_amtUN)*SUM(lm.SIPS_count_qtyUN))/
		NULLIF((SUM(lm.SIPS_total_amtUN)*SUM(em.SIPS_count_qtyUN)), 0) - 1		[SIPS_avg_PctDiffAmtUN],

	(SUM(em.SIPS_total_amtPB)*SUM(lm.SIPS_count_qtyPB))/
		NULLIF((SUM(lm.SIPS_total_amtPB)*SUM(em.SIPS_count_qtyPB)), 0) - 1		[SIPS_avg_PctDiffAmtPB],

	(SUM(em.SIPS_total_amtNOST)*SUM(lm.SIPS_count_qtyNOST))/
		NULLIF((SUM(lm.SIPS_total_amtNOST)*SUM(em.SIPS_count_qtyNOST)), 0) - 1	[SIPS_avg_PctDiffAmtNOST],

	(SUM(em.SIPS_total_amtDVD)*SUM(lm.SIPS_count_qtyDVD))/
		NULLIF((SUM(lm.SIPS_total_amtDVD)*SUM(em.SIPS_count_qtyDVD)), 0) - 1	[SIPS_avg_PctDiffAmtDVD],

	(SUM(em.SIPS_total_amtCD)*SUM(lm.SIPS_count_qtyCD))/
		NULLIF((SUM(lm.SIPS_total_amtCD)*SUM(em.SIPS_count_qtyCD)), 0) - 1		[SIPS_avg_PctDiffAmtCD],

	(SUM(em.SIPS_total_amtLP)*SUM(lm.SIPS_count_qtyLP))/
		NULLIF((SUM(lm.SIPS_total_amtLP)*SUM(em.SIPS_count_qtyLP)), 0) - 1		[SIPS_avg_PctDiffAmtLP],

	(SUM(em.SIPS_total_amtBDGU)*SUM(lm.SIPS_count_qtyBDGU))/
		NULLIF((SUM(lm.SIPS_total_amtBDGU)*SUM(em.SIPS_count_qtyBDGU)), 0) - 1	[SIPS_avg_PctDiffAmtBDGU],

	(SUM(em.SIPS_total_amtELTU)*SUM(lm.SIPS_count_qtyELTU))/
		NULLIF((SUM(lm.SIPS_total_amtELTU)*SUM(em.SIPS_count_qtyELTU)), 0) - 1	[SIPS_avg_PctDiffAmtELTU],

	--Pct Comp Pricing Qty  Metrics
	CAST(SUM(em.SIPS_count_qtyAll) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyAll) AS FLOAT), 0) 	[SIPS_count_PctOfQtyALL],

	CAST(SUM(em.SIPS_count_qtyUN) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyUN) AS FLOAT), 0)		[SIPS_count_PctOfQtyUN],

	CAST(SUM(em.SIPS_count_qtyPB) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyPB) AS FLOAT), 0)		[SIPS_count_PctOfQtyPB],

	CAST(SUM(em.SIPS_count_qtyNOST) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyNOST) AS FLOAT), 0)	[SIPS_count_PctOfQtyNOST],

	CAST(SUM(em.SIPS_count_qtyDVD) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyDVD) AS FLOAT), 0)		[SIPS_count_PctOfQtyDVD],

	CAST(SUM(em.SIPS_count_qtyCD) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyCD) AS FLOAT), 0)		[SIPS_count_PctOfQtyCD],

	CAST(SUM(em.SIPS_count_qtyLP) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyLP) AS FLOAT), 0)		[SIPS_count_PctOfQtyLP],

	CAST(SUM(em.SIPS_count_qtyBDGU) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyBDGU) AS FLOAT), 0)	[SIPS_count_PctOfQtyBDGU],

	CAST(SUM(em.SIPS_count_qtyELTU) AS FLOAT)/
		NULLIF(CAST(SUM(lm.SIPS_count_qtyELTU) AS FLOAT), 0)	[SIPS_count_PctOfQtyELTU],
	
	--Employee Orders Metrics
	SUM(em.orders_count_SAS)										[orders_count_EmpSAS],
	AVG(CAST(em.orders_count_SAS AS FLOAT))							[orders_avg_EmpMoQtySAS], 
	SUM(em.orders_amt_SAS)											[orders_total_EmpAmtSAS],
	SUM(em.orders_count_XFR)										[orders_count_EmpXFR],
	AVG(CAST(em.orders_count_XFR AS FLOAT))							[orders_avg_EmpMoQtyXFR],
	SUM(em.orders_amt_XFR)											[orders_total_EmpAmtXFR],
	
	SUM(em.orders_count_SAS + em.orders_count_XFR)					[orders_count_EmpCombined],
	AVG(CAST((em.orders_count_SAS + em.orders_count_XFR) AS FLOAT)) [orders_avg_EmpMoQtyCombined],
	SUM(em.orders_amt_SAS + em.orders_amt_XFR)						[orders_total_EmpAmtCombined],

	--Location Order Metrics
	SUM(lm.orders_count_SAS)										[orders_count_LocSAS],
	AVG(CAST(lm.orders_count_SAS AS FLOAT))							[orders_avg_LocMoQtySAS], 
	SUM(lm.orders_amt_SAS)											[orders_total_LocAmtSAS],
	SUM(lm.orders_count_XFR)										[orders_count_LocXFR],
	AVG(CAST(lm.orders_count_XFR AS FLOAT))							[orders_avg_LocMoQtyXFR],
	SUM(lm.orders_amt_XFR)											[orders_total_LocAmtXFR],
	SUM(lm.orders_count_SAS + lm.orders_count_XFR)					[orders_count_LocCombined],
	AVG(CAST((lm.orders_count_SAS + lm.orders_count_XFR) AS FLOAT)) [orders_avg_LocMoQtyCombined],
	SUM(lm.orders_amt_SAS + lm.orders_amt_XFR)						[orders_total_LocAmtCombined],
	
	--Pct Comp Order Metrics
	CAST(SUM(em.orders_count_SAS) AS FLOAT)/
		NULLIF(CAST(SUM(lm.orders_count_SAS) AS FLOAT), 0)								[orders_count_PctOfSAS],
	CAST(AVG(em.orders_count_SAS) AS  FLOAT)/
		NULLIF(CAST(AVG(lm.orders_count_SAS) AS FLOAT), 0)								[orders_avg_PctOfMoQtySAS], 
	CAST(SUM(em.orders_amt_SAS) AS FLOAT)/
		NULLIF(CAST(SUM(lm.orders_amt_SAS) AS FLOAT), 0)								[orders_total_PctOfAmtSAS],
	CAST(SUM(em.orders_count_XFR) AS FLOAT)/
		NULLIF(CAST(SUM(lm.orders_count_XFR) AS FLOAT), 0)								[orders_count_PctOfXFR],
	CAST(AVG(em.orders_count_XFR) AS FLOAT)/
		NULLIF(CAST(AVG(lm.orders_count_XFR) AS FLOAT), 0)								[orders_avg_PctOfMoQtyXFR], 
	CAST(SUM(em.orders_amt_XFR) AS FLOAT)/
		NULLIF(CAST(SUM(lm.orders_amt_XFR) AS FLOAT), 0)								[orders_total_PctOfAmtXFR],

	CAST(SUM(em.orders_count_SAS + em.orders_count_XFR) AS FLOAT)/
		NULLIF(CAST(SUM(lm.orders_count_SAS + lm.orders_count_XFR) AS FLOAT), 0)		[orders_count_PctOfCombined],
	CAST(AVG(em.orders_count_SAS + em.orders_count_XFR) AS FLOAT)/
		NULLIF(CAST(AVG(lm.orders_count_SAS + lm.orders_count_XFR) AS FLOAT), 0)		[orders_avg_PctOfMoQtyCombined], 
	CAST(SUM(em.orders_amt_SAS + em.orders_amt_XFR) AS FLOAT)/
		NULLIF(CAST(SUM(lm.orders_amt_SAS + lm.orders_amt_XFR) AS FLOAT), 0)			[orders_total_PctOfAmtCombined]
FROM Sandbox..RU_EmployeeMetrics em
	INNER JOIN #LocationMetrics lm
		ON em.BusinessMonth = lm.BusinessMonth
		AND em.LocationNo = lm.LocationNo
WHERE 
		em.LocationNo = @LocationNo
	AND em.Employee_Login = @Employee_Login
	AND em.BusinessMonth >= @StartDate
	AND em.BusinessMonth <= @EndDate
GROUP BY 
	em.LocationNo,
	em.Employee_Login

DROP TABLE #LocationMetrics
END
