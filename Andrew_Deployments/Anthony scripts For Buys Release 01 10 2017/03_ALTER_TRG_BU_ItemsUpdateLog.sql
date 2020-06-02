USE [BUYS]
GO
/****** Object:  Trigger [dbo].[TRG_BU_ItemsUpdateLog]    Script Date: 7/19/2017 3:05:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TABLE BuyBinItemsUpdateLog
ADD LabelPrinted int

go

ALTER trigger [dbo].[TRG_BU_ItemsUpdateLog] on [dbo].[BuyBinItems] for update
as	--06/09/13
insert	dbo.BuyBinItemsUpdateLog (LocationNo, BuyBinNo, ItemLineNo, StatusCode, BuyTypeID, Quantity, Offer, LastUpdateUser, LastUpdateTime, LastUpdateMachine, LastUpdateType, LabelPrinted)
select	LocationNo, BuyBinNo, ItemLineNo, StatusCode, BuyTypeID, Quantity, Offer, LastUpdateUser, LastUpdateTime, LastUpdateMachine, LastUpdateType, LabelPrinted
from	deleted




