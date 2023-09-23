IF OBJECT_ID('dbo.AdjustorWorkspaceDemandPackage_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.AdjustorWorkspaceDemandPackage_Output(
	OdsCustomerId INT,
	Customer nvarchar(200) NULL,
	Company varchar(50) NULL,
	Office varchar(40) NULL,
	SOJ varchar(2) NULL,
	RequestedByUserName varchar(50) NULL,
	DateTimeReceived date NULL,
	DemandClaimantId int NULL,
	DemandPackageId int NULL,
	PageCount int NULL,
	Size int NULL,
	FileCount int NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END
GO

