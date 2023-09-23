IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('stg.DP_PerformanceReport_MaxPrePPOBillInfo')
			AND NAME = 'IX_MaxPrePPOBillInfo_OdsCustomerId'
		)
CREATE NONCLUSTERED INDEX IX_MaxPrePPOBillInfo_OdsCustomerId 
ON stg.DP_PerformanceReport_MaxPrePPOBillInfo (OdsCustomerId, billIDNo, line_no, line_type)
GO
