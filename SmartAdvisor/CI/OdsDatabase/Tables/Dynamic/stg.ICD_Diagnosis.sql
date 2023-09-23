IF OBJECT_ID('stg.ICD_Diagnosis', 'U') IS NOT NULL 
	DROP TABLE stg.ICD_Diagnosis  
BEGIN
	CREATE TABLE stg.ICD_Diagnosis
		(
		  ICDDiagnosisID INT NULL,
		  Code CHAR (8) NULL,
		  ShortDesc VARCHAR (60) NULL,
		  Description VARCHAR (300) NULL,
		  Detailed BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

