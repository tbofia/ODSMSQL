IF OBJECT_ID('stg.IcdDiagnosisCodeDictionaryBodyPart', 'U') IS NOT NULL 
	DROP TABLE stg.IcdDiagnosisCodeDictionaryBodyPart  
BEGIN
	CREATE TABLE stg.IcdDiagnosisCodeDictionaryBodyPart
		(
		  DiagnosisCode VARCHAR (8) NULL,
		  IcdVersion TINYINT NULL,
		  StartDate DATETIME2 (7) NULL,
		  NcciBodyPartId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

