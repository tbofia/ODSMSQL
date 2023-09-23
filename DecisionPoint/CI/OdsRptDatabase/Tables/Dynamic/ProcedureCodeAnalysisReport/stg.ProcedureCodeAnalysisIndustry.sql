IF OBJECT_ID('stg.ProcedureCodeAnalysisIndustry', 'U') IS NOT NULL
DROP TABLE stg.ProcedureCodeAnalysisIndustry; 
BEGIN
CREATE TABLE stg.ProcedureCodeAnalysisIndustry(
	ReportName varchar(13) NOT NULL,
	CoverageType varchar(20) NULL,
	FormType varchar(20) NULL,
	State varchar(20) NULL,
	County varchar(50) NULL,
	Company varchar(100) NULL,
	Office varchar(100) NULL,
	Year int NULL,
	Quarter int NULL,
	ProcedureCode varchar(50) NULL,
	IndTotalClaims int NULL,
	IndTotalClaimants int NULL,
	IndTotalCharged money NULL,
	IndTotalAllowed money NULL,
	IndTotalReductions money NULL,
	IndTotalBills int NULL,
	IndTotalUnits numeric(9, 2) NULL,
	IndTotalLines int NULL
);
END 
GO

