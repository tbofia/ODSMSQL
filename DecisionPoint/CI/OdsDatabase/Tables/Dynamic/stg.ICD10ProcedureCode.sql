IF OBJECT_ID('stg.ICD10ProcedureCode', 'U') IS NOT NULL
DROP TABLE stg.ICD10ProcedureCode
BEGIN
	CREATE TABLE stg.ICD10ProcedureCode (
		ICDProcedureCode VARCHAR(7) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,Description VARCHAR(300) NULL
		,PASGrpNo SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO   
