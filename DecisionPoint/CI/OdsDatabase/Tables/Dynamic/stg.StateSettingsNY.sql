IF OBJECT_ID('stg.StateSettingsNY', 'U') IS NOT NULL 
	DROP TABLE stg.StateSettingsNY  
BEGIN
	CREATE TABLE stg.StateSettingsNY
		(
		  StateSettingsNYID INT NULL,
		  NF10PrintDate BIT NULL,
		  NF10CheckBox1 BIT NULL,
		  NF10CheckBox18 BIT NULL,
		  NF10UseUnderwritingCompany BIT NULL,
		  UnderwritingCompanyUdfId INT NULL,
		  NaicUdfId INT NULL,
		  DisplayNYPrintOptionsWhenZosOrSojIsNY BIT NULL,
		  NF10DuplicatePrint BIT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

