IF OBJECT_ID('src.Branch', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Branch
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  BranchSeq INT NOT NULL ,
			  Name VARCHAR (60) NULL ,
			  ExternalID VARCHAR (20) NULL ,
			  BranchID VARCHAR (20) NULL ,
			  LocationCode VARCHAR (10) NULL ,
			  AdminKey VARCHAR (40) NULL ,
			  Address1 VARCHAR (30) NULL ,
			  Address2 VARCHAR (30) NULL ,
			  City VARCHAR (20) NULL ,
			  State CHAR (2) NULL ,
			  Zip VARCHAR (9) NULL ,
			  PhoneNum VARCHAR (20) NULL ,
			  FaxNum VARCHAR (20) NULL ,
			  ContactName VARCHAR (30) NULL ,
			  TIN VARCHAR (9) NULL ,
			  StateTaxID VARCHAR (30) NULL ,
			  DIRNum VARCHAR (20) NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  RuleFire VARCHAR (4) NULL ,
			  FeeRateCntrlEx VARCHAR (4) NULL ,
			  FeeRateCntrlIn VARCHAR (4) NULL ,
			  SalesTaxExempt CHAR (1) NULL ,
			  EffectiveDate DATETIME NULL ,
			  TerminationDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Branch ADD 
     CONSTRAINT PK_Branch PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, BranchSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Branch ON src.Branch   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
