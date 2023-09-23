IF OBJECT_ID('dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback(
	StartOfMonth datetime NULL,
	OdsCustomerId int NOT NULL,
	Customer varchar(100) NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	SOJ varchar(2) NOT NULL,
	BillType varchar(8) NOT NULL,
	CV_Type varchar(2) NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	InNetworkCharges money NULL,
	InNetworkAmountAllowed money NULL,
	Savings money NULL,
	Credits money NULL,
	NetSavings money NULL,
	BillsCount float NULL,
	BillsRePriced float NULL,
	ProviderCharges money NULL,
	BRAllowable money NULL,
	ReportTypeId INT NULL,
	RunDate datetime NOT NULL);
END
GO


IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkUniqueSubmitted_Flashback'
		AND COLUMN_NAME = 'BillsCount'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback
	ALTER COLUMN BillsCount FLOAT;

END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkUniqueSubmitted_Flashback'
		AND COLUMN_NAME = 'BillsRePriced'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback
	ALTER COLUMN BillsRePriced FLOAT;

END
GO

