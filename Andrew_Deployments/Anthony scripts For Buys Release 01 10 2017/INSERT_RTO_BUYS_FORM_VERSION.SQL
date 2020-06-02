use sips

insert into AppRtoMain
(ApplicationID, OptionName, OptionValue, StatusCode, RecordDateTime, UseMainOnly)
values
(1, 'BUYS_FORM_VERSION=', 'frmBuysV4', 1, getdate(), 0)

select top 10 * from AppRtoLocation

insert into AppRtoLocation
(LocationNo, ApplicationID, OptionName, OptionValue, StatusCode, RecordDateTime)
values
('00001', 1, 'BUYS_FORM_VERSION=', 'frmBuysV5', 1, getdate())