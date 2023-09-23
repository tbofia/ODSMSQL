IF OBJECT_ID('dbo.PPO_ActivityReport_MasterCoverage_Flashback', 'U') IS NULL
BEGIN
CREATE TABLE dbo.PPO_ActivityReport_MasterCoverage_Flashback(
	OdsCustomerId int NOT NULL,
	StartOfMonth datetime NOT NULL,
	Customer varchar(100) NOT NULL,
	Year int NOT NULL,
	Month int NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	SOJ varchar(2) NOT NULL,
	Coverage varchar(2) NOT NULL,
	Form_Type varchar(8) NOT NULL,
	Total_Bills float NULL,
	Total_Provider_Charges money NULL,
	Total_Bill_Review_Reductions money NULL,
	ReportTypeID int NOT NULL,
	RunDate datetime NOT NULL
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PPO_ActivityReport_MasterCoverage_Flashback'
		AND COLUMN_NAME = 'Total_Bills'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.PPO_ActivityReport_MasterCoverage_Flashback
	ALTER COLUMN Total_Bills FLOAT;

END



