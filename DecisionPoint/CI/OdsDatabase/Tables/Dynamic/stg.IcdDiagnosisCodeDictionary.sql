IF OBJECT_ID('stg.IcdDiagnosisCodeDictionary', 'U') IS NOT NULL
DROP TABLE stg.IcdDiagnosisCodeDictionary
BEGIN
	CREATE TABLE stg.IcdDiagnosisCodeDictionary (
	   DiagnosisCode VARCHAR(8) NULL
	   ,IcdVersion TINYINT NULL
	   ,StartDate DATETIME2(7) NULL
	   ,EndDate DATETIME2(7) NULL
	   ,NonSpecific BIT NULL
	   ,Traumatic BIT NULL
	   ,Duration TINYINT NULL
	   ,[Description] VARCHAR(max) NULL
	   ,DiagnosisFamilyId TINYINT NULL
	   ,DiagnosisSeverityId TINYINT NULL
	   ,LateralityId TINYINT NULL
	   ,TotalCharactersRequired TINYINT NULL
	   ,PlaceholderRequired BIT NULL
	   ,Flags SMALLINT NULL
	   ,AdditionalDigits BIT NULL
	   ,Colossus SMALLINT NULL
	   ,InjuryNatureId TINYINT NULL
	   ,EncounterSubcategoryId TINYINT NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO





