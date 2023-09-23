IF OBJECT_ID('stg.StateSettingsNewYorkPolicyPreference', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNewYorkPolicyPreference  
BEGIN
	CREATE TABLE stg.StateSettingsNewYorkPolicyPreference
		(
		  PolicyPreferenceId INT NULL,
		  ShareCoPayMaximum BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

