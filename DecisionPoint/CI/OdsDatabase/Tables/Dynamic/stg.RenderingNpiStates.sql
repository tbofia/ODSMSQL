IF OBJECT_ID('stg.RenderingNpiStates', 'U') IS NOT NULL 
	DROP TABLE stg.RenderingNpiStates  
BEGIN
	CREATE TABLE stg.RenderingNpiStates
		(
		  ApplicationSettingsId INT NULL,
		  State VARCHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

