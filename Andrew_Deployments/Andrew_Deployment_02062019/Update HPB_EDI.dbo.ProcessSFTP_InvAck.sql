-- ==========================================================================================
-- Description:	Builds a list of Invoice ACKs to be exported to SFPT folders thru EDI.....
-- Created:		2015-05-08  Joey B.
-- Updates:
--				2019-02-06 ALB Changed to CTE and modified vendor join to speed up procedure
-- ==========================================================================================
ALTER PROCEDURE [dbo].[ProcessSFTP_InvAck]
AS

BEGIN

	SET NOCOUNT ON;

	;WITH dataset AS (
	SELECT   h.InvoiceID
			,h.InvoiceNo
			,v.ParentFolder
			,v.[Binary]
			,h.ShipFromSAN
			,h.IssueDate
			,h.InsertDateTime
			,h.PONumber 
			,h.GSNo
			,h.ReferenceNo
			,dbo.EDIfn_GetInvoiceACKDtls(h.InvoiceNo) AS InvoiceACKDtls			
	FROM HPB_EDI..[810_Inv_Hdr] h 
		INNER JOIN HPB_EDI..[810_Inv_Dtl] d 
			ON h.InvoiceID=d.InvoiceID
		INNER JOIN HPB_EDI..Vendor_SAN_Codes v 
			ON h.VendorID=v.VendorID
				AND v.Invoice997=1
				AND v.Processor='SFTP'
	WHERE h.InvoiceACKSent=0 
	GROUP BY h.InvoiceID, h.InvoiceNo, v.[Binary], v.ParentFolder, h.ShipFromSAN, h.IssueDate, h.InsertDateTime, h.PONumber, h.GSNo, h.ReferenceNo
)
SELECT	 InvoiceID
		,InvoiceNo
		,ParentFolder
		,CASE WHEN Binary=0 
			THEN 
				'ISA*00*          *00*          *ZZ*760985X        *ZZ*'+ CAST(ShipFromSAN AS CHAR(15)) 
				+'*'+CONVERT(VARCHAR(6),IssueDate,12)+'*'+REPLACE(CONVERT(VARCHAR(5),InsertDateTime,108),':','')
				+CASE WHEN ShipFromSAN IN ('8600023') 
					THEN '*:*00200*'+RIGHT('000000000'+CAST(DATEPART(dy, GETDATE()) AS VARCHAR(5)) + CAST(PONumber AS VARCHAR(10)),9)  
					ELSE '*:*00200*'+RIGHT('0000000000'+PONumber,9) 
				 END +'*0*P*>~'
				+CHAR(13) + CHAR(10)
				+'GS*FA*760985X*'+ShipFromSAN+'*'+CONVERT(VARCHAR(6),IssueDate,12)+'*'+REPLACE(CONVERT(VARCHAR(5),InsertDateTime,108),':','')+'*000000002*X*003060~'
				+CHAR(13) + CHAR(10)
				+'ST*997*000000001~'
				+CHAR(13) + CHAR(10)
				+'AK1*IN*'+CASE WHEN ShipFromSAN IN ('8600023') 
								THEN CONVERT(VARCHAR(12),GSNo) 
								ELSE CONVERT(VARCHAR(12),ReferenceNo)
						  END+'~'
				+CHAR(13) + CHAR(10)
				+ InvoiceACKDtls
				+'AK9*A*'+CONVERT(VARCHAR(10),(('1')))+'*'+CONVERT(VARCHAR(10),(('1')))+'*'+CONVERT(VARCHAR(10),(('1')))+'~'
				+CHAR(13) + CHAR(10)
				+'SE*'+CONVERT(VARCHAR(10),(('6')))+'*000000001~'
				+CHAR(13) + CHAR(10)
				+'GE*1*000000002~'
				+CHAR(13) + CHAR(10)
				+'IEA*1*'+CASE WHEN ShipFromSAN IN ('8600023') 
								THEN RIGHT('000000000'+CAST(DATEPART(dy, GETDATE()) AS VARCHAR(5)) + CAST(PONumber AS VARCHAR(10)),9) 
								ELSE RIGHT('0000000000'+PONumber,9) 
						 END +'~'
		ELSE
			CONVERT(VARCHAR(max),CONVERT(varbinary(max),CONVERT(VARCHAR(max),
				'ISA*00*          *00*          *ZZ*760985X        *ZZ*'+ CAST(ShipFromSAN AS CHAR(15)) +'*'+CONVERT(VARCHAR(6),IssueDate,12)+'*'+REPLACE(CONVERT(VARCHAR(5),InsertDateTime,108),':','')
				+CASE WHEN ShipFromSAN IN ('8600023') 
						THEN '*:*00200*'+RIGHT('000000000'+CAST(DATEPART(dy, GETDATE()) AS VARCHAR(5)) + CAST(PONumber AS VARCHAR(10)),9) 
						ELSE '*:*00200*'+RIGHT('0000000000'+PONumber,9) 
				 END +'*0*P*>~'
				+CHAR(13) + CHAR(10)
				+'GS*FA*760985X*'+ShipFromSAN+'*'+CONVERT(VARCHAR(6),IssueDate,12)+'*'+REPLACE(CONVERT(VARCHAR(5),InsertDateTime,108),':','')+'*000000002*X*003060~'
				+CHAR(13) + CHAR(10)
				+'ST*997*000000001~'
				+CHAR(13) + CHAR(10)
				+'AK1*IN*'+CASE WHEN ShipFromSAN IN ('8600023') 
								THEN CONVERT(VARCHAR(12),GSNo) 
								ELSE CONVERT(VARCHAR(12),ReferenceNo)
						  END+'~'
				+CHAR(13) + CHAR(10)
				+InvoiceACKDtls
				+'AK9*A*'+CONVERT(VARCHAR(10),(('1')))+'*'+CONVERT(VARCHAR(10),(('1')))+'*'+CONVERT(VARCHAR(10),(('1')))+'~'
				+CHAR(13) + CHAR(10)
				+'SE*'+CONVERT(VARCHAR(10),(('6')))+'*000000001~'
				+CHAR(13) + CHAR(10)
				+'GE*1*000000002~'
				+CHAR(13) + CHAR(10)
				+'IEA*1*'+CASE WHEN ShipFromSAN IN ('8600023') 
								THEN RIGHT('000000000'+CAST(DATEPART(dy, GETDATE()) AS VARCHAR(5)) + CAST(PONumber AS VARCHAR(10)),9)  
								ELSE RIGHT('0000000000'+PONumber,9) END +'~')),1)
		END [FileText]
FROM dataset 


/* previous code 
		select distinct h.InvoiceID,h.InvoiceNo,v.ParentFolder, 
				case when v.Binary=0 then 
				'ISA*00*          *00*          *ZZ*760985X        *ZZ*'+ cast(h.ShipFromSAN as CHAR(15)) 
				+'*'+convert(varchar(6),h.IssueDate,12)+'*'+replace(convert(varchar(5),h.InsertDateTime,108),':','')
				+case when h.ShipFromSAN in ('8600023') then '*:*00200*'+right('000000000'+cast(datepart(dy, getdate()) as varchar(5)) + cast(h.PONumber as varchar(10)),9)  
					else '*:*00200*'+RIGHT('0000000000'+h.PONumber,9) end +'*0*P*>~'
				+CHAR(13) + CHAR(10)
				+'GS*FA*760985X*'+h.ShipFromSAN+'*'+convert(varchar(6),h.IssueDate,12)+'*'+replace(convert(varchar(5),h.InsertDateTime,108),':','')+'*000000002*X*003060~'
				+CHAR(13) + CHAR(10)
				+'ST*997*000000001~'
				+CHAR(13) + CHAR(10)
				+'AK1*IN*'+case when h.ShipFromSAN in ('8600023') then CONVERT(varchar(12),h.GSNo) else CONVERT(varchar(12),h.ReferenceNo)end+'~'
				+CHAR(13) + CHAR(10)
				+ dbo.EDIfn_GetInvoiceACKDtls(h.InvoiceNo)
				+'AK9*A*'+convert(varchar(10),(('1')))+'*'+convert(varchar(10),(('1')))+'*'+convert(varchar(10),(('1')))+'~'
				+CHAR(13) + CHAR(10)
				+'SE*'+convert(varchar(10),(('6')))+'*000000001~'
				+CHAR(13) + CHAR(10)
				+'GE*1*000000002~'
				+CHAR(13) + CHAR(10)
				+'IEA*1*'+case when h.ShipFromSAN in ('8600023') then right('000000000'+cast(datepart(dy, getdate()) as varchar(5)) + cast(h.PONumber as varchar(10)),9) 
					else RIGHT('0000000000'+h.PONumber,9) end +'~'
				else
				CONVERT(varchar(max),CONVERT(varbinary(max),CONVERT(varchar(max),
				'ISA*00*          *00*          *ZZ*760985X        *ZZ*'+ cast(h.ShipFromSAN as CHAR(15)) +'*'+convert(varchar(6),h.IssueDate,12)+'*'+replace(convert(varchar(5),h.InsertDateTime,108),':','')
				+case when h.ShipFromSAN in ('8600023') then '*:*00200*'+right('000000000'+cast(datepart(dy, getdate()) as varchar(5)) + cast(h.PONumber as varchar(10)),9) 
					else '*:*00200*'+RIGHT('0000000000'+h.PONumber,9) end +'*0*P*>~'
				+CHAR(13) + CHAR(10)
				+'GS*FA*760985X*'+h.ShipFromSAN+'*'+convert(varchar(6),h.IssueDate,12)+'*'+replace(convert(varchar(5),h.InsertDateTime,108),':','')+'*000000002*X*003060~'
				+CHAR(13) + CHAR(10)
				+'ST*997*000000001~'
				+CHAR(13) + CHAR(10)
				+'AK1*IN*'+case when h.ShipFromSAN in ('8600023') then CONVERT(varchar(12),h.GSNo) else CONVERT(varchar(12),h.ReferenceNo)end+'~'
				+CHAR(13) + CHAR(10)
				+ dbo.EDIfn_GetInvoiceACKDtls(h.InvoiceNo)
				+'AK9*A*'+convert(varchar(10),(('1')))+'*'+convert(varchar(10),(('1')))+'*'+convert(varchar(10),(('1')))+'~'
				+CHAR(13) + CHAR(10)
				+'SE*'+convert(varchar(10),(('6')))+'*000000001~'
				+CHAR(13) + CHAR(10)
				+'GE*1*000000002~'
				+CHAR(13) + CHAR(10)
				+'IEA*1*'+case when h.ShipFromSAN in ('8600023') then right('000000000'+cast(datepart(dy, getdate()) as varchar(5)) + cast(h.PONumber as varchar(10)),9)  
					else RIGHT('0000000000'+h.PONumber,9) end +'~')),1)
				end [FileText]
		from HPB_EDI..[810_Inv_Hdr] h with(nolock) inner join HPB_EDI..[810_Inv_Dtl] d with(nolock) on h.InvoiceID=d.InvoiceID
				inner join HPB_EDI..Vendor_SAN_Codes v with(nolock) on h.VendorID=v.VendorID
		where h.InvoiceACKSent=0 and v.processor='SFTP' and h.VendorID in (select VendorID from HPB_EDI..Vendor_SAN_Codes where Invoice997=1)
*/
END
GO