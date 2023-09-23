IF OBJECT_ID('stg.VPN_Monitoring_NetworkSubmitted', 'U') IS NOT NULL
DROP TABLE stg.VPN_Monitoring_NetworkSubmitted
BEGIN
CREATE TABLE stg.VPN_Monitoring_NetworkSubmitted(
	StartOfMonth datetime NULL,
	OdsCustomerId int NOT NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	SOJ varchar(2) NOT NULL,
	NetworkName varchar(50) NULL,
	BillType varchar(8) NOT NULL,
	CV_Type varchar(2) NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	BillsCount int NULL,
	BillsCount_Weekend int NULL,
	BillsCount_WeekDay int NULL,
	BillsRePriced int NULL,
	BillsRePriced_Weekend int NULL,
	BillsRePriced_WeekDay int NULL,
	ProviderCharges money NULL,
	ProviderCharges_Weekend money NULL,
	ProviderCharges_WeekDay money NULL,
	BRAllowable money NULL,
	BRAllowable_Weekend money NULL,
	BRAllowable_WeekDay money NULL) 
END
GO
