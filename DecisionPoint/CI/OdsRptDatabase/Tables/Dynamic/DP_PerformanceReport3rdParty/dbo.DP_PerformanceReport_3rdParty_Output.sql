IF OBJECT_ID('dbo.DP_PerformanceReport_3rdParty_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.DP_PerformanceReport_3rdParty_Output(
	OdsCustomerId int NOT NULL,
	StartOfMonth datetime NOT NULL,
	Customer varchar(100) NOT NULL,
	Year int NULL,
	Month int NULL,
	Company varchar(100) NULL,
	Office varchar(100) NULL,
	SOJ varchar(2) NULL,
	Coverage varchar(2) NULL,
	Form_Type varchar(12) NULL,
	ClaimIDNo int NULL,
	CmtIDNo int NULL,
	Total_Claims int NULL,
	Total_Claimants int NULL,
	Total_Bills int NULL,
	Total_Lines int NULL,
	Total_Units float NULL,
	Total_Provider_Charges money NULL,
	Total_Final_Allowed money NULL,
	Total_Reductions money NULL,
	Total_BillAdjustments money NULL,
	Standard money NULL,
	Premium money NULL,
	FeeSchedule money NULL,
	Benchmark money NULL,
	VPN money NULL,
	Override money NULL,
	ReportTypeID int NOT NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO
