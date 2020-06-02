USE [HPB_Logistics]
GO

/****** Object:  StoredProcedure [dbo].[STOC_ApprvCreateSupPO]    Script Date: 9/25/2019 11:24:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B.>
-- Create date: <9/5/2014>
-- Description:	<Create/Approve Supply Orders...>
-- =============================================
CREATE PROCEDURE [dbo].[STOC_ApprvCreateSupPO] 
	@user varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

----testing.........
	--declare @user varchar(20)
	--set @user = 'jblalock'
----endtesting........


----get reqs for approval....
	create table #reqTmp (rowid int identity(1,1), reqNo char(6), POno char(6))
	insert into #reqTmp
	select distinct RequisitionNo,null
	from STOC_Reorder_Control src
	where LockedBy = @user and Locked = 'Y' and RequisitionNo is not null and Status = 20 and VendorID='WHPBSUPPLY'
		and exists(select itemcode from STOC_Requisition_Dtl where RequisitionNo = src.RequisitionNo and RequestedQty > 0 and Status<>99)

declare @POloop int
set @POloop = (select MAX(rowID) from #reqTmp)

while @POloop > 0
	begin 	
		declare @sRetPO char(6)
		declare @newPONo char(6)
		exec OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.VX_GetNextPONo @sRetPO = @newPONo output
		
		update #reqTmp
			set POno=@newPONo
		where rowid=@POloop
		
		set @POloop = @POloop - 1
	end

declare @rVal int
set @rVal = 0
Begin Transaction STOC_SUPCreate

----loop thru and update each req independently to ensure gaps in datetime stamps......
declare @loop int
set @loop = (select MAX(rowID) from #reqTmp)

while @loop > 0
	begin 	
		declare @curDT datetime
		set @curDT = GETDATE()
		declare @curReq char(6)
		declare @curPO char(6)
		select @curReq = reqNo, @curPO = POno from #reqTmp where rowid = @loop
		
	----update STOC_Reorder_Control status to approved for user's locked reqs....
		update STOC_Reorder_Control
			set [Status] = 35
		where RequisitionNo = @curReq

	----update requisition hdr & dtl statues from STOC_Reorder_Control....
		update stoc_requisition_hdr
			set  [Status] = 35
				,approvedby = @user
				,approveddate = @curDT
				,PONumber=@curPO
		where requisitionno = @curReq

		update stoc_requisition_dtl
			set	 [Status] = case when Status=99 then 99 else 35 end
				,approvedby = @user
				,approveddate = @curDT
				,PONumber=@curPO
		where requisitionno = @curReq
		
	----insert requisition into audit log for move to DIPS....
		insert into stoc_requisition_audit_log
			select @curReq, @curDT, null, 0, null
		
		if isnull((select PoNumber from STOC_Consolidation_Audit_Log where PoNumber=@curPO),'')=''
					begin
					----insert requisition into audit log for move to DIPS....
						insert into STOC_Consolidation_Audit_Log
							select @curPO,'WHPBSUPPLY','C','supplies',getdate(),@user,null,0,null
					end				
		set @loop = @loop - 1
	end

drop table #reqTmp
----Commit or Rollback trans...........
if @rVal <> 1 begin set @rVal = @@ERROR end
if @rVal=0
	begin
		Commit Transaction STOC_SUPCreate
		return @rVal
	end
else
	begin
		ROLLBACK  Transaction STOC_SUPCreate
		return @rVal
	end
	
END

GO

