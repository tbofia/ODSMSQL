IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_RollUpColumns'
			AND Object_id = Object_id('stg.LossYearReport_Filtered')
		)
CREATE NONCLUSTERED INDEX IX_RollUpColumns 
ON stg.LossYearReport_Filtered(OdsCustomerId, CmtIDNo, CompanyName, SOJ, DateQuarter)
GO

