IF OBJECT_ID('stg.VPNBillableFlags', 'U') IS NOT NULL
DROP TABLE stg.VPNBillableFlags
BEGIN
	CREATE TABLE stg.VPNBillableFlags(
		SOJ nchar(2) NULL,
		NetworkID int NULL,
		ActivityFlag nchar(2) NULL,
		Billable nchar(1) NULL,
		CompanyCode varchar(10) NULL,
		CompanyName varchar(100) NULL,
		DmlOperation CHAR(1) NOT NULL 
	)
END
GO

