IF OBJECT_ID('stg.BillsProviderNetwork', 'U') IS NOT NULL
DROP TABLE stg.BillsProviderNetwork
BEGIN
	CREATE TABLE stg.BillsProviderNetwork (
		BillIdNo INT NULL
		,NetworkId INT NULL
		,NetworkName VARCHAR(50) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
