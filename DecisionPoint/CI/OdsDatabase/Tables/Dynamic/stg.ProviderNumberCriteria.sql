IF OBJECT_ID('stg.ProviderNumberCriteria', 'U') IS NOT NULL 
	DROP TABLE stg.ProviderNumberCriteria  
BEGIN
	CREATE TABLE stg.ProviderNumberCriteria
		(
		  ProviderNumberCriteriaId SMALLINT NULL,
		  ProviderNumber INT NULL,
		  Priority TINYINT NULL,
		  FeeScheduleTable CHAR (1) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

