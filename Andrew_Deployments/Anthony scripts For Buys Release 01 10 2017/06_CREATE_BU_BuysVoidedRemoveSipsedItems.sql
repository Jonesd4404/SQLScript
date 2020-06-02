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
CREATE PROCEDURE BU_BuysVoidedRemoveSipsedItems
@LocationNo char(5),
@BuyXactionID char(10),
@ItemCodes varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--step 1 insert into the audit table
declare @insertSql varchar(max)
set @insertSql = 'INSERT into SipsProductInventoryAudit 
SELECT *, getdate() FROM SipsProductInventory with (nolock) WHERE BuyXactionID = ''' + @BuyXactionID + ''' AND LocationNo = ''' + @LocationNo + ''' AND ItemCode IN (' + @ItemCodes + ')'
--step 2 delete from inventory
declare @deleteSql varchar(max)
set @deleteSql = 'DELETE FROM SipsProductInventory WHERE BuyXactionID = ''' + @BuyXactionID + ''' AND LocationNo = ''' + @LocationNo + ''' AND ItemCode IN (' + @ItemCodes + ')'
--step 3 update BuyBinItems so they no longer see the item codes on the BuyItems form 
declare @updateBuyItems varchar(max)
set @updateBuyItems = 'update BUYS.dbo.BuyBinItems ' +
'set LabelPrinted = null ' +
'where LocationNo = ' + @LocationNo + 
' and BuyBinNo = ' + @BuyXactionID + 
' and LabelPrinted in (' + @ItemCodes + ')'

BEGIN TRY
	BEGIN TRAN 
		exec (@insertSql)
		exec (@deleteSql)
		exec (@updateBuyItems)
	COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK
END CATCH

END
GO

