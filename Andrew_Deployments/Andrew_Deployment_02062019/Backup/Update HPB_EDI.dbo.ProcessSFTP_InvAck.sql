USE [HPB_EDI]
GO

/****** Object:  StoredProcedure [dbo].[ProcessSFTP_InvAck]    Script Date: 2/6/2019 2:32:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Joey B.>
-- Create date: <5/8/2015>
-- Description:	<Builds a list of Invoice ACKs to be exported to SFPT folders thru EDI.....>
-- =============================================
CREATE PROCEDURE [dbo].[ProcessSFTP_InvAck]
AS

BEGIN

	SET NOCOUNT ON;

	
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


END





GO


