USE Sips

--User Level
insert into AppSecGroups
(ApplicationID, SecurityGroup, DisplayName, StatusCode, ADGroupModeEnabled, ADGroupName, SecurityLevelIDEnabled, SecurityLevelID)
values
(1, 'ADMIN', 'ADMIN', 1, 0, null, 1, 1)

insert into AppSecLoginReferenceTypes
(UserLoginReferenceTypeID, UserLoginReferenceTypeName)
values
(1, 'Windows')

insert into AppSecUserLocationGroup
(ApplicationID, UserLoginIdentifier, LocationNo, StatusCode, SecurityGroup, UserLoginReference, UserLoginReferenceTypeID)
values
(1, 'ALe', '00001', 1, 'ADMIN', 'ALe', 1)

--Application Components
insert into AppSecModuleFunctionObjects
(ApplicationID, ModuleName, FunctionName, FormName, ControlName, ControlItemName, ControlType)
values
(1, 'Buy Items', 'Print Barcodes', 'frmBuyItems', 'buttonPrint', 'buttonPrint', 'Button'),
(1, 'Buys', 'Print Sips Labels', 'frmBuysV5', 'CheckBoxPrintSipsLabels', 'CheckBoxPrintSipsLabels', 'CheckBox')

insert into AppSecModules
(ApplicationID, ModuleName, StatusCode)
values
(1, 'Buy Items', 1),
(1, 'Buys', 1)

insert into AppSecGroupModuleFunction
(ApplicationID, SecurityGroup, ModuleName, FunctionName, StatusCode, ObjectEnabled, ObjectVisible)
values
(1, 'ADMIN', 'Buy Items', 'Print Barcodes', 1, 1, 1),
(1, 'ADMIN', 'Buys', 'Print Sips Labels', 1, 1, 1)