IF OBJECT_ID('stg.RuleType', 'U') IS NOT NULL 
	DROP TABLE stg.RuleType  
BEGIN
	CREATE TABLE stg.RuleType
		(
		  RuleTypeID INT NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (150) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

