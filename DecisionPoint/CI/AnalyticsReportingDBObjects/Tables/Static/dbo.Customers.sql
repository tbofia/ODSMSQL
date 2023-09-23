IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN

CREATE TABLE dbo.Customers(
	Custid INT NOT NULL,
	Name VARCHAR(100) NULL,
	Customer VARCHAR(100) NULL,
	CrossReference VARCHAR(100) NULL,
	IndustryComparisonFlag INT NULL,
	VPN BIT NULL,
	AdjusterWorkspaceServiceRequestFlag BIT NULL);
	
ALTER TABLE dbo.Customers ADD 
CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED (Custid);

END
GO
