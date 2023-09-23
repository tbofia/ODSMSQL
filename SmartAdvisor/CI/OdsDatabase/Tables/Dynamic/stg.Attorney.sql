IF OBJECT_ID('stg.Attorney', 'U') IS NOT NULL 
	DROP TABLE stg.Attorney  
BEGIN
	CREATE TABLE stg.Attorney
		(
		  ClaimSysSubSet CHAR (4) NULL,
		  AttorneySeq BIGINT NULL,
		  TIN VARCHAR (9) NULL,
		  TINSuffix VARCHAR (6) NULL,
		  ExternalID VARCHAR (30) NULL,
		  Name VARCHAR (50) NULL,
		  GroupCode VARCHAR (5) NULL,
		  LicenseNum VARCHAR (30) NULL,
		  MedicareNum VARCHAR (20) NULL,
		  PracticeAddressSeq INT NULL,
		  BillingAddressSeq INT NULL,
		  AttorneyType CHAR (3) NULL,
		  Specialty1 VARCHAR (8) NULL,
		  Specialty2 VARCHAR (8) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  Status CHAR (1) NULL,
		  ExternalStatus CHAR (1) NULL,
		  ExportDate DATETIME NULL,
		  SsnTinIndicator CHAR (1) NULL,
		  PmtDays SMALLINT NULL,
		  AuthBeginDate DATETIME NULL,
		  AuthEndDate DATETIME NULL,
		  TaxAddressSeq INT NULL,
		  CtrlNum1099 VARCHAR (4) NULL,
		  SurchargeCode CHAR (1) NULL,
		  WorkCompNum VARCHAR (18) NULL,
		  WorkCompState CHAR (2) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

