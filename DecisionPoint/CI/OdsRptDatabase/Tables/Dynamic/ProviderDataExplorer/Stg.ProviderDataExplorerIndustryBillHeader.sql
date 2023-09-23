
IF OBJECT_ID('stg.ProviderDataExplorerIndustryBillHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerIndustryBillHeader;

BEGIN
CREATE TABLE Stg.ProviderDataExplorerIndustryBillHeader(
	OdsCustomerId INT NOT NULL,
	BillId INT NOT NULL,
	ClaimantHeaderId INT NULL,
	CVType VARCHAR(2) NULL,
	CVTypeDescription VARCHAR(100) NULL,
	Flags INT NULL,	
	TypeofBill VARCHAR(4) NULL,		
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
	);

END
GO
