IF OBJECT_ID('rpt.CustomerBillExclnListThreshold', 'U') IS NULL
BEGIN
CREATE TABLE rpt.CustomerBillExclnListThreshold(
	CustomerId int NULL,
	CustomerName varchar(250) NULL,
	CustomerDatabase varchar(250) NULL,
	BillIdNo int NULL,
	BillCreateDateYear int NULL,
	Charged money NULL,
	Allowed money NULL,
	Rundate datetime NULL
);
END
GO

