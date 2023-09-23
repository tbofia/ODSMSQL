IF OBJECT_ID('stg.PPO_ActivityReport_MasterCoverage_Input', 'U') IS NOT NULL
DROP TABLE stg.PPO_ActivityReport_MasterCoverage_Input
BEGIN

CREATE TABLE stg.PPO_ActivityReport_MasterCoverage_Input(
	OdsCustomerId int NOT NULL,
	BillIDNo int NOT NULL,
	CreateDate datetime NULL,
	Form_Type varchar(8) NOT NULL,
	TypeOfBill varchar(4) NULL,
	CompanyID int NULL,
	Company varchar(50) NOT NULL,
	OfficeID int NULL,
	Office varchar(40) NOT NULL,
	Coverage varchar(2) NULL,
	SOJ varchar(2) NULL,
	LINE_NO_DISP smallint NULL,
	LINE_NO smallint NOT NULL,
	REF_LINE_NO int NULL,
	LineType int NOT NULL,
	OVER_RIDE smallint NULL,
	CHARGED money NOT NULL,
	ALLOWED money NOT NULL,
	PreApportionedAmount decimal(19, 4) NULL,
	ANALYZED money NOT NULL,
	UNITS real NOT NULL,
	ReportTypeId int NOT NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO

