DECLARE @StartDate DATE = '1/1/2017'
DECLARE @EndDate DATE = '1/31/2019'


--Roll all register transaction info into temp table (key = AD_Login)
SELECT 
	slm.LocationNo,
	'All' [Employee_Login],
	DATEADD(MONTH, DATEDIFF(MONTH, 0, shh.BusinessDate), 0) [BusinessMonth],
	COUNT(shh.SalesXactionID) [count_SalesTransations]
INTO #RU_RegisterHeader
FROM rHPB_Historical..SalesHeaderHistory_Recent shh
	INNER JOIN ReportsView..StoreLocationMaster slm
		ON shh.LocationID = slm.LocationId
		AND slm.StoreStatus = 'O'
GROUP BY 
	slm.LocationNo,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, shh.BusinessDate), 0)

SELECT
	slm.LocationNo,
	'All' [Employee_Login],
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sih.BusinessDate), 0) [BusinessMonth],
	rurh.count_SalesTransations,
	COUNT(DISTINCT
			CASE
			WHEN sih.IsReturn = 'Y'
			THEN sih.SalesXactionID
			END) [count_SalesReturns]
INTO #RU_Register
FROM rHPB_Historical..SalesItemHistory_Recent sih
	INNER JOIN ReportsView..StoreLocationMaster slm
		ON sih.LocationID = slm.LocationId
		AND slm.StoreStatus = 'O'
	INNER JOIN #RU_RegisterHeader rurh
		ON slm.LocationNo = rurh.LocationNo
		AND DATEADD(MONTH, DATEDIFF(MONTH, 0, sih.BusinessDate), 0) = rurh.BusinessMonth
GROUP BY 
	slm.LocationNo,
	rurh.count_SalesTransations,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, sih.BusinessDate), 0)
ORDER BY LocationNo, BusinessMonth

DROP TABLE #RU_RegisterHeader