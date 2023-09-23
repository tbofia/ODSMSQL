IF OBJECT_ID('stg.DP_PerformanceReport_Input', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_Input
BEGIN
CREATE TABLE stg.DP_PerformanceReport_Input (
	OdsCustomerId int NOT NULL,
	billIDNo int,
	line_type int,
	line_no int,
	CreateDate datetime,
	CompanyID int,
	Company varchar(100),
	OfficeID int,
	Office varchar(100),
	Coverage varchar(2),
	claimNo varchar(255),
	ClaimIDNo int,
	CmtIDNo int,
	SOJ varchar(2),
	Form_Type varchar(12),
	ProviderZipOfService varchar(12),
	TypeOfBill varchar(4),
	DiagnosisCode varchar(8),
	ProcedureCode varchar(15),
	ProviderSpecialty varchar(max),
	ProviderType varchar(10),
	ProviderType_Desc varchar(100),
	line_no_disp int,
	ref_line_no int,
	over_ride int,
	charged money,
	allowed money,
	PreApportionedAmount Decimal (19,4),
	analyzed money,
	units real,
	reporttype int,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO


