IF OBJECT_ID('stg.ScriptAdvisorSettings', 'U') IS NOT NULL 
	DROP TABLE stg.ScriptAdvisorSettings  
BEGIN
	CREATE TABLE stg.ScriptAdvisorSettings
		(
		  ScriptAdvisorSettingsId TINYINT NULL,
		  IsPharmacyEligible BIT NULL,
		  EnableSendCardToClaimant BIT NULL,
		  EnableBillSource BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

