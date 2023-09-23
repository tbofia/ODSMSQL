IF OBJECT_ID('stg.BillReevalReason', 'U') IS NOT NULL 
	DROP TABLE stg.BillReevalReason  
BEGIN
	CREATE TABLE stg.BillReevalReason
		(
		  BillReevalReasonCode VARCHAR (30) NULL,
		  SiteCode CHAR (3) NULL,
		  BillReevalReasonCategorySeq INT NULL,
		  ShortDescription VARCHAR (40) NULL,
		  LongDescription VARCHAR (255) NULL,
		  Active BIT NULL,
		  CreateDate DATETIME NULL,
		  CreateUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

