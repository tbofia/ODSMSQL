IF OBJECT_ID('stg.SENTRY_CRITERIA', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_CRITERIA  
BEGIN
	CREATE TABLE stg.SENTRY_CRITERIA
		(
		  CriteriaID INT NULL,
		  ParentName VARCHAR (50) NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (150) NULL,
		  Operators VARCHAR (50) NULL,
		  PredefinedValues VARCHAR (MAX) NULL,
		  ValueDataType VARCHAR (50) NULL,
		  ValueFormat VARCHAR (250) NULL,
		  NullAllowed SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

