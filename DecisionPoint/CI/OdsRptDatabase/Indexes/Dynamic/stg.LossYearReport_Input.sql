IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('stg.LossYearReport_Input')
			AND NAME = 'IX_OdsCustomerId_BillIDNo_Outlier_ALLOWED'
		)
CREATE CLUSTERED INDEX IX_OdsCustomerId_BillIDNo_Outlier_ALLOWED
ON stg.LossYearReport_Input (OdsCustomerId,BillIDNo,Outlier,ALLOWED) 
WITH (DATA_COMPRESSION = PAGE) ON rpt_PartitionScheme(OdsCustomerId);
GO

