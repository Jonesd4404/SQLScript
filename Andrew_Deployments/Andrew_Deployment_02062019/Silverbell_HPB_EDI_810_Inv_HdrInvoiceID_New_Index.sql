
/*
Missing Index Details from SQLQuery12.sql - porcupine [silverbell].HPB_EDI (HPB\Andrew_Bender (71))
The Query Processor estimates that implementing the following index could improve the query cost by 30.4834%.
*/

/*
USE [HPB_EDI]
GO
CREATE NONCLUSTERED INDEX [InvoiceID]
ON [dbo].[810_Inv_Hdr] ([InvoiceACKSent])
INCLUDE ([InvoiceID],[InvoiceNo],[IssueDate],[VendorID],[PONumber],[ReferenceNo],[ShipFromSAN],[InsertDateTime],[GSNo])
GO
*/
