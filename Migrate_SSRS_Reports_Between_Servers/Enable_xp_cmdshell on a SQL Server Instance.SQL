-- Allow advanced options to be changed. 
EXEC sp_configure 'show advanced options', 1 
GO 
  
-- Update the currently configured value for advanced options. 
RECONFIGURE 
GO 
  
-- Enable xp_cmdshell 
EXEC sp_configure 'xp_cmdshell', 1 
GO 
  
-- Update the currently configured value for xp_cmdshell 
RECONFIGURE 
GO 
  
-- Disallow further advanced options to be changed. 
EXEC sp_configure 'show advanced options', 0 
GO 
  
-- Update the currently configured value for advanced options. 
RECONFIGURE 
GO