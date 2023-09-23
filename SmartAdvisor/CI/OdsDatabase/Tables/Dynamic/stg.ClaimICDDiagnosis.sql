IF OBJECT_ID('stg.ClaimICDDiagnosis', 'U') IS NOT NULL 
	DROP TABLE stg.ClaimICDDiagnosis  
BEGIN
	CREATE TABLE stg.ClaimICDDiagnosis
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  ClaimSeq INT NULL,
		  ClaimDiagnosisSeq SMALLINT NULL,
		  ICDDiagnosisID INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

