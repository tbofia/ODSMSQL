IF OBJECT_ID('stg.StateSettingsNewJerseyPolicyPreference', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNewJerseyPolicyPreference  
BEGIN
	CREATE TABLE stg.StateSettingsNewJerseyPolicyPreference
		(
		  PolicyPreferenceId INT NULL,
		  ShareCoPayMaximum BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

