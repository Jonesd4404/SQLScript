USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[ACT_StoreTransferSummary]    Script Date: 10/2/2019 2:14:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[ACT_StoreTransferSummary]

@Month INT = '6'
,@Year INT = '2011'

AS

/****************************************
CREATED FOR: Store Transfers
CREATED BY: DGREEN
CREATE DATE: 10/18/07
NOTES: Displays all the transfers from store to store for 
month selected
10/19/07 - Converting Money to 2 decimal places means
converting it to a varchar first then converting it back
to money.  This give the two decimal places.
*****************************************/

/*
DECLARE @Month INT, @Year INT
SELECT @Month = 7, @Year = 2006
*/

SELECT Convert(Money, Cast(SUM(TransferQty * CostEach) As Varchar(50))) AS Credit,
	CAST(0 AS MONEY) AS Debit,
	RIGHT(ToLocationNo,3) AS ToLocationNo, 
	RIGHT(FromLocationNo,3) AS FromLocationNo,
	PTypeClass, --TOP 100 * 
	@Month AS Month, @Year AS Year

INTO #TEMP

FROM ReportsData..InventoryTransfers i
	JOIN ReportsData..ProductMaster pm ON pm.ItemCode = i.ItemCode
	JOIN ReportsData..ProductTypes pt ON pt.ProductType = pm.ProductType
	JOIN ReportsData..Locations l ON l.LocationNo = i.ToLocationNo

WHERE DATEPART(MM, DateTransferred) = @Month
	AND DATEPART(YYYY, DateTransferred) = @Year
	AND ToLocationNo NOT IN ('00210','00710' ,'00452') 	/*	Skip donations and BS per Mary Cline		*/
	AND l.LocationType NOT IN ('T','R','C','O')		/*	Skip Trash, CDC and RDCs per Mary Cline		*/

GROUP BY FromLocationNo, ToLocationNo, PTypeClass

ORDER BY FromLocationNo, ToLocationNo, PTypeClass


INSERT #Temp
SELECT Cast(0 As Money) AS Credit,
	Convert(Money, Cast(Credit As Varchar(50))) AS Debit,
	ToLocationNo,
	FromLocationNo,
	PTypeClass, 
	Month,
	Year 
FROM #TEMP

SELECT * FROM #TEMP
ORDER BY ToLocationNo, FromLocationNo, PTypeClass

DROP TABLE #TEMP


GO

