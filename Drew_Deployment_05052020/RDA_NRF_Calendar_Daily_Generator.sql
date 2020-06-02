DECLARE 
	@StartDate datetime2 = '1/31/2010', --This date must be the start of an NRF year. 
	@NumYears int = 16,
	--The remaining parameters should not be modified.
	@dt datetime2 = '1905-01-01', --This is a Sunday, allowing this to be set as a reference datetime where Sunday is the start of the week, otherwise date 0 is Monday, 1/1/1900
	@StartWeekDate datetime2,
	@EndDate datetime2,
	@NRF_Week int,
	@NRF_MonthNum int,
	@NRF_MonthName varchar(10),
	@NRF_Year int,
	@i int = 0, --while loop iterator (not adjustable without potentially breaking or infinitizing the loop)
	@di int = 0 --date period iterator (adjustable)


SET @StartWeekDate = DATEADD(WEEK, DATEDIFF(WEEK, @dt, @StartDate), @dt)
SET @EndDate = DATEADD(WEEK, 52.16*@NumYears, @StartWeekDate) --52.16 is an approximation that should include all extra weeks caused by the occasional 53rd, even for larger time spans. Might need some tinkering.
SET @NRF_Week = 1
SET @NRF_MonthNum = 1
SET @NRF_MonthName = DATEPART(MONTH, DATEADD(DAY, @di + 7, @StartWeekDate))
SET @NRF_Year = CAST(DATEPART(YEAR, @StartWeekDate) AS INT)


CREATE TABLE #Calendar 
	(NRF_Year char(4),
	 NRF_MonthName varchar(10),
	 NRF_MonthNum int, 
	 NRF_Week int,
	 Calendar_StartOfWeek datetime2, 
	 Calendar_EndOfWeek datetime2, 
	 Store_StartOfWeek datetime2,
	 Store_EndOfWeek datetime2)


WHILE @i <= DATEDIFF(DAY, @StartDate, @EndDate)
BEGIN
	
	SET @StartWeekDate = CASE
			WHEN @NRF_Week = 53
			THEN DATEADD(DAY, @di, @StartWeekDate)
			ELSE @StartWeekDate
			END --If the last week encountered was a 53rd week, restart the day count until the next 53rd week is encountered.

	SET @di = CASE
				WHEN @NRF_Week = 53
				THEN 0
				ELSE @di
				END --@di is set to maintain a separate day count from @i. @di will reset any time a 53rd week is encountered.

	SET @NRF_Week = CASE
						WHEN DATEPART(MONTH, DATEADD(DAY, @di, @StartWeekDate)) = 1
						AND DATEPART(DAY, DATEADD(DAY, @di, @StartWeekDate)) < 29
						AND DATEPART(DAY, DATEADD(DAY, @di, @StartWeekDate)) > 26
						AND FLOOR((@di + 7) / 7) - 52 * FLOOR((@di / 7) / 52) <> 52 
						THEN 53 --If there are 4 or more days remaining in January, and it's not the 52nd week, it's a 53rd week.
						ELSE FLOOR((@di + 7) / 7) - 52 * FLOOR((@di / 7) / 52) --Calculates the number of weeks in a 52 week period
						END 
	
	SET @NRF_MonthNum = CASE 
						WHEN @NRF_Week = 1 --Reset to month 1 on the first week of each year
							THEN 1
						WHEN @NRF_Week = 53
							THEN 12 --Manually set this to 12 for the 53rd week, else it will start a 13th month.
						WHEN @NRF_Week % 13 = 1 
						    THEN @NRF_MonthNum + 1 --Add a month if a 13 week period has elapsed (4+5+4)
						WHEN @NRF_Week % 13 = 5 
							THEN @NRF_MonthNum + 1 --Add a month if 4 weeks have elapsed in a 13 week period
						WHEN @NRF_Week % 13 = 10
							THEN @NRF_MonthNum + 1 --Add a month if 9 weeks have elapsed in a 13 week period
						ELSE @NRF_MonthNum --Must be included to avoid population with NULLs where none of the above are true.
						END

	SET @NRF_MonthName = CASE 
						WHEN @NRF_Week = 1 --Reset to month 1 on the first week of each year
							THEN FORMAT(DATEADD(DAY, @di + 7, @StartWeekDate), 'MMM', 'en-US')
						WHEN @NRF_Week = 53
							THEN FORMAT(DATEADD(DAY, @di, @StartWeekDate), 'MMM', 'en-US') --To keep this in the same month as week 52, we have to go off the starting day of the week here.
						WHEN @NRF_Week % 13 = 1 
						    THEN FORMAT(DATEADD(DAY, @di + 7, @StartWeekDate), 'MMM', 'en-US')
						WHEN @NRF_Week % 13 = 5 
							THEN FORMAT(DATEADD(DAY, @di + 7, @StartWeekDate), 'MMM', 'en-US')
						WHEN @NRF_Week % 13 = 10
							THEN FORMAT(DATEADD(DAY, @di + 7, @StartWeekDate), 'MMM', 'en-US')
						ELSE @NRF_MonthName
						END

	SET @NRF_Year = CASE 
						WHEN @NRF_Week = 1 
							THEN DATEPART(YEAR, DATEADD(DAY, @di, @StartWeekDate))
							ELSE @NRF_Year
							END

	INSERT INTO #Calendar
	SELECT 
		@NRF_Year,
		@NRF_MonthName,
		@NRF_MonthNum,
		@NRF_Week,
		DATEADD(DAY, @di, @StartWeekDate) [Calendar_StartOfWeek],
		DATEADD(SECOND, -1 , DATEADD(DAY, @di + 7, @StartWeekDate)) [Calendar_EndOfWeek], --Removed 1 second to distinguish end of week from start, for clarity.
		DATEADD(DAY, @di + 1, @StartWeekDate) [Store_StartOfWeek],
		DATEADD(SECOND, -1, DATEADD(DAY, @di + 8, @StartWeekDate)) [Store_EndOfWeek] --Removed 1 second to distinguish end of week from start, for clarity.


	SET @di = @di + 7 --iterate over the number of days since the last 53 week calendar year
	SET @i = @i + 7 --iterate over the total number of days in the time period.

END

SELECT 
	c.NRF_Year,
	c.NRF_MonthName,
	c.NRF_MonthNum,
	c.NRF_Week,
	CASE 
		WHEN r.NRF_Week IS NOT NULL
		THEN c.NRF_Week - 1
		ELSE c.NRF_Week
		END [NRF_Week_Restated],
	c.Calendar_StartOfWeek,
	c.Calendar_EndOfWeek,
	c.Store_StartOfWeek,
	c.Store_EndOfWeek
INTO #NRF_Final
FROM #Calendar c
	LEFT OUTER JOIN #Calendar r
		ON c.NRF_Year = r.NRF_Year
		AND r.NRF_Week = 53


/*
CREATE TABLE MathLab..NRF_Weekly
	(NRF_Year char(4),
	 NRF_MonthName varchar(10),
	 NRF_MonthNum int, 
	 NRF_Week int, 
	 NRF_Week_Restated int,
	 Calendar_StartOfWeek datetime2, 
	 Calendar_EndOfWeek datetime2, 
	 Store_StartOfWeek datetime2,
	 Store_EndOfWeek datetime2)

INSERT INTO MathLab..NRF_Weekly
SELECT
	 NRF_Year,
	 NRF_MonthName,
	 NRF_MonthNum, 
	 NRF_Week, 
	 NRF_Week_Restated,
	 Calendar_StartOfWeek, 
	 Calendar_EndOfWeek, 
	 Store_StartOfWeek,
	 Store_EndOfWeek
FROM #NRF_Final
*/

--SELECT *
--FROM #NRF_Final

DROP TABLE #Calendar


DECLARE @DailyCalStartDate DATETIME2
DECLARE @DailyCalEndDate DATETIME2
DECLARE @DailyDate DATETIME2
--DECLARE @DailyStoreStartDate DATE
--DECLARE @DailyStoreEndDate DATE

SELECT 
	@DailyCalStartDate = MIN(n.Calendar_StartOfWeek),
	@DailyCalEndDate = MAX(n.Calendar_EndOfWeek)
	--@DailyStoreStartDate = MIN(n.Store_StartOfWeek),
	--@DailyStoreEndDate = MAx(n.Store_EndOfWeek)
FROM #NRF_Final n


CREATE TABLE #DailyCalendar 
	(Calendar_Date datetime2,
	 Store_Date datetime2,
	 NRF_Year int,
	 NRF_MonthName varchar(10),
	 NRF_MonthNum int, 
	 NRF_Week int,
	 NRF_Week_Restated int)

SET @i = 0


WHILE @i <= DATEDIFF(DAY, @DailyCalStartDate, @DailyCalEndDate)
BEGIN
	
		
	SET @DailyDate = DATEADD(DAY, @i, @DailyCalStartDate)
	SET @i = @i + 1 --iterate over the total number of days in the time period.
	

	INSERT INTO #DailyCalendar
	SELECT 
		@DailyDate [Calendar_Date],
		DATEADD(DAY, 1, @DailyDate) [Store_Date],
		NRF_Year,
		NRF_MonthName,
		NRF_MonthNum,
		NRF_Week,
		NRF_Week_Restated
	FROM #NRF_Final n
	WHERE @DailyDate >= n.Calendar_StartOfWeek
	AND @DailyDate <= n.Calendar_EndOfWeek
			
END


SELECT 
	Calendar_Date,
	Store_Date,
	NRF_Year,
	NRF_MonthName,
	NRF_MonthNum,
	NRF_Week,
	NRF_Week_Restated,
	ROW_NUMBER() OVER (PARTITION BY NRF_Year ORDER BY Store_Date ASC) [NRF_Day]
INTO #DailyCalendar_Final
FROM #DailyCalendar
ORDER BY Calendar_Date ASC


CREATE TABLE ReportsData.dbo.RDA_NRF_Daily
	 (
	 Calendar_Date datetime2, 
	 Store_Date datetime2, 
	 NRF_Year int,
	 NRF_MonthName varchar(10),
	 NRF_MonthNum int, 
	 NRF_Week int, 
	 NRF_Week_Restated int,
	 NRF_Day int
	 )

INSERT INTO ReportsData.dbo.RDA_NRF_Daily
SELECT
	 Calendar_Date,
	 Store_Date,
	 NRF_Year,
	 NRF_MonthName,
	 NRF_MonthNum, 
	 NRF_Week, 
	 NRF_Week_Restated,
	 NRF_Day
FROM #DailyCalendar_Final


DROP TABLE #NRF_Final
DROP TABLE #DailyCalendar
DROP TABLE #DailyCalendar_Final


