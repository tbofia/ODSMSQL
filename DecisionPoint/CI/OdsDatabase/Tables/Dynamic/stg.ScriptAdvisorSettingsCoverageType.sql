IF OBJECT_ID('stg.ScriptAdvisorSettingsCoverageType', 'U') IS NOT NULL 
	DROP TABLE stg.ScriptAdvisorSettingsCoverageType  
BEGIN
	CREATE TABLE stg.ScriptAdvisorSettingsCoverageType
		(
		  ScriptAdvisorSettingsId TINYINT NULL,
		  CoverageType VARCHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

