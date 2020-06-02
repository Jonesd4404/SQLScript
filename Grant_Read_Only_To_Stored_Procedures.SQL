select 'GRANT VIEW DEFINITION ON ' + quotename(specific_schema) 
+ '.' + quotename(specific_name)
+ ' TO ' + '[HPB\TDennis]'
  from INFORMATION_SCHEMA.routines
where routine_type = 'PROCEDURE'


-- SQL above Script generates script below
/*
GRANT VIEW DEFINITION ON [dbo].[GetBadDeltasData] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateARAddress] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateARCard] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateARCustomer] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[MQ_InsertSIGCard] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateARCustomerAccount] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[MQ_Insert_RChecks] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateARData] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetUnknownItems] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[DeltaMaintenance] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateTotalsARData] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[AR_TransactionSearch] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[AR_AccountSearch] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[AR_AccountNumberName] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetAR_AccountsWithBalance] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetAR_AccountsInfo] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[AR_TotalBalance] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[CheckDuplicateUsers] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetUserInfo] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetAllChangedUsers_BACKUP] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetAllUsers] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetAllUsersForStore] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetAllChangedUsers] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateSipsItemsForDelete_V2] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GenerateStoreList] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetProductXML1_NonSips] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateSipsDeleteList_V2] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetProductXML1_Sips] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[DeleteProductXML1_NonSips] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[InsertCopyUsersLastRunDate] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetCopyUsersLastRunDate] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateCopyUsersModifyDate] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[CC_TransactionSearch] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[GetTillsForStore] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateSipsDeleteList] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[UpdateSipsItemsForDelete] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[HK_Start] TO HPB\TDennis
GRANT VIEW DEFINITION ON [dbo].[Get_PCMS_Max_User_Role] TO HPB\TDennis
*/