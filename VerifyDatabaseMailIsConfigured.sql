/*
To determine if Database Mail is enabled
In SQL Server Management Studio, connect to an instance of SQL Server by using a query editor window, and then execute the following code:
*/

sp_configure 'show advanced', 1; 
GO
RECONFIGURE;
GO
sp_configure;
GO

/*
In the results pane, confirm that the run_value for Database Mail XPs is set to 1.

If the run_value is not 1, Database Mail is not enabled. Database Mail is not automatically enabled to reduce the number of features available for attack by a malicious user. For more information, see Understanding Surface Area Configuration.

If you decide that it is appropriate to enable Database Mail, execute the following code:
*/
sp_configure 'Database Mail XPs', 1; 
GO
RECONFIGURE;
GO
/*
To restore the sp_configure procedure to its default state, which does not show advanced options, execute the following code:
*/
sp_configure 'show advanced', 0; 
GO
RECONFIGURE;
GO

/*
To determine if users are properly configured to send Database Mail
To send Database Mail, users must be a member of the DatabaseMailUserRole. Members of the sysadmin fixed server role and msdb db_owner role are automatically members of the DatabaseMailUserRole role. To list all other members of the DatabaseMailUserRole execute the following statement:
*/
EXEC msdb.sys.sp_helprolemember 'DatabaseMailUserRole';

/*
To add users to the DatabaseMailUserRole role, use the following statement:
*/
sp_addrolemember @rolename = 'DatabaseMailUserRole'
   ,@membername = '<database user>';
/*
To send Database Mail, users must have access to at least one Database Mail profile. To list the users (principals) and the profiles to which they have access, execute the following statement.
*/
EXEC msdb.dbo.sysmail_help_principalprofile_sp;
/*
Use the Database Mail Configuration Wizard to create profiles and grant access to profiles to users.

To confirm that the Database Mail is started
The Database Mail External Program is activated when there are e-mail messages to be processed. When there have been no messages to send for the specified time-out period, the program exits. To confirm the Database Mail activation is started, execute the following statement.
*/
EXEC msdb.dbo.sysmail_help_status_sp;
/*
If the Database Mail activation is not started, execute the following statement to start it:
*/
EXEC msdb.dbo.sysmail_start_sp;
/*
If the Database Mail external program is started, check the status of the mail queue with the following statement:
*/
EXEC msdb.dbo.sysmail_help_queue_sp @queue_type = 'mail';
/*
The mail queue should have the state of RECEIVES_OCCURRING. The status queue may vary from moment to moment. If the mail queue state is not RECEIVES_OCCURRING, try stopping the queue using sysmail_stop_sp and then starting the queue using sysmail_start_sp.

NoteNote
Use the length column in the result set of sysmail_help_queue_sp to determine the number of e-mails in the Mail queue.

To determine if problems with Database Mail affect all accounts in a profile or only some accounts
If you have determined that some but not all profiles can send mail, then you may have problems with the Database Mail accounts used by the problem profiles. To determine which accounts are successful in sending mail, execute the following statement:
*/
SELECT sent_account_id, sent_date FROM msdb.dbo.sysmail_sentitems;
/*
If a profile which is not working does not use any of the accounts listed, then it is possible that all the accounts available to the profile are not working properly. To test individual accounts, use the Database Mail Configuration Wizard to create a new profile with a single account, and then use the Send Test E-Mail dialog box to send mail using the new account.

To view the error messages returned by Database Mail, execute the following statement:
*/
SELECT * FROM msdb.dbo.sysmail_event_log;
/*
NoteNote
Database Mail considers mail to be sent, when it is successfully delivered to a SMTP mail server. Subsequent errors, such as an invalid recipient e-mail address, can still prevent mail from being delivered, but will not be contained in the Database Mail log.

To configure Database Mail to retry mail delivery
If you have determined that the Database Mail is failing because the SMTP server cannot be reliably reached, you may be able to increase your successful mail delivery rate by increasing the number of times Database Mail attempts to send each message. Start the Database Mail Configuration Wizard, and select the View or change system parameters option. Alternatively, you can associate more accounts to the profile so upon failover from the primary account, Database Mail will use the failover account to send e-mails.

On the Configure System Parameters page, the default values of 5 times for the Account Retry Attempts and 60 seconds for the Account Retry Delay means that message delivery will fail if the SMTP server cannot be reached in 5 minutes. Increase these parameters to lengthen the amount of time before message deliver fails.

NoteNote
When large numbers of messages are being sent, large default values may increase reliability, but will substantially increase the use of resources as many messages are attempted to be delivered over and over again. Address the root problem by resolving the network or SMTP server problem that prevents Database Mail from contacting the SMTP server promptly.

Security
You must be a member of the sysadmin fixed server role to troubleshoot all aspects of Database Mail. Users who are not members of the sysadmin fixed server role can only obtain information about the e-mails they attempt to send, not about e-mails sent by other users.

See Also
*/