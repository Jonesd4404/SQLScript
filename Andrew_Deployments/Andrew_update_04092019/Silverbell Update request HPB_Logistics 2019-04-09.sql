select * from STOC_Users where userid = 'dtaylor2'

begin transaction

update HPB_Logistics.dbo.STOC_Users
	set  UserAccessCode = 'district'
		,UserLocation = '00981'
		,UserActive = 'A'
where userid = 'dtaylor2'

select * from STOC_Users where userid = 'dtaylor2'

-- commit transaction
-- rollback transaction