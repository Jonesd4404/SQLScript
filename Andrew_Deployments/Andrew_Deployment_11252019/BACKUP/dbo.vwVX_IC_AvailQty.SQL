USE [HPB_Logistics]
GO

/****** Object:  View [dbo].[vwVX_IC_AvailQty]    Script Date: 11/25/2019 9:36:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwVX_IC_AvailQty]
AS
	SELECT i_n.ISBNUPC, 'N' AS Warehouse, i_n.LVTN_OnHand AS QtyOnHand
	FROM meta.IngramContentDCQuantities i_n
	WHERE i_n.LVTN_Flag = 'Y' and i_n.LVTN_OnHand > 0
	UNION
	SELECT i_b.ISBNUPC, 'B' AS Warehouse, i_b.ATPA_OnHand AS QtyOnHand
	FROM meta.IngramContentDCQuantities i_b
	WHERE i_b.ATPA_Flag = 'Y' and i_b.ATPA_OnHand > 0
	UNION
	SELECT i_c.ISBNUPC, 'C' AS Warehouse, i_c.CBPA_OnHand AS QtyOnHand
	FROM meta.IngramContentDCQuantities i_c
	WHERE i_c.CBPA_Flag = 'Y' and i_c.CBPA_OnHand > 0
	UNION
	SELECT i_d.ISBNUPC, 'D' AS Warehouse, i_d.FWIN_OnHand AS QtyOnHand
	FROM meta.IngramContentDCQuantities i_d
	WHERE i_d.FWIN_Flag = 'Y' and i_d.FWIN_OnHand > 0
	UNION
	SELECT ISBNUPC, 'E' AS Warehouse, RBOR_OnHand AS QtyOnHand
	FROM meta.IngramContentDCQuantities i_e
	WHERE i_e.RBOR_Flag = 'Y'and i_e.RBOR_OnHand > 0
	UNION
	SELECT i_j.ISBNUPC, 'J' AS Warehouse, FOCA_OnHand AS QtyOnHand
	FROM Meta.IngramContentDCQuantities i_j
	WHERE i_j.FOCA_Flag = 'Y' and i_j.FOCA_OnHand > 0

GO

