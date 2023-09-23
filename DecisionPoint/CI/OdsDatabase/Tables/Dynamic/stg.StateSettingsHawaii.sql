IF OBJECT_ID('stg.StateSettingsHawaii', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsHawaii  
BEGIN
	CREATE TABLE stg.StateSettingsHawaii
		(
		  StateSettingsHawaiiId INT NULL,
		  PhysicalMedicineLimitOption SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

