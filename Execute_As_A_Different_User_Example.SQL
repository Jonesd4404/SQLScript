EXECUTE AS LOGIN = 'HPB\jblalock';  
--Verify the execution context is now login1.  
SELECT SUSER_NAME(), USER_NAME();  


--Execute as a different login, then revert back to original login
--Display current execution context.  
EXECUTE AS LOGIN = 'HPB\jblalock'; 
SELECT SUSER_NAME(), USER_NAME();  
REVERT;  
--Display current execution context.  Should show the original user
SELECT SUSER_NAME(), USER_NAME(); 