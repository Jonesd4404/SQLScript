DECLARE @po varchar(6) =  '282267'
DECLARE @rn int 

SELECT @rn = h.RequisitionNo
FROM VX_Requisition_Hdr h
WHERE PONumber = @po
	AND [Status]= 60


SELECT *
	INTO BACKUP_VX_Requisition_Hdr_20190318
FROM VX_Requisition_Hdr h
WHERE h.PONumber = @po


SELECT *
	INTO BACKUP_VX_Requisition_dtl_20190318
FROM VX_Requisition_Dtl d
WHERE d.RequisitionNo = @rn

SELECT *
	INTO BACKUP_VX_Requisition_Audit_Log_20190318
FROM VX_Requisition_Audit_Log al
WHERE al.PONumber = @po


begin transaction

	UPDATE h
		SET [Status] = 20
	FROM VX_Requisition_Hdr h
	WHERE [Status] = 60
		AND PONumber = @po

	UPDATE d
		SET [Status] = 20
	FROM VX_Requisition_Dtl d
	WHERE [Status] = 60
		AND RequisitionNo = @rn

	delete FROM al
	FROM VX_Requisition_Audit_Log al
	WHERE al.PONumber = @po


	SELECT *
	FROM VX_Requisition_Hdr 
	WHERE PONumber = @po

	SELECT *
	FROM VX_Requisition_Dtl 
	WHERE RequisitionNo = @rn

	SELECT *
	FROM VX_Requisition_Audit_Log
	WHERE PONumber= @po

-- commit transaction