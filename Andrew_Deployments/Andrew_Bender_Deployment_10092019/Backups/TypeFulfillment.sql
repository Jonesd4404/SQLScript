USE [HPB_EDI]
GO

/****** Object:  UserDefinedTableType [CDF].[TypeFulfillment]    Script Date: 10/9/2019 10:13:19 AM ******/
CREATE TYPE [CDF].[TypeFulfillment] AS TABLE(
	[Id] [bigint] NULL,
	[LastTransactionId] [tinyint] NULL,
	[VendorId] [varchar](20) NULL,
	[SourceApplication] [varchar](20) NULL,
	[OrderNumber] [varchar](22) NULL,
	[QuantityOrdered] [int] NULL,
	[QuantityConfirmed] [int] NULL,
	[QuantityBackordered] [int] NULL,
	[QuantityCancelled] [int] NULL,
	[QuantitySlashed] [int] NULL,
	[QuantityShipped] [int] NULL,
	[QuantityInvoiced] [int] NULL,
	[LastModifiedDateUTC] [datetime2](7) NULL,
	[LastModifiedUTCOffset] [int] NULL,
	[RequestedShipMethod] [char](3) NULL
)
GO

