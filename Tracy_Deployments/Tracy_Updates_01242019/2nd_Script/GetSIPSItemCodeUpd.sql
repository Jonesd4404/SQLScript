USE [Reports]
GO

/****** Object:  UserDefinedFunction [dbo].[GetSIPSItemCode]    Script Date: 09/07/2018 14:53:47 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


Alter FUNCTION [dbo].[GetSIPSItemCode] (@ItemCode VARCHAR(20))
RETURNS INT
AS
/****************************************************************
CREATED: 1/17/2018
CREATED BY: Tracy Dennis
REPORT: Employee Purchases Detail Report (LP)
FUNCTION: GetSIPSItemCode 
=================================================================
DESCRIPTION
=================================================================
Get the item code with the item code prefix and the leading zeros for SIPS item codes.  The Distibution item codes or ones that have character returns 0 so that no match would be made 
/ couldn't join to the ReportsData..sipsProductinventory.

=================================================================
UPDATES
=================================================================
1/17/2018 - Creation Date
9/10/2018 - Tracy Dennis added 99 logic since items with item code greater than 2,147,483,647 breaks the max an int could be causing the ReportsData..sipsProductinventory join to 
            fail since item code is an int. testing -> USE [Reports] select dbo.GetSIPSItemCode('99000000002198487730') as result
*****************************************************************/
BEGIN
	DECLARE @IC INT

	IF 
	(left(@ItemCode, 1) = '0')
		OR (isnumeric(@ItemCode) <> 1) --Distribution item codes or or some items such generic Puzzle(150000000000000000pz) item code or gift card (GA) have characters in them and woulfd fail the join to ReportsData..SipsProductMaster
	    OR (left(@ItemCode, 2) = '99')-- Prefix 99 unknown items
	BEGIN
		SET @IC = 0
	END
	ELSE --SIPS item codes
		--Removes the leading zeroes only use the right 18 so that the item code prefix would be removed.
	BEGIN
		SET @IC = Substring(right(@ItemCode, 18), PATINDEX('%[^0]%', right(@ItemCode, 18)), 18)
	END

	RETURN @IC
END

GO


