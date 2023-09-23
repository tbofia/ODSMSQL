IF OBJECT_ID('stg.CustomBillStatuses', 'U') IS NOT NULL
DROP TABLE stg.CustomBillStatuses
BEGIN
	CREATE TABLE stg.CustomBillStatuses (
		StatusId INT NULL,
		StatusName VARCHAR(50) NULL,
		StatusDescription VARCHAR(300) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
