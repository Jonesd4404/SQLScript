USE [SIPS]
GO
/****** Object:  StoredProcedure [dbo].[BU_CustomerSearchV2]    Script Date: 7/14/2017 11:41:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[BU_CustomerSearchV3]
	@searchFor	varchar(255)
as	--03/10/13

set nocount on

declare @work as varchar(260),
	@workNumeric as numeric

set @work = @searchFor
/*
going to check to see if the string is a firstname/lastname combo, if it is, parse it and search by that, if not leave everything as it would be
*/
declare @firstName varchar(255) --because the search string could just be the firstname i.e. Madonna, Prince, etc
declare @lastName varchar(255) 

if isnumeric(@work) = 1  --id
	select @workNumeric = cast(@work as numeric), @firstName = cast(@work as numeric), @lastName = cast(@work as numeric) --keep it the same
else
	select @firstName = rtrim(left(@searchFor, CHARINDEX(' ', @searchFor))), @lastName = substring(@searchFor, CHARINDEX(' ', @searchFor) + 1, len(@searchFor) - (CHARINDEX(' ', @searchFor)-1))

--if isnumeric(@work) = 1 begin --id
--	set @workNumeric = cast(@work as numeric)
--end --id

if (@work is not null  and @work <> '' ) begin
	set @work = '' + @searchFor + '%'
end


select	distinct
lower(REPLICATE('*',round(len(c.GID) * .55,0)) + substring(c.GID, round(len(c.GID) * .55,0) +1, round(LEN(c.gid) * .45,0))) as GovtIssuedID,
	c.GID as HiddenGovtIssuedID,
	 c.Telephone as Phone,
	lower(c.LastName) as LastName, lower(c.FirstName) as FirstName,
	t.CustomerTypeName as [Type], 
	--f.FlagName as Flag,
	c.CustomerNo, 
	--c.CustomerID as [HPB ID],
	c.SetupDate
	--04.26.2016 for customer pop
	,c.CustomerFlagID
		--07.12.2017 add a ranking so i bring direct matches to the top
	,case 
		when c.FirstName = @FirstName and c.LastName = @lastName then 1
		when c.LastName = @LastName then 2
		else 3
	end sortOrder
from
	buys.dbo.BuyCustomers c
	--left join buys.dbo.BuyCustomerFlags f
	--	on c.CustomerFlagID = f.FlagID
	left join buys.dbo.BuyCustomerTypes t
		on c.CustomerTypeID = t.CustomerTypeID
	--BSSC only wants to see active customers within the last year (this is an effort to clean up the BuyCustomers table)
	--inner join buys.dbo.vwActiveBuyCustomersWithinAYear a
	--	on c.CustomerNo = a.CustomerNo
where
	CustomerID like @work
	or FirstName like @firstName
	or LastName like @lastName
	--or FirstName like @work
	--or LastName like @work
	or GID like @work
	or Telephone like @work
	or c.CustomerNo = @workNumeric
	--10.08.2015 only displaying customers withing the last year
	and SetupDate >= DATEADD(YY, -1, GETDATE())
	and c.Status != 'I'
order by 
	sortOrder, lastname, firstname, 
	c.CustomerNo desc



