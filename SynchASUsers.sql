--update on server: Weirwood
use sips

--save current copy
select * into zzz_ASUsers_copy_12_22_17 from dbo.ASUsers

--update all 
update sips.dbo.ASUsers
set 
	UserNo = n.UserNo, AddDate = n.AddDate, AddLocationNo = n.AddLocationNo, 
	AddUserNo = n.AddUserNo, EmailAddress = n.EmailAddress, IsCorporateMgr = n.IsCorporateMgr, 
	IsLocationMgr = n.IsLocationMgr, IsMarketMgr=n.IsMarketMgr, 
	IsRegionalMgr = n.IsRegionalMgr, IsSysAdmin = n.IsSysAdmin, IsSystemMgr = n.IsSystemMgr, Name = n.Name, [Password] = n.[Password], 
	[Status] = n.[Status], UserChar15 = n.UserChar15, UserChar30 = n.UserChar30, UserDate1 = n.UserDate1, 
	UserDate2 = n.UserDate2, UserID = n.UserID, UserInt1 = n.UserInt1, UserInt2 = n.UserInt2, 
	UserLevel = n.UserLevel, UserNum1 = n.UserNum1, UserNum2 = n.UserNum2, AddStationNo = n.AddStationNo, 
	ModifyDate = n.ModifyDate, ModifyLocationNo = n.ModifyLocationNo, ModifyStationNo = n.ModifyStationNo, 
	ModifyUserNo = n.ModifyUserNo, AllowAsOverride = n.AllowAsOverride, msrepl_tran_version = n.msrepl_tran_version
from sips.dbo.ASUsers o
	inner join sips.dbo.ASUsersSequoia n 
		on o.UserNo = n.UserNo
--where	o.ModifyDate <> n.ModifyDate
/*
select * from zzz_ASUsers_copy_12_22_17

select o.UserChar30 , n.UserChar30 from zzz_ASUsers_copy_12_22_17 o inner join ASUsers n
on o.UserNo = n.UserNo
where  o.UserChar30 <> n.UserChar30
*/