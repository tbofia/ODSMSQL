IF OBJECT_ID('stg.SENTRY_ACTION', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_ACTION  
BEGIN
	CREATE TABLE stg.SENTRY_ACTION
		(
		  ActionID INT NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (100) NULL,
		  CompatibilityKey VARCHAR (50) NULL,
		  PredefinedValues VARCHAR (MAX) NULL,
		  ValueDataType VARCHAR (50) NULL,
		  ValueFormat VARCHAR (250) NULL,
		  BillLineAction INT NULL,
		  AnalyzeFlag SMALLINT NULL,
		  ActionCategoryIDNo INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

