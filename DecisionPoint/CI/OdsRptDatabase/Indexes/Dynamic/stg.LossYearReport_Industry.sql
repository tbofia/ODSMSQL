IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_RollUpColumns'
			AND Object_id = OBJECT_ID('stg.LossYearReport_Industry')
		)
CREATE NONCLUSTERED INDEX IX_RollUpColumns 
ON stg.LossYearReport_Industry(ReportID, SOJ, AgeGroup, DateQuarter, FormType,  CoverageType,  ServiceGroup)

GO



