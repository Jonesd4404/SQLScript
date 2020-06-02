
/*
BEGIN: RUN ONCE
*/
use Bookworm
go

----very old and outdated. started the process while bw3 was in its infancy and didn't keep up with the changes. 
--drop table archive_searchCatalogResults
--go
--drop table archive_searchInventory
--go
--drop table archive_searchMapping
--go
--drop table archive_searchResult
--go

--DROP TABLE archive_processing
----table to log archiving. 
--USE Bookworm
--create table archive_processing (searchId bigint, insertDate datetime2(2), archiveComplete bit, processed bit, processed_Date DateTime, archiveDate datetime2(2))
--go
--/*
--END: RUN ONCE
*/



/*
BEGIN: DAILY DELETES
*/
use bookworm 
go
declare @maxarchivedate datetime = dateadd(month, -6, current_timestamp) --never archive anything within the last six months
declare @currnetarchivedate datetime = (select min(dateadd(month, 1, searchdate)) from search) --maximum date for this archive process
if(@currnetarchivedate > @maxarchivedate)
begin
	set @currnetarchivedate = @maxarchivedate
end
print @currnetarchivedate

--insert all searchids order than the maximum date for the archive process
create table #archivesearches(searchid bigint)
create clustered index idx_archsearchtemp_searchid on #archivesearches(searchid)
insert into #archivesearches 
select searchid 
from search where searchDate < @currnetarchivedate


insert into archive_processing(searchid, insertdate, archivecomplete)
select searchid, current_timestamp, 0 from #archivesearches
--select * from #archivesearches

begin tran
delete s from searchCatalogResults s join #archivesearches a on s.searchId = a.searchid
delete s from searchFacets s join #archivesearches a on s.searchId = a.searchid
delete s from searchinventory s join #archivesearches a on s.searchId = a.searchid
delete s from searchmapping s join #archivesearches a on s.searchId = a.searchid
delete s from searchresult s join #archivesearches a on s.searchId = a.searchid
delete s from searchstats s join #archivesearches a on s.searchId = a.searchid
delete s from search s join #archivesearches a on s.searchId = a.searchid

--rollback tran
commit tran


--more overhead than I would like, but I also want to log the start and stop of this process. 
--i could create two archive tables start/finish tables with time stamps and have multiple joins... 
--i'll think about it. 
update archive_processing
set archivecomplete = 1, archivedate = current_timestamp
from archive_processing ap
	join #archivesearches s
		on s.searchid = ap.searchid

drop table #archivesearches

/*
END: DAILY DELETES
*/