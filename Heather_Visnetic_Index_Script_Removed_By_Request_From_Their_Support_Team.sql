USE [VisNetic MailFlow]
GO

/****** Object:  Index [IX_TicketActionID]    Script Date: 9/10/2018 11:39:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_TicketActionID] ON [dbo].[TicketHistory]
(
	[TicketActionID] ASC,
	[ID1] ASC,
	[ID2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


