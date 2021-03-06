USE [Reports]
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RU_EmployeeMetrics_test]') AND name = N'IX_EmployeeMetrics')
DROP INDEX [IX_EmployeeMetrics] ON [dbo].[RU_EmployeeMetrics_test] WITH ( ONLINE = OFF )
GO


USE [Reports]
GO

CREATE NONCLUSTERED INDEX [IX_EmployeeMetrics] ON [dbo].[RU_EmployeeMetrics_test] 
(
	[LocationNo] ASC,
	[Employee_Login] ASC,
	[BusinessMonth] ASC)
INCLUDE ([reg_count_SalesTrans]
      ,[reg_count_SalesReturns]
      ,[reg_count_SalesVoids]
      ,[buys_count_BuyTrans]
      ,[buys_count_TotalQty]
      ,[buys_total_TotalOffer]
      ,[buys_total_BuyScans]
      ,[buys_total_BuyWait]
      ,[buys_total_qtyHB]
      ,[buys_total_amtHB]
      ,[buys_total_qtyPB]
      ,[buys_total_amtPB]
      ,[buys_total_qtyDVD]
      ,[buys_total_amtDVD]
      ,[buys_total_qtyCD]
      ,[buys_total_amtCD]
      ,[buys_total_qtyLP]
      ,[buys_total_amtLP]
      ,[scans_count_SingleScans]
      ,[scans_count_FullScans]
      ,[SIPS_count_qtyAll]
      ,[SIPS_total_amtAll]
      ,[SIPS_count_qtyUN]
      ,[SIPS_total_amtUN]
      ,[SIPS_count_qtyPB]
      ,[SIPS_total_amtPB]
      ,[SIPS_count_qtyNOST]
      ,[SIPS_total_amtNOST]
      ,[SIPS_count_qtyDVD]
      ,[SIPS_total_amtDVD]
      ,[SIPS_count_qtyCD]
      ,[SIPS_total_amtCD]
      ,[SIPS_count_qtyLP]
      ,[SIPS_total_amtLP]
      ,[SIPS_count_qtyBDGU]
      ,[SIPS_total_amtBDGU]
      ,[SIPS_count_qtyELTU]
      ,[SIPS_total_amtELTU]
      ,[orders_count_SAS]
      ,[orders_count_XFR]
      ,[orders_amt_SAS]
      ,[orders_amt_XFR])	
 WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
