IF OBJECT_ID('stg.Icd10DiagnosisVersion', 'U') IS NOT NULL
DROP TABLE stg.Icd10DiagnosisVersion
BEGIN
	CREATE TABLE stg.Icd10DiagnosisVersion (
		DiagnosisCode VARCHAR(8) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,NonSpecific BIT NULL
		,Traumatic BIT NULL
		,Duration SMALLINT NULL
		,Description VARCHAR(max) NULL
		,DiagnosisFamilyId TINYINT NULL
		,TotalCharactersRequired TINYINT NULL
		,PlaceholderRequired BIT NULL 
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
