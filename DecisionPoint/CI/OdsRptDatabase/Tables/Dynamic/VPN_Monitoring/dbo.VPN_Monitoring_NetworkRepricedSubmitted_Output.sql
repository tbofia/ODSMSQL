IF OBJECT_ID('dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output(
	StartOfMonth datetime NULL,
	OdsCustomerId int NULL,
	Customer varchar(100) NULL,
	SOJ varchar(2) NULL,
	NetworkName varchar(50) NULL,
	BillType varchar(8) NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	CV_Type varchar(2) NULL,
	Company varchar(50) NULL,
	Office varchar(40) NULL,
	BillsCount float NOT NULL,
	BillsRepriced float NOT NULL,
	ProviderCharges money NOT NULL,
	BRAllowable money NOT NULL,
	InNetworkCharges money NOT NULL,
	InNetworkAmountAllowed money NOT NULL,
	Savings money NOT NULL,
	Credits money NOT NULL,
	NetSavings money NOT NULL,
	ReportTypeId INT NULL,
	RunDate datetime NOT NULL);
END
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output')
                        AND NAME = 'LastUpdate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output.LastUpdate', 'RunDate', 'COLUMN'; 
    END;
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkRepricedSubmitted_Output'
		AND COLUMN_NAME = 'BillsCount'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	ALTER COLUMN BillsCount FLOAT;

END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkRepricedSubmitted_Output'
		AND COLUMN_NAME = 'BillsRepriced'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	ALTER COLUMN BillsRepriced FLOAT;

END
GO

