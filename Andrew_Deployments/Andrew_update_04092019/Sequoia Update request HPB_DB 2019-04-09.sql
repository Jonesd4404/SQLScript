select userchar15, *
from VendorMaster 
where vendorid in ('IDALLPORTE','IDLANGHOLD','IDSOURCEDI')

begin transaction

update hpb_db.dbo.VendorMaster
	set userchar15 = 'STOC'
where vendorid in ('IDALLPORTE','IDLANGHOLD')


update hpb_db.dbo.VendorMaster
	set UserChar15 = 'VX'
where vendorid in ('IDSOURCEDI')


select userchar15, *
from VendorMaster 
where vendorid in ('IDALLPORTE','IDLANGHOLD','IDSOURCEDI')

-- commit transaction
-- rollback transaction