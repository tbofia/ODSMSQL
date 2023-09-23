IF OBJECT_ID('stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered', 'U') IS NOT NULL
DROP TABLE stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered
BEGIN
CREATE TABLE stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered(
	LogDate datetime NULL,
	EventId int NULL,
	BillIdNo int NULL,
	ProcessInfo smallint NULL,
	NetworkId int NULL,
	StartOfMonth datetime NULL,
	OdsCustomerId int NOT NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	SOJ varchar(2) NOT NULL,
	BillType varchar(8) NOT NULL,
	CV_Type varchar(2) NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	ProviderCharges money NOT NULL,
	BRAllowable money NOT NULL,
	NetworkName varchar(50) NULL,
	SubNetwork varchar(50) NULL)
END
GO

