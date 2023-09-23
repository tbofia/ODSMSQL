IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('stg.DP_PerformanceReport_Input')
			AND NAME = 'ncidx_BillsBillsPharm'
		)
CREATE NONCLUSTERED INDEX ncidx_BillsBillsPharm 
ON stg.DP_PerformanceReport_Input (line_type) 
INCLUDE (billIDNo, line_no,OdsCustomerId)
GO

IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('stg.DP_PerformanceReport_Input')
			AND NAME = 'Idx_CustomerIdBillIdNoLineNoLineType'
		)
CREATE NONCLUSTERED INDEX Idx_CustomerIdBillIdNoLineNoLineType 
ON stg.DP_PerformanceReport_Input (OdsCustomerId, billIDNo, line_no, line_type)
GO

IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('stg.DP_PerformanceReport_Input')
			AND NAME = 'ncidx_over_ride'
		)
CREATE NONCLUSTERED INDEX ncidx_over_ride 
ON stg.DP_PerformanceReport_Input (over_ride) 
INCLUDE (billIDNo, charged, line_no, line_type,OdsCustomerId)
GO

IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('stg.DP_PerformanceReport_Input')
			AND NAME = 'ncidx_ProviderZipOfService'
		)
CREATE NONCLUSTERED INDEX ncidx_ProviderZipOfService
ON stg.DP_PerformanceReport_Input (OdsCustomerId,ProviderZipOfService) 
GO

IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('stg.DP_PerformanceReport_Input')
			AND NAME = 'ncidx_Allowed'
		)
CREATE NONCLUSTERED INDEX ncidx_Allowed 
ON stg.DP_PerformanceReport_Input (Allowed,OdsCustomerId) 
GO

