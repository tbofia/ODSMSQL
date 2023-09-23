IF OBJECT_ID('stg.DP_PerformanceReport_PostVPNReductions', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_PostVPNReductions
BEGIN
CREATE TABLE stg.DP_PerformanceReport_PostVPNReductions (
	 OdsCustomerId INT NOT NULL
	,billIDNo INT
	,line_no INT
	,line_type INT
	,charged MONEY
	,allowed MONEY
	,categoryIDNo INT
	,OVER_RIDE SMALLINT
	,IsZeroAllowedDuplicateLine BIT
	,analyzed MONEY
	,AnalystReductions MONEY DEFAULT 0.00
	,AnalystORReductions MONEY DEFAULT 0.00
	,DuplicateReductions MONEY DEFAULT 0.00
	,BenchmarkReductions MONEY DEFAULT 0.00
	,VPNReductions MONEY DEFAULT 0.00
	,FeeScheduleReductions MONEY DEFAULT 0.00
	,CTGReductions MONEY DEFAULT 0.00
	,Overrides MONEY DEFAULT 0.00
	,VPNReductionsFlag INT DEFAULT 0
	,DuplicateReductionsFlag INT DEFAULT 0
	,LLevel INT DEFAULT 0
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	)
END
GO

