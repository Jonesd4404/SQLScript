USE [SIPS]
GO

/****** Object:  Trigger [dbo].[TRG_SPI_U_ISIS_Inventory]    Script Date: 3/13/2018 1:35:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create trigger [dbo].[TRG_SPI_U_ISIS_Inventory]
on [SIPS].[dbo].[SipsProductInventory]
	after Update
as

begin
	set nocount on

	/********************************************************
	Update Type

	**Active Flag Updates**
	20 - Active flag update - Unknown
	21 - Active flag update - Transfer to Trash (T)
	22 - Active flag update - Transfer to Booksmarter (B)
	23 - Active flag update - Transfer to Donate (D)
	24 - Active flag update - Transfer to Marketing (K)
	25 - Active flag update - Item Missing (M)
	26 - Active flag update - Item reactivated (Y)
	

	**LocationNo Updates**
	3 - LocationNo update - Store to Store transfer

	**Price Updates**
	4 - Price updates

	**Product Type Updates**
	5 - Product type updates	
	********************************************************/	

	if update(Active)
	begin
		insert into SIPS.dbo.ISIS_SipsInventoryUpdates (TriggerType, ItemCode, SipsID)
		select case when i.Active = 'T' then 21
					when i.Active = 'B' then 22
					when i.Active = 'D' then 23
					when i.Active = 'K' then 24
					when i.Active = 'M' then 25
					when i.Active = 'Y' then 26
					else 20 end
			,i.ItemCode
			,i.SipsID			
		from inserted i 
	end

	if update(LocationNo)
	begin
		insert into SIPS.dbo.ISIS_SipsInventoryUpdates (TriggerType, ItemCode, SipsID, LocationNo, LocationID)
		select 3
			,i.ItemCode
			,i.SipsID
			,i.LocationNo
			,i.LocationID
		from Inserted i
	end

	if update(Price)
	begin
		insert into SIPS.dbo.ISIS_SipsInventoryUpdates (TriggerType, ItemCode, SipsID, Price)
		select 4
			,i.ItemCode
			,i.SipsID
			,i.Price
		from inserted i
	end

	if update(ProductType)
	begin
		insert into SIPS.dbo.ISIS_SipsInventoryUpdates (TriggerType, ItemCode, SipsID, ProductType)
		select 5
			,i.ItemCode
			,i.SipsID
			,i.ProductType
		from inserted i
	end
end



GO

ALTER TABLE [dbo].[SipsProductInventory] ENABLE TRIGGER [TRG_SPI_U_ISIS_Inventory]
GO


