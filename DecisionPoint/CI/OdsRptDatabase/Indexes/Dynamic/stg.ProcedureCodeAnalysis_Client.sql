IF NOT EXISTS (
SELECT *
FROM sys.indexes
WHERE NAME = 'IX_ProcedureCodeAnalysisClient'
	AND Object_id = Object_id('stg.ProcedureCodeAnalysisClient')
)
CREATE NONCLUSTERED INDEX IX_ProcedureCodeAnalysisClient
ON stg.ProcedureCodeAnalysisClient (OdsCustomerID,ReportName,CoverageType,FormType,STATE,County,Company,Office,Year,Quarter,ProcedureCode)
INCLUDE (TotalClaims,TotalClaimants,TotalCharged,TotalAllowed,TotalReductions,TotalBills,TotalUnits,TotalLines)
GO

