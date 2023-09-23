
IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('dbo.LossYearReport')
			AND NAME = 'PK_LossYearReport'
		)
CREATE CLUSTERED INDEX PK_LossYearReport 
ON dbo.LossYearReport(CustomerName,ReportName,OdsCustomerId) 
WITH (DATA_COMPRESSION = PAGE) ON rpt_PartitionScheme(OdsCustomerId);
GO
