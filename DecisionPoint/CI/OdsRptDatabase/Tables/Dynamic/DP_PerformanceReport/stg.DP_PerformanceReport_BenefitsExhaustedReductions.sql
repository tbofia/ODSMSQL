IF OBJECT_ID('stg.DP_PerformanceReport_BenefitsExhaustedReductions', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_BenefitsExhaustedReductions
BEGIN
CREATE TABLE stg.DP_PerformanceReport_BenefitsExhaustedReductions (
	 OdsCustomerId INT NOT NULL
	,BillIDNo INT
	,line_no INT
	,line_type INT
	,EndNote INT
	,charged MONEY
	,allowed MONEY
	,BenefitsExhaustedReductions MONEY DEFAULT 0.00
	,BenefitsExhaustedReductionsFlag INT DEFAULT 0
	,LLevel INT DEFAULT 0
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	)
END
GO
