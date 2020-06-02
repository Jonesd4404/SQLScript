USE [ReportsData]
GO

/****** Object:  Table [dbo].[LocationsDist]    Script Date: 1/24/2019 1:35:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LocationsDist](
	[LocationID] [char](10) NOT NULL,
	[ManifestTitle] [varchar](255) NULL,
	[TransferTypeID] [int] NULL,
	[WebReceiving] [char](1) NOT NULL,
	[Region] [varchar](30) NULL,
	[Rank1] [char](1) NULL,
	[OpenDate] [datetime] NULL,
 CONSTRAINT [PK_LocationsDist] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[LocationsDist] ADD  CONSTRAINT [DF_LocationsDist_WebReceiving]  DEFAULT ('Y') FOR [WebReceiving]
GO


