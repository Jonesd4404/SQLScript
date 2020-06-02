USE [HPB_Logistics]
GO
/****** Object:  StoredProcedure [dbo].[STOC_ApprvCreateSupPO]    Script Date: 9/25/2019 10:02:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Joey B.>
-- Create date: <9/5/2014>
-- Description:	<Create/Approve Supply Orders...>
-- =============================================
ALTER PROCEDURE [dbo].[STOC_ApprvCreateSupPO] 
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
	CREATE TABLE #reqTmp (rowid INT IDENTITY(1,1), reqNo CHAR(6), POno CHAR(6))
	
	INSERT INTO #reqTmp
		SELECT DISTINCT RequisitionNo,null
		FROM STOC_Reorder_Control src
		WHERE LockedBy = @user 
			AND Locked = 'Y' 
			AND RequisitionNo IS NOT NULL 
			AND [Status] = 20 
			AND VendorID='WHPBSUPPLY'
			AND EXISTS(SELECT ItemCode FROM STOC_Requisition_Dtl WHERE RequisitionNo = src.RequisitionNo AND RequestedQty > 0 AND [Status]<>99)

	DECLARE @POloop INT

	-- added if exits 
	IF EXISTS(SELECT 1 FROM #reqTmp)
		BEGIN
			SELECT @POloop = MAX(rowID) FROM #reqTmp

			WHILE @POloop > 0
				BEGIN 	
					DECLARE @sRetPO CHAR(6)
					DECLARE @newPONo CHAR(6)
					EXEC OPENDATASOURCE('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.VX_GetNextPONo @sRetPO = @newPONo output
			
					UPDATE #reqTmp
						SET POno=@newPONo
					WHERE rowid=@POloop
			
					SET @POloop = @POloop - 1
				END

			DECLARE @rVal INT = 0
			BEGIN TRANSACTION STOC_SUPCreate

			----loop thru and update each req independently to ensure gaps in datetime stamps......
			DECLARE @loop INT
			SELECT @loop = MAX(rowID) FROM #reqTmp

			WHILE @loop > 0
				BEGIN 	
					DECLARE @curDT DATETIME = GETDATE()
					DECLARE @curReq CHAR(6)
					DECLARE @curPO  CHAR(6)
				
					SELECT	 @curReq = reqNo
							,@curPO = POno 
					FROM #reqTmp 
					WHERE rowid = @loop
		
					----update STOC_Reorder_Control status to approved for user's locked reqs....
					UPDATE STOC_Reorder_Control
						SET [Status] = 35
					WHERE RequisitionNo = @curReq

					----update requisition hdr & dtl statues from STOC_Reorder_Control....
					UPDATE stoc_requisition_hdr
						SET  [Status] = 35
							,approvedby = @user
							,approveddate = @curDT
							,PONumber=@curPO
					WHERE requisitionno = @curReq

					UPDATE stoc_requisition_dtl
						SET	 [Status] = CASE WHEN [Status]=99 THEN 99 ELSE 35 END
							,ApprovedBy = @user
							,ApprovedDate = @curDT
							,PONumber=@curPO
					WHERE RequisitionNo = @curReq
		
					----insert requisition into audit log for move to DIPS....
					INSERT INTO stoc_requisition_audit_log
						SELECT @curReq, @curDT, NULL, 0, NULL
		
					IF ISNULL((SELECT PoNumber FROM STOC_Consolidation_Audit_Log WHERE PoNumber=@curPO),'')=''
						BEGIN
							-- insert requisition into audit log for move to DIPS....
							INSERT INTO STOC_Consolidation_Audit_Log
								SELECT @curPO,'WHPBSUPPLY','C','supplies',GETDATE(),@user,NULL,0,NULL
						end				
				
					SET @loop = @loop - 1
				END

			DROP TABLE #reqTmp
			----Commit or Rollback trans...........
			IF @rVal <> 1 BEGIN SET @rVal = @@ERROR END
			IF @rVal=0
				BEGIN
					COMMIT TRANSACTION STOC_SUPCreate
					RETURN @rVal
				END
			ELSE
				BEGIN
					ROLLBACK  TRANSACTION STOC_SUPCreate
					RETURN @rVal
				END	
		END		
END