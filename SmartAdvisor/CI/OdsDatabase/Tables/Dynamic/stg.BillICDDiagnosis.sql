IF OBJECT_ID('stg.BillICDDiagnosis', 'U') IS NOT NULL 
	DROP TABLE stg.BillICDDiagnosis  
BEGIN
	CREATE TABLE stg.BillICDDiagnosis
		(
		  ClientCode CHAR (4) NULL,
		  BillSeq INT NULL,
		  BillDiagnosisSeq SMALLINT NULL,
		  ICDDiagnosisID INT NULL,
		  POA CHAR (1) NULL,
		  BilledICDDiagnosis CHAR (8) NULL,
		  ICDBillUsageTypeID SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

