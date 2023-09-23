IF OBJECT_ID('dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output(
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

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output')
                        AND NAME = 'LastUpdate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output.LastUpdate', 'RunDate', 'COLUMN'; 
    END;
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkUniqueSubmitted_Output'
		AND COLUMN_NAME = 'BillsCount'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
	ALTER COLUMN BillsCount FLOAT;

END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkUniqueSubmitted_Output'
		AND COLUMN_NAME = 'BillsRePriced'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
	ALTER COLUMN BillsRePriced FLOAT;

END
GO
