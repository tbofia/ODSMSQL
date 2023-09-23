IF OBJECT_ID('stg.DP_PerformanceReport_3rdParty_Adjustments', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_3rdParty_Adjustments
BEGIN
CREATE TABLE stg.DP_PerformanceReport_3rdParty_Adjustments(
	OdsCustomerId INT NOT NULL,
	billIDNo INT NULL,
	line_no INT NULL,
	line_type INT NULL,
	Standard MONEY NULL,
	Premium MONEY NULL,
	FeeSchedule MONEY NULL,
	Benchmark MONEY NULL,
	VPN money NULL,
	Override MONEY NULL,
	ReportType INT NOT NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO

