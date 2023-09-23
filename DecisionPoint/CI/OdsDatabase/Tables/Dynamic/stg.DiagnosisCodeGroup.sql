IF OBJECT_ID('stg.DiagnosisCodeGroup', 'U') IS NOT NULL
DROP TABLE stg.DiagnosisCodeGroup
BEGIN
	CREATE TABLE stg.DiagnosisCodeGroup (
		DiagnosisCode VARCHAR(8) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,MajorCategory VARCHAR(500) NULL
		,MinorCategory VARCHAR(500) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
