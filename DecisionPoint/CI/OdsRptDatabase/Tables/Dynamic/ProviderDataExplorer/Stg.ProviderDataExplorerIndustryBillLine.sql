
IF OBJECT_ID('stg.ProviderDataExplorerIndustryBillLine', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerIndustryBillLine;

BEGIN
CREATE TABLE Stg.ProviderDataExplorerIndustryBillLine(
	OdsCustomerId INT NOT NULL,
	BillId INT NOT NULL,
	LineNumber INT NOT NULL,
	OverRide SMALLINT NULL,
	DateofService DATETIME NOT NULL,
	ProcedureCode VARCHAR(13) NULL,	
	Charged MONEY NOT NULL,
	Allowed MONEY NOT NULL,	
	RefLineNo SMALLINT NULL,
	POSRevCode VARCHAR(4) NULL,
	Adjustment MONEY NULL,
	FormType VARCHAR(10) NULL,
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,
	CodeDescription VARCHAR(2500) NULL,
	Category VARCHAR(500) NULL,
	SubCategory VARCHAR(500) NULL,
	BillLineType VARCHAR(50) NOT NULL,
	BundlingFlag INT NULL,
	ExceptionFlag BIT NOT NULL DEFAULT 0,
	ExceptionComments VARCHAR(500) NULL,
	SubFormType VARCHAR(500) NULL,
	IsCodeNumeric INT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
	);

END
GO
