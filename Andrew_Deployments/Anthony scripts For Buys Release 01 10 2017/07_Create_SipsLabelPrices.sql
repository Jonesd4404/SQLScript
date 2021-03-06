USE [SIPS]
GO
/****** Object:  Table [dbo].[SipsLabelPrices]    Script Date: 8/25/2017 12:26:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SipsLabelPrices](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[Price] [decimal](10, 2) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO

insert into sipslabelprices
(price, isactive)
values
(5.99, 1),
(6.99, 1),
(7.99, 1),
(8.99, 1),
(9.99, 1),
(10.99, 1)
