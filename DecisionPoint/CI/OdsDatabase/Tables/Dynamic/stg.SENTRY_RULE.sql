IF OBJECT_ID('stg.SENTRY_RULE', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_RULE  
BEGIN
	CREATE TABLE stg.SENTRY_RULE
		(
		  RuleID INT NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (MAX) NULL,
		  CreatedBy VARCHAR (50) NULL,
		  CreationDate DATETIME NULL,
		  PostFixNotation VARCHAR (MAX) NULL,
		  Priority INT NULL,
		  RuleTypeID SMALLINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

