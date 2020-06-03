
$Running = Get-Process Mongod -ErrorAction SilentlyContinue
if (!$Running) {
$PSEmailServer = "smtp.hpb.hpbrm.com"
 Send-MailMessage -From "Dale_Jones@halfpricebooks.com" -To "MongoDBAAlerts@hpb.com " -Subject "Mongod is running on Palmetto - test email only" -Body "Mongod is running OK - Test Email Only"}