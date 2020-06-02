USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[VX_GetVendorWhseSettings]    Script Date: 10/1/2019 1:28:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Joey B.>
-- Create date: <11/2/12>
-- Description:	<Get warehouse setting for vendor....>
-- =============================================
CREATE PROCEDURE [dbo].[VX_GetVendorWhseSettings]
	@vendorID varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-----testing......
	--declare @vendorID varchar(10)
	--set @vendorID = 'IDB&TDISTR'
	--------------------------------
	
	----get vendor warehouse settings.....
	select r.StoreNo,l.Name,isnull(rc.PONumber,'')[PONumber],isnull(s.StatusDesc,'')[Status],
		isnull(case when r.Warehouse1='NA'then''else r.Warehouse1 end,'')[Warehouse1],
		isnull(case when r.Warehouse2='NA'then''else r.Warehouse2 end,'')[Warehouse2],
		isnull(case when r.Warehouse3='NA'then''else r.Warehouse3 end,'')[Warehouse3],
		isnull(case when r.Warehouse4='NA'then''else r.Warehouse4 end,'')[Warehouse4],
		cast(case when(isnull(l2.Active,'N'))='N' then'False'else'True'end as bit)[VX Active],
		cast(case when(isnull(bt.active,0))=0 then'False'else'True'end as bit) [BT Active]
	from VX_Whse_Ref r 
		inner join [HPB_Prime].[dbo].[Locations] L on r.storeno = l.locationno
		inner join dbo.VX_Locations l2 on l2.LocationNo = l.LocationNo
		inner join dbo.VX_Reorder_Control rc on r.StoreNo = rc.StoreNo and r.VendorID = rc.VendorID
		left join dbo.VX_Status s on rc.Status = s.StatusCode
		left join BakerTaylor..codes_SAN bt on bt.LocationNo = rc.StoreNo and bt.Warehouse = rc.Warehouse
	where rc.VendorID = @vendorID
	order by r.StoreNo
	
END

GO

