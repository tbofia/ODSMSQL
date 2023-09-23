IF NOT EXISTS (
SELECT *
FROM sys.indexes
WHERE NAME = 'IX_ProcedureCodeAnalysisIndustry'
	AND Object_id = Object_id('stg.ProcedureCodeAnalysisIndustry')
)
CREATE NONCLUSTERED INDEX IX_ProcedureCodeAnalysisIndustry
ON stg.ProcedureCodeAnalysisIndustry (ReportName,CoverageType,FormType,State,County,Company,Office,Year,Quarter,ProcedureCode)
INCLUDE (IndTotalClaims,IndTotalClaimants,IndTotalCharged,IndTotalAllowed,IndTotalReductions,IndTotalBills,IndTotalUnits,IndTotalLines)
GO
