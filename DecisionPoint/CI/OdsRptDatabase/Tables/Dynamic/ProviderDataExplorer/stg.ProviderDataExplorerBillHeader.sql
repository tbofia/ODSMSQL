
IF OBJECT_ID('stg.ProviderAnalyticsBillHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderAnalyticsBillHeader
GO

IF OBJECT_ID('stg.ProviderDataExplorerBillHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerBillHeader
BEGIN
CREATE TABLE stg.ProviderDataExplorerBillHeader(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	BillIdNo INT NOT NULL,
	ClaimantHdrIdNo INT NULL,
	DateSaved DATETIME NULL,	
	ClaimDateLoss DATETIME NULL,
	CVType VARCHAR(2) NULL,
	Flags INT NULL,		
	CreateDate DATETIME NULL,
	PvdZOS VARCHAR(12) NULL,	
	TypeOfBill VARCHAR(4) NULL,	
	LastChangedOn DATETIME NULL,
	CVTypeDescription VARCHAR(100) NULL,	
	RunDate DATETIME NOT NULL DEFAULT GETDATE()		
);
END
GO



