IF OBJECT_ID('stg.DeductibleRuleExemptEndnote', 'U') IS NOT NULL 
	DROP TABLE stg.DeductibleRuleExemptEndnote  
BEGIN
	CREATE TABLE stg.DeductibleRuleExemptEndnote
		(
		  Endnote INT NULL,
		  EndnoteTypeId TINYINT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

