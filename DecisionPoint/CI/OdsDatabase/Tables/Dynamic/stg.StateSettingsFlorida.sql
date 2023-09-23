IF OBJECT_ID('stg.StateSettingsFlorida', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsFlorida  
BEGIN
	CREATE TABLE stg.StateSettingsFlorida
		(
		  StateSettingsFloridaId INT NULL,
		  ClaimantInitialServiceOption SMALLINT NULL,
		  ClaimantInitialServiceDays SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

