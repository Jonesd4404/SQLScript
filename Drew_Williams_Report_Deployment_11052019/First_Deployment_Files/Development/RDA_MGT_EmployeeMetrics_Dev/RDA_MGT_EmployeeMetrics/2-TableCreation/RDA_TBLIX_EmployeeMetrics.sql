USE [Reports]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RDA_RU_EmployeeMetrics]') AND TYPE in (N'U'))
DROP TABLE [dbo].[RDA_RU_EmployeeMetrics]
GO

USE [Reports]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RDA_RU_EmployeeMetrics] (
	   [LocationNo] [char](5) NOT NULL --All location numbers typically stored as CHAR(5)
      ,[Employee_Login] [varchar](20) NOT NULL --I'm unsure of the standard maximum for employee logins, but I've never observed one over 20 characters long.
      ,[BusinessMonth] [date] NOT NULL
      --Best practice dictates use of decimal(19,4) over smallmoney where calculations will be done on the data. "Smallmoney" is highly prone to rounding errors.
	  --Decimal(19,4) will be used for all currency amounts.
	  ,[reg_count_SalesTrans] [bigint] NULL --Bigint may be necessary due to inclusion of chain data in this table. It will be used for all counts to prevent future problems.
      ,[reg_count_SalesReturns] [bigint] NULL 
      ,[reg_count_SalesVoids] [bigint] NULL
      ,[buys_count_BuyTrans] [bigint] NULL
      ,[buys_count_TotalQty] [bigint] NULL
      ,[buys_total_TotalOffer] [decimal](19,4) NULL
      ,[buys_total_BuyScans] [bigint] NULL
      ,[buys_total_BuyWait] [decimal](19,4) --Buy minutes with decimal precision. (19, 4) might be overkill.
      ,[buys_total_qtyHB] [bigint] NULL
      ,[buys_total_amtHB] [decimal](19,4)
      ,[buys_total_qtyPB] [bigint] NULL
      ,[buys_total_amtPB] [decimal](19,4)
      ,[buys_total_qtyDVD] [bigint] NULL
      ,[buys_total_amtDVD] [decimal](19,4)
      ,[buys_total_qtyCD] [bigint] NULL
      ,[buys_total_amtCD] [decimal](19,4)
      ,[buys_total_qtyLP] [bigint] NULL
      ,[buys_total_amtLP] [decimal](19,4)
      ,[scans_count_SingleScans] [bigint] NULL --Bigint is most important here. Chain data would definitely overflow INT.
      ,[scans_count_FullScans] [bigint] NULL
      ,[SIPS_count_qtyAll] [bigint] NULL
      ,[SIPS_total_amtAll] [decimal](19,4)
      ,[SIPS_count_qtyUN] [bigint] NULL
      ,[SIPS_total_amtUN] [decimal](19,4)
      ,[SIPS_count_qtyPB][bigint] NULL
      ,[SIPS_total_amtPB] [decimal](19,4)
      ,[SIPS_count_qtyNOST][bigint] NULL
      ,[SIPS_total_amtNOST] [decimal](19,4)
      ,[SIPS_count_qtyDVD] [bigint] NULL
      ,[SIPS_total_amtDVD] [decimal](19,4)
      ,[SIPS_count_qtyCD] [bigint] NULL
      ,[SIPS_total_amtCD] [decimal](19,4)
      ,[SIPS_count_qtyLP] [bigint] NULL
      ,[SIPS_total_amtLP] [decimal](19,4)
      ,[SIPS_count_qtyBDGU] [bigint] NULL
      ,[SIPS_total_amtBDGU] [decimal](19,4)
      ,[SIPS_count_qtyELTU] [bigint] NULL
      ,[SIPS_total_amtELTU] [decimal](19,4)
      ,[orders_count_SAS] [bigint] NULL
	  ,[orders_count_STS] [bigint] NULL
      ,[orders_count_XFR] [bigint] NULL
      ,[orders_amt_SAS] [decimal](19,4)
	  ,[orders_amt_STS] [decimal](19,4)
      ,[orders_amt_XFR] [decimal](19,4)
,CONSTRAINT [PK_RDA_RU_EmployeeMetrics] PRIMARY KEY CLUSTERED 
(
       [LocationNo] ASC,
       [Employee_Login] ASC,
       [BusinessMonth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 97) ON [PRIMARY]
) ON [PRIMARY]

