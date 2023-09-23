IF OBJECT_ID('dbo.SelfServePerformanceReport_Savings', 'U') IS NULL
BEGIN

CREATE TABLE dbo.SelfServePerformanceReport_Savings(
	OdsCustomerId INT NULL,
	CustomerName VARCHAR(100) NULL,
	Company VARCHAR(100) NULL,
	Office VARCHAR(100) NULL,
	SOJ VARCHAR(2) NULL,
	ClaimCoverageType VARCHAR(5) NULL,
	BillCoverageType VARCHAR(5) NULL,
	FormType VARCHAR(12) NULL,
	ClaimID VARCHAR(255) NULL,
	ClaimantID INT NULL,
	ProviderTIN VARCHAR(15) NULL,
	BillID INT NULL,
	BillCreateDate DATETIME NULL,
	BillCommitDate DATETIME NULL,
	MitchellCompleteDate DATETIME NULL,
	ClaimCreateDate DATETIME NULL,
	ClaimDateofLoss DATETIME NULL,
	ExpectedRecoveryDate DATETIME NULL,
	BillLine INT NULL,
	ProcedureCode VARCHAR(15) NULL,
	ProcedureCodeDescription VARCHAR(max) NULL,
	ProcedureCodeMajorGroup VARCHAR(100) NULL,
	BodyPart VARCHAR(100) NULL,
	ReductionType VARCHAR(100) NULL,
	AdjSubCatName VARCHAR(50) NULL,
	DuplicateBillFlag SMALLINT NULL,
	DuplicateLineFlag SMALLINT NULL,
	Adjustment MONEY NULL,
	ProviderCharges MONEY NULL,
	TotalAllowed MONEY NULL,
	TotalUnits REAL NULL,
	ExpectedRecoveryDuration INT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
) 

END
GO


