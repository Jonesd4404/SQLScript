USE [HPB_Logistics]
GO
/****** Object:  StoredProcedure [dbo].[VX_SendPendingApprovalsEmail]    Script Date: 10/1/2019 3:49:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Joey B.>
-- Create date: <4/21/2014>
-- Description:	<Send Pending Approval's Email.....>
-- =============================================
ALTER PROCEDURE [dbo].[VX_SendPendingApprovalsEmail]
	@time int
AS
BEGIN
	SET NOCOUNT ON;
	
	----testing......
	--declare @time int
	--set @time = -99999
	--------.........

	IF EXISTS (	SELECT 1 
				FROM dbo.VX_Requisition_Hdr rh 
					INNER JOIN dbo.VX_Submit_Audit_Log sal 
						ON rh.PONumber=sal.PONumber 
				WHERE [Status]=40 
					AND CAST(CONVERT(VARCHAR(10),sal.ResponseDate,120)+' '+CONVERT(CHAR(5),sal.ResponseDate,108) AS DATETIME) > DATEADD(n,@time,GETDATE()))
		BEGIN
			--select rh.VendorID,rh.LocationNo,rh.PONumber,rh.ReqQty,rh.ReqAmt 
			--from VX_Requisition_Hdr rh inner join VX_Submit_Audit_Log sal on rh.PONumber=sal.PONumber
			--where Status=40 and sal.ResponseDate > DATEADD(n,-5,getdate())
			--order by rh.VendorID,rh.LocationNo,rh.PONumber
			
			
			----send the email................................
			DECLARE @emailAddy varchar(1000) = 'jblalock@hpb.com'
			DECLARE @qry VARCHAR(MAX)
			
			SET @qry = ' SET NOCOUNT ON; ' +
						'SELECT rh.VendorID,rh.LocationNo ' +
						',CAST(rh.PONumber AS VARCHAR(10)) AS PONumber ' +
						',CAST(rd.ReqQty AS VARCHAR(10)) AS Requested ' +
						',CAST(rd.Canqty as VARCHAR(10)) as Cancelled ' +
						',CAST(rd.ConQty AS VARCHAR(10)) AS Confirmed ' +
						',CAST(rh.ReqAmt AS VARCHAR(10)) AS ReqAmt ' +
						'FROM [HPB_LOGISTICS].dbo.[VX_Requisition_Hdr] rh ' +
						'INNER JOIN (SELECT PONumber, SUM(RequestedQty) AS ReqQty, SUM(ConfirmedQty) AS ConQty, SUM(CanceledQty) as CanQty ' +
									'FROM VX_Requisition_Dtl ' +
									'GROUP BY PONumber) rd ' +
						'ON rd.POnumber = rh.ponumber ' +
						'INNER JOIN [HPB_LOGISTICS].dbo.[VX_Submit_Audit_Log] sal ' +
						'ON rh.PONumber=sal.PONumber ' +
						'WHERE rh.Status=40 ' +
						'AND CAST(CONVERT(VARCHAR(10),sal.ResponseDate,120)+'' ''+CONVERT(CHAR(5),sal.ResponseDate,108)as datetime) > DATEADD(n,'+CAST(@time AS VARCHAR(6))+',GETDATE()) ' +
						'ORDER BY rh.VendorID,rh.LocationNo,rh.PONumber'

			EXECUTE [msdb].[dbo].[sp_send_dbmail]
			        @profile_name='EDIMail',
			        @recipients=@emailAddy,
			        @subject     = 'EDI Orders Pending Approval',
					@body        = 'These EDI orders are awaiting approval.',
					@query = @qry 			
		END  
END