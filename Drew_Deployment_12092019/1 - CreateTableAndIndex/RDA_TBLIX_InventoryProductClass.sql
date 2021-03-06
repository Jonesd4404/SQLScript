USE [ReportsData]


CREATE TABLE RDA_InventoryProductClass (
	ProductClassID int identity not null,
	Type_Description varchar(15) null,
	ProductType varchar(4) null,
	Category varchar(15) null,
	CONSTRAINT [PK_RDA_InventoryProductClass] PRIMARY KEY CLUSTERED 
(
       [ProductClassID] 
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 97) ON [PRIMARY]
) ON [PRIMARY]


