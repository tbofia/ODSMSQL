IF OBJECT_ID('stg.ProcedureCodeGroup', 'U') IS NOT NULL
DROP TABLE stg.ProcedureCodeGroup
BEGIN
	CREATE TABLE stg.ProcedureCodeGroup (
		ProcedureCode VARCHAR(7) NULL
		,MajorCategory VARCHAR(500) NULL
		,MinorCategory VARCHAR(500) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
