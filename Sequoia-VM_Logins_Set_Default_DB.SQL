/* sp_help_revlogin script 
** Generated Sep  1 2017  6:28AM on SEQUOIA */
 
DECLARE @pwd sysname
 
-- Login: AutoEmail
SET @pwd = CONVERT (varbinary(256), 0x0100903F7144531F238EC84B93A92595DB830FA1952F93143181D0657735E1CDC47DC79C278C7727E1AF6553402E)
EXEC master..sp_addlogin 'AutoEmail', @pwd, @sid = 0xA76CFBCC1FA7714FAF2EEFCCA9F4327E, @encryptopt = 'skip_encryption'

--exec sp_defaultdb @loginame='YourDomain\YourLogin', @defdb='YourDatabase'
exec sp_defaultdb @loginame='AutoEmail', @defdb='HPB_db'
 
-- Login: bookwormmsmq
SET @pwd = CONVERT (varbinary(256), 0x0100471C2624DFB756A9C58560D741E75536DFD622E77E784FBBFDC650FC7C50244D0B3F41F9966704DC5CFFC997)
EXEC master..sp_addlogin 'bookwormmsmq', @pwd, @sid = 0xD52A08BF47961641A888E5358C8AE4A0, @encryptopt = 'skip_encryption'

--exec sp_defaultdb @loginame='YourDomain\YourLogin', @defdb='YourDatabase'
exec sp_defaultdb @loginame='bookwormmsmq', @defdb='master'
 
 -- Login: BUILTIN\Administrators
EXEC master..sp_grantlogin 'BUILTIN\Administrators'
exec sp_defaultdb @loginame='BUILTIN\Administrators', @defdb='master'

 
-- Login: CardPrinter
SET @pwd = CONVERT (varbinary(256), 0x0100903F7144B7690053390032D987125C49F3EE07C780297973D3EEF394D3DEDA9BA6337499F0D768D219F27CCE)
EXEC master..sp_addlogin 'CardPrinter', @pwd, @sid = 0xDECC48B8B1411D44AAF2EF6C0475890A, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='CardPrinter', @defdb='HPB_db'
 
-- Login: CustRepl
SET @pwd = CONVERT (varbinary(256), 0x0100903F71448A905D6C431FBC17DF4ED455CA4AD946CA68A80FAC7DA3A60D8A08DBB050299516ABBE22F1C34546)
EXEC master..sp_addlogin 'CustRepl', @pwd, @sid = 0x5A91A9CA1C374349BD91DA30BE465380, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='CustRepl', @defdb='master'
 
-- Login: dbamaint
SET @pwd = CONVERT (varbinary(256), 0x0100903F714482CA940439A3C7A4AF236E110BA11355D94C4EDAC1ADBDCFFD96BFE1EEED81470B89A4EBD8F86A51)
EXEC master..sp_addlogin 'dbamaint', @pwd, @sid = 0x966963B9EEEA284CA67D7DFDBC669926, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='dbamaint', @defdb='master'
 
-- Login: distributor_admin
SET @pwd = CONVERT (varbinary(256), 0x01005C37784F8DA82E126DDD44410ECA6CCE0ABA3160ECD0DA218DA82E126DDD44410ECA6CCE0ABA3160ECD0DA21)
EXEC master..sp_addlogin 'distributor_admin', @pwd, @sid = 0xAA9B7EFD064C1E4897DF167140353915, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='distributor_admin', @defdb='master'

-- Login: DTSUser
SET @pwd = CONVERT (varbinary(256), 0x0100903F714422C118422F3C2727F3ED40D6119E35C42C9EF5AB895CD37D69946AB73A0CEAA20324CF8E98501C98)
EXEC master..sp_addlogin 'DTSUser', @pwd, @sid = 0xB717FC54E82A884AB50866EB1C64D9E6, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='DTSUser', @defdb='master'

-- Login: gcservicecstar
SET @pwd = CONVERT (varbinary(256), 0x01003458AF31B9829A663006052F815847E2141F6DE75A1EA8B0C80FDBCF99E6B8D02832002B38A41E46FD4C0355)
EXEC master..sp_addlogin 'gcservicecstar', @pwd, @sid = 0x39C3403636FE384F950810C20950CBB2, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='gcservicecstar', @defdb='master'

-- Login: gcservicewobo
SET @pwd = CONVERT (varbinary(256), 0x01009A0FB42A86C00946DD2553B5B48C63B935F516948688B72044551C878730449515127842470AFFDA6DA4F7F0)
EXEC master..sp_addlogin 'gcservicewobo', @pwd, @sid = 0xADD6C5F9FDF2CB4EAF2275F6E603D4B8, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='gcservicewobo', @defdb='master'

-- Login: hpb\043accts
EXEC master..sp_grantlogin 'hpb\043accts'
exec sp_defaultdb @loginame='hpb\043accts', @defdb='master'

-- Login: HPB\admdjones
EXEC master..sp_grantlogin 'HPB\admdjones'
exec sp_defaultdb @loginame='HPB\admdjones', @defdb='master'
 
-- Login: hpb\Anthony_Le
EXEC master..sp_grantlogin 'hpb\Anthony_Le'
exec sp_defaultdb @loginame='hpb\Anthony_Le', @defdb='master'
 
-- Login: HPB\bcarusella
EXEC master..sp_grantlogin 'HPB\bcarusella'
exec sp_defaultdb @loginame='HPB\bcarusella', @defdb='master'
 
-- Login: HPB\bpaul
EXEC master..sp_grantlogin 'HPB\bpaul'
exec sp_defaultdb @loginame='HPB\bpaul', @defdb='master'
 
-- Login: HPB\Dale_Jones
EXEC master..sp_grantlogin 'HPB\Dale_Jones'
exec sp_defaultdb @loginame='HPB\Dale_Jones', @defdb='master'
 
-- Login: HPB\dgreen
EXEC master..sp_grantlogin 'HPB\dgreen'
exec sp_defaultdb @loginame='HPB\dgreen', @defdb='master'
 
-- Login: HPB\DIST Users
EXEC master..sp_grantlogin 'HPB\DIST Users'
exec sp_defaultdb @loginame='HPB\DIST Users', @defdb='HPB_db'
 
-- Login: HPB\Domain Users
EXEC master..sp_grantlogin 'HPB\Domain Users'
exec sp_defaultdb @loginame='HPB\Domain Users', @defdb='HPB_Receiving'
 
-- Login: hpb\drush
EXEC master..sp_grantlogin 'hpb\drush'
exec sp_defaultdb @loginame='hpb\drush', @defdb='HPB_db'
 
-- Login: HPB\HELP DESK
EXEC master..sp_grantlogin 'HPB\HELP DESK'
exec sp_defaultdb @loginame='HPB\HELP DESK', @defdb='HPB_db'
 
-- Login: HPB\iGC Users
EXEC master..sp_grantlogin 'HPB\iGC Users'
exec sp_defaultdb @loginame='BUILTIN\Administrators', @defdb='HPB_iGC'
 
-- Login: HPB\jblalock
EXEC master..sp_grantlogin 'HPB\jblalock'
exec sp_defaultdb @loginame='HPB\jblalock', @defdb='master'

-- Login: HPB\jfischer
EXEC master..sp_grantlogin 'HPB\jfischer'
 exec sp_defaultdb @loginame='HPB\jfischer', @defdb='master'

-- Login: HPB\kcarmichael
EXEC master..sp_grantlogin 'HPB\kcarmichael'
 exec sp_defaultdb @loginame='HPB\kcarmichael', @defdb='HPB_db'

-- Login: HPB\MCline
EXEC master..sp_grantlogin 'HPB\MCline'
 exec sp_defaultdb @loginame='HPB\MCline', @defdb='master'

-- Login: HPB\MIS Secure
EXEC master..sp_grantlogin 'HPB\MIS Secure'
 exec sp_defaultdb @loginame='HPB\MIS Secure', @defdb='HPB_db'

-- Login: HPB\mthomason
EXEC master..sp_grantlogin 'HPB\mthomason'
 exec sp_defaultdb @loginame='HPB\mthomason', @defdb='HPB_db'

-- Login: HPB\OFS Users
EXEC master..sp_grantlogin 'HPB\OFS Users'
 exec sp_defaultdb @loginame='HPB\OFS Users', @defdb='HPB_db'

-- Login: HPB\rfisher
EXEC master..sp_grantlogin 'HPB\rfisher'
 exec sp_defaultdb @loginame='HPB\rfisher', @defdb='master'

-- Login: hpb\rlatham
EXEC master..sp_grantlogin 'hpb\rlatham'
 exec sp_defaultdb @loginame='hpb\rlatham', @defdb='HPB_db'

-- Login: HPB\rthomas
EXEC master..sp_grantlogin 'HPB\rthomas'
 exec sp_defaultdb @loginame='HPB\rthomas', @defdb='master'

-- Login: HPB\SDADM
EXEC master..sp_grantlogin 'HPB\SDADM'
 exec sp_defaultdb @loginame='HPB\SDADM', @defdb='master'

-- Login: hpb\SQLAdmin2K
EXEC master..sp_grantlogin 'hpb\SQLAdmin2K'
 exec sp_defaultdb @loginame='hpb\SQLAdmin2K', @defdb='master'

-- Login: InvUser 
SET @pwd = CONVERT (varbinary(256), 0x01008705DB41531FEFFD69222B1B8B2622123637607B1FCFE432BF9D6CE0574C3E2CFFD0B129B8C076B84C227AA5)
EXEC master..sp_addlogin 'InvUser ', @pwd, @sid = 0x953860DCD194B14B90860AB273A978AA, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='InvUser ', @defdb='master'

-- Login: LocDistUser
SET @pwd = CONVERT (varbinary(256), 0x0100232B8110D4334774ABA1491A466274B7742BC0F6979FEAC6146405251A1A396D80C67AB71285692099BFEDEF)
EXEC master..sp_addlogin 'LocDistUser', @pwd, @sid = 0xF9AC03D257394C49AAC36B0918D6F8CC, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='LocDistUser', @defdb='master'

-- Login: MSMQcorp
SET @pwd = CONVERT (varbinary(256), 0x0100B80D1D5960AE12E204667B82861F199C3051C45A8E965097A338A43D34C277789D83B4C20B2B4A3E1B6EFFB7)
EXEC master..sp_addlogin 'MSMQcorp', @pwd, @sid = 0xF087A23978779D4DA6624073073A710A, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='MSMQcorp', @defdb='master'

 
-- Login: MSMQMaple
SET @pwd = CONVERT (varbinary(256), 0x0100903F7144219C715D78A32741A2DF8B48524D1779A4D9874AC08D08538F9783A4D9F2C4C4797507D339EDA4E9)
EXEC master..sp_addlogin 'MSMQMaple', @pwd, @sid = 0x839C57E6CB38DD4D9A814A902B6C84E8, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='MSMQMaple', @defdb='HPB_db'

-- Login: MSMQstore
SET @pwd = CONVERT (varbinary(256), 0x0100903F7144B529824D44EEF44F3C996BE50AF15BE0813C4996C370F11C83EEE68CA6190E67A8CEAD9420AE8C25)
EXEC master..sp_addlogin 'MSMQstore', @pwd, @sid = 0x11A1BC38B584904985B698A6D91016DA, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='MSMQstore', @defdb='master'

-- Login: PoSApp
SET @pwd = CONVERT (varbinary(256), 0x0100903F71446B01A98D500CC4DE9CBD2C0E1282A24CE770CF89AC29DCC85ADF30EEBF01E2B57FD278E83C86D6DE)
EXEC master..sp_addlogin 'PoSApp', @pwd, @sid = 0x186A1EABBEA37D4980B258F991FB7371, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='PoSApp', @defdb='HPB_db'

-- Login: PoSCorp
SET @pwd = CONVERT (varbinary(256), 0x0100903F71442680677533CAEAF0A11540192B798400952AF4B3DA77FBF0124789D9DA3260AB0232820C28C89B54)
EXEC master..sp_addlogin 'PoSCorp', @pwd, @sid = 0xCD8E99AD464400449E2E029E359F8147, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='PoSCorp', @defdb='HPB_db'

-- Login: ReplUser
SET @pwd = CONVERT (varbinary(256), 0x0100903F71441CD6763C472CE1651C7C3D97F5AAE1D12B1064495E830B2125D8C8BC381AE98DC688EA302EA337BF)
EXEC master..sp_addlogin 'ReplUser', @pwd, @sid = 0x4E4533DC851086428097D4B02EDC4657, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='ReplUser', @defdb='HPB_db'

-- Login: ReportReader
SET @pwd = CONVERT (varbinary(256), 0x0100903F7144B7690053390032D987125C49F3EE07C780297973D3EEF394D3DEDA9BA6337499F0D768D219F27CCE)
EXEC master..sp_addlogin 'ReportReader', @pwd, @sid = 0x9B39FC3302E49D47BED2D28F35856F5C, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='ReportReader', @defdb='HPB_db'

-- Login: ritaauthverifymailer
SET @pwd = CONVERT (varbinary(256), 0x01009979534EF43E5B69D74CD001A508E2E2A6FD9F9A33F17C55E7F4D3C6810BE9D1D7B1AC7200CA9C1CE68A103B)
EXEC master..sp_addlogin 'ritaauthverifymailer', @pwd, @sid = 0x09ADC32CD194B14EA58B5629C8258F68, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='ritaauthverifymailer', @defdb='master'

-- Login: ritasettleuser
SET @pwd = CONVERT (varbinary(256), 0x0100BA417B07034040AE18A3F942E6B4D3DFCD78DA6E93956A88C5E1367C91289F8A2E24C33564923784566344AE)
EXEC master..sp_addlogin 'ritasettleuser', @pwd, @sid = 0x2777736B4F4F2449B52A6E29AD2917F3, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='ritasettleuser', @defdb='HPB_db'

-- Login: StocUser
SET @pwd = CONVERT (varbinary(256), 0x01008072F1462094FCA8F01C58D8B5284D4886273262981E4B9EA3F4D4C76136B94B75E5822EAF9D3A33A9F52804)
EXEC master..sp_addlogin 'StocUser', @pwd, @sid = 0x5A76571D42EE554C8B1F03B7A8EAA309, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='StocUser', @defdb='master'

-- Login: StoreRepl
SET @pwd = CONVERT (varbinary(256), 0x0100903F7144EAC9C22FC0949AEBA58E20787BD91C95AE82ED6922BF68FBFBFBBAD904235DDEC2B8922B8F063F5D)
EXEC master..sp_addlogin 'StoreRepl', @pwd, @sid = 0x8F2CE8A9CEA8A9489CA817554F35077B, @encryptopt = 'skip_encryption'
 exec sp_defaultdb @loginame='StoreRepl', @defdb='master'

-- Login: UAM_Mobile
SET @pwd = CONVERT (varbinary(256), 0x01004E68390221C5C50B5DBB1959394A1CD81145E27887997DDC44CEE6E4B1E5646958A9A473CA55CB9210433863)
EXEC master..sp_addlogin 'UAM_Mobile', @pwd, @sid = 0xCDA350DFEE950F4BA32C71D71B36D70B, @encryptopt = 'skip_encryption'
exec sp_defaultdb @loginame='UAM_Mobile', @defdb='master'
