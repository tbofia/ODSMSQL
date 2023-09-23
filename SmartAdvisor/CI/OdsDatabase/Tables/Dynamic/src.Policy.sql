IF OBJECT_ID('src.Policy', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Policy
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  PolicySeq INT NOT NULL ,
			  Name VARCHAR (60) NULL ,
			  ExternalID VARCHAR (20) NULL ,
			  PolicyID VARCHAR (30) NULL ,
			  AdminKey VARCHAR (40) NULL ,
			  LocationCode VARCHAR (10) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (20) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  EffectiveDate DATETIME NULL ,
			  TerminationDate DATETIME NULL ,
			  TIN VARCHAR (9) NULL ,
			  StateTaxID VARCHAR (30) NULL ,
			  DeptIndusRelNum VARCHAR (20) NULL ,
			  EqOppIndicator CHAR (1) NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  MCOFlag CHAR (1) NULL ,
			  MCOStartDate DATETIME NULL ,
			  FeeRateCtrlEx CHAR (4) NULL ,
			  CreateBy CHAR (2) NULL ,
			  FeeRateCtrlIn CHAR (4) NULL ,
			  CreateDate DATETIME NULL ,
			  SelfInsured CHAR (1) NULL ,
			  NAICSCode VARCHAR (15) NULL ,
			  MonthlyPremium MONEY NULL ,
			  PPOProfileSiteCode CHAR (3) NULL ,
			  PPOProfileID INT NULL ,
			  SalesTaxExempt CHAR (1) NULL ,
			  ReceiptHandlingCode CHAR (1) NULL ,
			  TxNonSubscrib CHAR (1) NULL ,
			  SubdivisionName VARCHAR (60) NULL ,
			  PolicyCoPayAmount MONEY NULL ,
			  PolicyCoPayPct SMALLINT NULL ,
			  PolicyDeductible MONEY NULL ,
			  PolicyLimitAmount MONEY NULL ,
			  PolicyTimeLimit SMALLINT NULL ,
			  PolicyLimitWarningPct SMALLINT NULL ,
			  PolicyLimitResult CHAR (1) NULL ,
			  URProfileID VARCHAR (8) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Policy ADD 
     CONSTRAINT PK_Policy PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, PolicySeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Policy ON src.Policy   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
