IF OBJECT_ID('stg.UB_BillType', 'U') IS NOT NULL
DROP TABLE stg.UB_BillType
BEGIN
	CREATE TABLE stg.UB_BillType (
		TOB VARCHAR(4) NULL
		,Description VARCHAR(max) NULL
		,Flag INT NULL
		,UB_BillTypeID INT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
   
