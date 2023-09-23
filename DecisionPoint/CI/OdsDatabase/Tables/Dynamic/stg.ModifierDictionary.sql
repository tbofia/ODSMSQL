IF OBJECT_ID('stg.ModifierDictionary', 'U') IS NOT NULL 
	DROP TABLE stg.ModifierDictionary  
BEGIN
	CREATE TABLE stg.ModifierDictionary
		(
		  ModifierDictionaryId INT NULL,
		  Modifier VARCHAR (2) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  Description VARCHAR (100) NULL,
		  Global BIT NULL,
		  AnesMedDirect BIT NULL,
		  AffectsPricing BIT NULL,
		  IsCoSurgeon BIT NULL,
		  IsAssistantSurgery BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

