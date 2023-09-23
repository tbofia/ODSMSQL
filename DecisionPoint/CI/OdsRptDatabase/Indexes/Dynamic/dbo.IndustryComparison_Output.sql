IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_yearquarter'
			AND OBJECT_NAME(Object_id) = 'IndustryComparison_Output'
		)
CREATE NONCLUSTERED INDEX idx_yearquarter 
ON dbo.IndustryComparison_Output(DateQuarter,YEAR,Quarter);
GO
		
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'idx_DisplayName'
			AND OBJECT_NAME(Object_id) = 'IndustryComparison_Output'
		)
CREATE NONCLUSTERED INDEX idx_DisplayName 
ON dbo.IndustryComparison_Output(DisplayName);
GO
