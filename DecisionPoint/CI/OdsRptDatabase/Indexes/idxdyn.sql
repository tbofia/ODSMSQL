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
IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_RollUpColumns'
			AND Object_id = OBJECT_ID('stg.LossYearReport_Client')
		)
CREATE NONCLUSTERED INDEX IX_RollUpColumns 
ON stg.LossYearReport_Client(OdsCustomerID,ReportID, SOJ, DateQuarter)
GO

IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_RollUpColumns'
			AND Object_id = OBJECT_ID('stg.LossYearReport_Industry')
		)
CREATE NONCLUSTERED INDEX IX_RollUpColumns 
ON stg.LossYearReport_Industry(ReportID, SOJ, AgeGroup, DateQuarter, FormType,  CoverageType,  ServiceGroup)

GO



IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_RollUpColumns'
			AND Object_id = Object_id('stg.LossYearReport_Filtered')
		)
CREATE NONCLUSTERED INDEX IX_RollUpColumns 
ON stg.LossYearReport_Filtered(OdsCustomerId, CmtIDNo, CompanyName, SOJ, DateQuarter)
GO

IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID('stg.DP_PerformanceReport_MaxPrePPOBillInfo')
			AND NAME = 'IX_MaxPrePPOBillInfo_OdsCustomerId'
		)
CREATE NONCLUSTERED INDEX IX_MaxPrePPOBillInfo_OdsCustomerId 
ON stg.DP_PerformanceReport_MaxPrePPOBillInfo (OdsCustomerId, billIDNo, line_no, line_type)
GO
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
