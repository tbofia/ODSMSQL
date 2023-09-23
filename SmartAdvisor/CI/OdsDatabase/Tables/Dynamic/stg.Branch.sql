IF OBJECT_ID('stg.Branch', 'U') IS NOT NULL 
	DROP TABLE stg.Branch  
BEGIN
	CREATE TABLE stg.Branch
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  BranchSeq INT NULL,
		  Name VARCHAR (60) NULL,
		  ExternalID VARCHAR (20) NULL,
		  BranchID VARCHAR (20) NULL,
		  LocationCode VARCHAR (10) NULL,
		  AdminKey VARCHAR (40) NULL,
		  Address1 VARCHAR (30) NULL,
		  Address2 VARCHAR (30) NULL,
		  City VARCHAR (20) NULL,
		  State CHAR (2) NULL,
		  Zip VARCHAR (9) NULL,
		  PhoneNum VARCHAR (20) NULL,
		  FaxNum VARCHAR (20) NULL,
		  ContactName VARCHAR (30) NULL,
		  TIN VARCHAR (9) NULL,
		  StateTaxID VARCHAR (30) NULL,
		  DIRNum VARCHAR (20) NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  RuleFire VARCHAR (4) NULL,
		  FeeRateCntrlEx VARCHAR (4) NULL,
		  FeeRateCntrlIn VARCHAR (4) NULL,
		  SalesTaxExempt CHAR (1) NULL,
		  EffectiveDate DATETIME NULL,
		  TerminationDate DATETIME NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

