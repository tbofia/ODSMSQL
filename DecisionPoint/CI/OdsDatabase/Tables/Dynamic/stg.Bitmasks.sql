IF OBJECT_ID('stg.Bitmasks', 'U') IS NOT NULL
DROP TABLE stg.Bitmasks
BEGIN
	CREATE TABLE stg.Bitmasks (
		TableProgramUsed VARCHAR(50) NULL
		,AttributeUsed VARCHAR(50) NULL
		,DECIMAL BIGINT NULL
		,ConstantName VARCHAR(50) NULL
		,BIT VARCHAR(50) NULL
		,Hex VARCHAR(20) NULL
		,Description VARCHAR(250) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
