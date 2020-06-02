USE [Reports]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Miller, William
-- Create date: 2/22/2019
-- Description:	Given a location number, retrieves the full name (Lastname, PreferredName),
--	log-in ID, POS User ID, and POS User Number to allow info retrieval from all tables.
-- =============================================
CREATE PROCEDURE [dbo].[PARAMS_GetCurrEmployeeKeysByLoc]
	-- Add the parameters for the stored procedure here
	@LocationNo CHAR(5)
AS
BEGIN

	SET NOCOUNT ON;
	--HR related tables use a 3 char location code instead of 5 char
	--Convert to 3 char before query
	DECLARE @HR_LocationNo CHAR(3) =  RIGHT(@LocationNo, 3)
	
	--Inner join on the most recent record associated with a given employee ID
	--Each employee has a record under their HR_Employee ID for each location they've worked at.
	--ASUsers.AddDate can point us to which one is most current.
	SELECT
		m.HR_EmployeeID,
		MAX(u.AddDate) [LastAddDate]
	INTO #CurrentUsers
	FROM ReportsData..ASUsers u
		INNER JOIN ReportsData..ADAccountMappings m
			ON u.UserID = m.POS_UserID
	GROUP BY HR_EmployeeID

	SELECT
		m.HR_NameLast + ', ' + m.HR_NamePreferred [EmployeeName],
		m.AD_Login [Employee_Login],
		m.POS_UserID [Employee_POSUserID],
		m.POS_UserNo [Employee_POSUserNo]
	FROM ReportsData..ASUsers u
		INNER JOIN ReportsData..ADAccountMappings m
			ON u.UserID = m.POS_UserID
			AND u.[Status] = 'A'
		INNER JOIN #CurrentUsers curr
			ON m.HR_EmployeeID = curr.HR_EmployeeID
			AND u.AddDate = curr.LastAddDate

	--HR_Location is a 3 digit code, whereas most systems store it as CHAR(5)
	AND m.HR_Location = @HR_LocationNo
	ORDER BY HR_NameLast

	DROP TABLE #CurrentUsers

END
GO
