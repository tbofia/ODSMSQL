IF OBJECT_ID('stg.StateSettingsNewJersey', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNewJersey  
BEGIN
	CREATE TABLE stg.StateSettingsNewJersey
		(
		  StateSettingsNewJerseyId INT NULL,
		  ByPassEmergencyServices BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

