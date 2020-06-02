USE [Reports]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		William Miller
-- Create date: 03/04/2019
-- Description:	Creates starting and ending date ranges for selection as report parameters
-- =============================================
CREATE PROCEDURE [dbo].[PARAMS_CreateDateRangeSelect]
	-- Add the parameters for the stored procedure here
AS
BEGIN
--Set the last date to prior month
DECLARE @DateRangeMax DATE = DATEADD(MONTH, -1, GETDATE())
--Change the statement below to determine the number of years back to all selection
DECLARE @DateRangeMin DATE = '1/1/2017'; --DATEADD(YEAR, -2, @DateRangeMax);

WITH CTE AS
(
    --DATEADD(MONTH, DATEDIFF... rounds each month down to the first day
    SELECT 
		DATEADD(MONTH, DATEDIFF(MONTH, 0, @DateRangeMin), 0) [StartDateSelect]
    UNION ALL
    SELECT 
	DATEADD(MONTH, 1, StartDateSelect)
    FROM CTE
    WHERE DATEADD(MONTH, 1, StartDateSelect) <= @DateRangeMax
)
SELECT 
	CONVERT(VARCHAR(10), StartDateSelect, 101) [format_StartDateSelect],
	CONVERT(VARCHAR(10), DATEADD(MONTH, DATEDIFF(MONTH, -1, StartDateSelect),  -1), 101) [format_EndDateSelect]
FROM CTE
ORDER BY StartDateSelect DESC
END
GO
