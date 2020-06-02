USE [Reports]
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Miller, William
-- Create date: 2/15/19
-- Description:	Get Login Name, Userno, UserID, and full name (LastName, PreferredName) for all employees at a specific location.
-- =============================================
CREATE PROCEDURE [dbo].[PARAMS_GetCurrUserKeysByLocation] 
	-- Add the parameters for the stored procedure here
	@LocationNo CHAR(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		u.UserNo,
		u.UserID, 
		m.AD_Login,
		m.HR_NameLast + ', ' + m.HR_NamePreferred [EmployeeName]
	FROM ReportsData..ASUsers u
		INNER JOIN ReportsData..ADAccountMappings m
			ON u.UserID = m.POS_UserID
		INNER JOIN
				(SELECT
					m.HR_EmployeeID,
					MAX(u.AddDate) [LastAddDate]
				FROM ReportsData..ASUsers u
				INNER JOIN ReportsData..ADAccountMappings m
					ON u.UserID = m.POS_UserID
				GROUP BY HR_EmployeeID) curr
			ON m.HR_EmployeeID = curr.HR_EmployeeID
			AND u.AddDate = curr.LastAddDate
	AND u.Status = 'A'
	AND m.HR_Location = RIGHT(@LocationNo, 3)
	ORDER BY HR_NameLast
END
GO
