IF NOT EXISTS (
SELECT *
FROM sys.indexes
WHERE NAME = 'idx_yearquarter'
	AND Object_id = Object_id('dbo.ProcedureCodeAnalysis_Output')
)
CREATE NONCLUSTERED INDEX idx_yearquarter 
ON dbo.ProcedureCodeAnalysis_Output (DateQuarter,YEAR,Quarter)

GO

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_InsurerName'
			AND Object_id = Object_id('dbo.ProcedureCodeAnalysis_Output')
		)
CREATE NONCLUSTERED INDEX idx_InsurerName 
ON dbo.ProcedureCodeAnalysis_Output (DisplayName);
GO


