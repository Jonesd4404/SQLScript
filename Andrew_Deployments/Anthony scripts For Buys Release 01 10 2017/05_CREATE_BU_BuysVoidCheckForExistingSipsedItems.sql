USE SIPS
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
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE BU_BuysVoidCheckForExistingSipsedItems
@LocationNo char(5),
@BuyBinNo char(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT locationNo, BuyBinNo, ItemDescription, SipsID, LabelPrinted
FROM Buys.dbo.BuyBinItems
WHERE buybinno = @BuyBinNo
AND LocationNo = @LocationNo
AND LabelPrinted is not null

END
GO
