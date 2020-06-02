USE [Reports]
GO

/****** Object:  StoredProcedure [dbo].[PARAMS_SIPSUsersByLocation]    Script Date: 1/2/2019 2:11:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


Alter Procedure [dbo].[PARAMS_SIPSUsersByLocation]

@LocationNo CHAR(5)-- = '00006'

AS

/****************************************************************
RTHOMAS - Parameter for SIPS users similar to the PARAMS_UsersByLocation procedure
03/08/2010

BPaul and TDennis -  Changed to do the date calculation not in the query using the @dateinstock parameter.
*****************************************************************/

declare @dateinstock datetime = dateadd(day, -30, getdate())

select
	distinct CreateUser, asu.Name
from reportsdata..sipsproductinventory spi with (nolock)
left join reportsdata..asusers asu on asu.userchar30 = replace(spi.createuser, 'HPB\', '')
where dateinstock >= @dateinstock  --dateadd(day, -30, getdate())
and locationno = @locationno
order by asu.name
GO


