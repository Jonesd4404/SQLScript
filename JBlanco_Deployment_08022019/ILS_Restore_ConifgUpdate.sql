-----==========================================================================================================================================================================
-----==========================================================================================================================================================================

USE [ILS]
GO

declare @DBserver nvarchar(100) 
declare @dbInstance nvarchar(100) 
declare @server nvarchar(100) 

set @DBserver = N'wmstestsql' --replace your name
set @dbInstance = N'ILS' -- If Database server is using default instance, just keep it empty
set @server = 'WMSTESTAPP' -- replace your name

-- Main 
update main_ui_screen
set path = N'http://'+@server+':9500/Main.cps' 
where form_id = 155;

-- Billing Mgmt Web
update main_ui_screen
set path = N'http://'+@server+'/BMWEB'
where form_id = 2598;

-- Billing Mgmt File Path 
update system_config_detail
set system_value = N'\\' + @server + '\ILS\BillingMgt'
where record_type = N'PkCost' and sys_key = N'10';

-- Billing Mgmt Output Path
update system_config_detail
set system_value = N'\\' + @server + '\ILS\BillingMgt\Interfaces'
where record_type = N'PkCost' and sys_key = N'20';

---- Slotting Optimization
--update main_ui_screen
--set path = N'C:\Program Files\Manhattan Associates\Slotting Optimization 2020\Bin\WinSlot.vbs'
--where form_id = 2600;

-- Slotting Upload File Path
update system_config_detail
set system_value = N'\\' + @server + '\ILS\Slotting\Upload'
where record_type = N'SLOT' and sys_key = N'10';

-- Int Download Input Dir
update system_config_detail
set system_value = N'\\' + @server + '\ILS\Interface\Input\'
where record_type = N'Interface' and sys_key = N'30';

-- Int Download Output Dir
update system_config_detail
set system_value = N'\\' + @server + '\ILS\Interface\Output\'
where record_type = N'Interface' and sys_key = N'40';

-- Int Upload Output Dir
update system_config_detail
set system_value = N'\\' + @server + '\ILS\Interface\Upload\'
where record_type = N'Interface' and sys_key = N'150';

-- Interface Stylesheet directory
update system_config_detail 
set system_value = N'\\'+@server+'\ILS\Interface\xsl'
where  record_type=N'Interface' and sys_key=N'180';

-- MR File Path
update system_config_detail
set system_value = N'\\' + @server + '\ILS\Reporting\MA Starter Reports\SQL Server'
where record_type = N'Technical' and sys_key = N'100';

-- Print Engine Location
update system_config_detail
set system_value = @server
where record_type = N'Technical' and sys_key = N'120';

-- Name or IP Address of the Reporting Server
update system_config_detail
set system_value = @server
where record_type = N'Technical' and sys_key = N'140';

-- template file path
update system_config_detail
set system_value = N'\\' + @server + '\ILS\Printing'
where record_type = N'Technical' and sys_key = N'170';

-- Default RF URL
update main_ui_screen 
set path = N'http://'+@server+'/RF/logon.aspx' 
where  form_id = 2514;

-- Personal Alerts
update system_config_detail 
set system_value = N'\\' + @server + '\ILS\Printing' 
where  record_type = N'Technical' and sys_key=N'310';

-- Workflow Directory
update system_config_detail 
set system_value = N'\\' + @server + '\ILS\Workflow' 
where record_type = N'Technical' and sys_key=N'350';

-- Order Directory
update system_config_detail
set system_value = N'\\' + @server + '\ILS\WebOrder'
where record_type = N'Web Inq' and sys_key = N'60';

-- Personal Views default report directory
update system_config_detail
set system_value = N'\\' + @server + '\ILS\Reporting'
where record_type = N'Web Inq' and sys_key = N'80';

-- Reviewed Order Directory
update system_config_detail
set system_value = N'\\' + @server + '\ILS\WebOrder\Reviewed'
where record_type = N'Web Inq' and sys_key = N'90';

-- Web Stylesheet directory
update system_config_detail
set system_value = N'\\'+@server+'\ILS\TPM\xsl'
where record_type = N'Web Inq' and sys_key = N'120';

-- Default TPM URL 
update main_ui_screen
set path = N'http://'+@server+'/TPM/UserSignon.aspx'
where form_id = 2513;

-- Performance Management Default Documents
update system_config_detail
set system_value = N'\\'+@server+'\ILS\Performance Management'
where record_type = N'PERFMAN' and sys_key = N'10';

-- Performance Management Analytics
update system_config_detail 
set system_value = N'\\'+@server+'\ILS\Performance Management\Analytics' 
where record_type = 'PERFMAN' and sys_key = '30';

---- Progistics
--update main_ui_screen
--set path = N'http://'+@server+'/Progistics/asp/index.asp'
--where form_id = 2599;

-- SQL Server Reporting Services Report Server 
update system_config_detail 
set system_value = N'http://'+@DBserver+'/reportserver'+@dbInstance 
where record_type = N'Technical' and sys_key = N'360';

-- Assortment MOD change
update system_config_detail 
set system_value = N'soap.tcp://'+@server+':9008/InterfaceWS'
where record_type = N'HALFMD02SYSVALUE' and sys_key = N'INTWEBSRVURI';


update SYSTEM_CONFIG_DETAIL
set SYSTEM_VALUE = REPLACE(system_value,'WMSAPP','WMSTESTAPP')
where SYSTEM_VALUE like '%WMSAPP%'

update SYSTEM_CONFIG_DETAIL set SYSTEM_VALUE='http://SQUIRREL/reportserver' where OBJECT_ID = 226 --SQL Server Reporting Services Report Server URL
update SYSTEM_CONFIG_DETAIL set SYSTEM_VALUE='SQUIRREL' where OBJECT_ID=121  --Name or IP Address of the Reporting Server.
update SYSTEM_CONFIG_DETAIL set SYSTEM_VALUE='soap.tcp://WMSTESTAPP:9008/InterfaceWS' where OBJECT_ID=241  --Interface Web Service URI

update MAIN_UI_SCREEN set PATH = REPLACE(PATH,'WMSAPP','WMSTESTAPP') where PATH like '%WMSAPP%' 

update SYSTEM_CONFIG_DETAIL set SYSTEM_VALUE='N' where SYS_KEY = 'Progistics Installed'
update SCHEDULED_JOBS set ACTIVE = 'N' where (USER_DEF2='Y' or ACTIVE='Y' )and JOB_NAME<>'RA - Daily Item Balance'






















