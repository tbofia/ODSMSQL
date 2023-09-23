
IF OBJECT_ID('stg.ProviderAnalyticsBillLine', 'U') IS NOT NULL
DROP TABLE stg.ProviderAnalyticsBillLine

GO

IF OBJECT_ID('stg.ProviderDataExplorerBillLine', 'U') IS NOT NULL
		DROP TABLE stg.ProviderDataExplorerBillLine
BEGIN
CREATE TABLE stg.ProviderDataExplorerBillLine(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	BillIdNo INT NOT NULL,
	LineNumber SMALLINT NOT NULL,	
	OverRide SMALLINT NULL,
	DTSVC DATETIME NOT NULL,
	PRCCD VARCHAR(13) NULL,
	Units REAL NOT NULL,
	Charged MONEY NOT NULL,
	Allowed MONEY NOT NULL,
	Analyzed MONEY NULL,
	RefLineNo SMALLINT NULL,	
	POSRevCode VARCHAR(4) NULL,
	Adjustment MONEY NULL, 
	FormType VARCHAR(10) NULL,
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,
	ProviderZipOfService VARCHAR(20) NULL,
	BillLineType VARCHAR(50) NOT NULL,
	ExceptionFlag BIT NOT NULL DEFAULT 0,
	ExceptionComments VARCHAR(500) NULL,
	BundlingFlag INT NULL,
	CodeDescription	VARCHAR	(2500) NULL,
	CodeCategory	VARCHAR	(1500) NULL,
	CodeSubCategory	VARCHAR	(1500) NULL,
	IsCodeNumeric BIT NULL,
	SubFormType VARCHAR(500) NULL,
	BillInjuryDescription VARCHAR(100) NULL,
	Modifier VARCHAR(20) NULL,
	EndNote VARCHAR(MAX) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()

	);
END
GO
