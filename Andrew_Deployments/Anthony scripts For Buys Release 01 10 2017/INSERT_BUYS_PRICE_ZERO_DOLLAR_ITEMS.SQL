use sips


insert into apprtomain
(applicationid, optionname, optionvalue, statuscode, recorddatetime, usemainonly)
values
(1, 'BUYS_PRICE_ZERO_DOLLAR_ITEMS=', 'True', 1, getdate(), 0)

--select * from apprtomain
go

insert into AppRtoLocation
(LocationNo, ApplicationID, OptionName, OptionValue, StatusCode, RecordDatetime)
values
('00001', 1, 'BUYS_PRICE_ZERO_DOLLAR_ITEMS=', 'False', 1, getdate())

--select * from AppRtoLocation
