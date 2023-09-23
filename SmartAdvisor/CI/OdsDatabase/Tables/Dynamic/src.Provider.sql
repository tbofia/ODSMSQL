IF OBJECT_ID('src.Provider', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Provider
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProviderSubSet CHAR (4) NOT NULL ,
			  ProviderSeq BIGINT NOT NULL ,
			  TIN VARCHAR (9) NULL ,
			  TINSuffix VARCHAR (6) NULL ,
			  ExternalID VARCHAR (30) NULL ,
			  Name VARCHAR (50) NULL ,
			  GroupCode VARCHAR (5) NULL ,
			  LicenseNum VARCHAR (30) NULL ,
			  MedicareNum VARCHAR (20) NULL ,
			  PracticeAddressSeq INT NULL ,
			  BillingAddressSeq INT NULL ,
			  HospitalSeq INT NULL ,
			  ProvType CHAR (3) NULL ,
			  Specialty1 VARCHAR (8) NULL ,
			  Specialty2 VARCHAR (8) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  Status CHAR (1) NULL ,
			  ExternalStatus CHAR (1) NULL ,
			  ExportDate DATETIME NULL ,
			  SsnTinIndicator CHAR (1) NULL ,
			  PmtDays SMALLINT NULL ,
			  AuthBeginDate DATETIME NULL ,
			  AuthEndDate DATETIME NULL ,
			  TaxAddressSeq INT NULL ,
			  CtrlNum1099 VARCHAR (4) NULL ,
			  SurchargeCode CHAR (1) NULL ,
			  WorkCompNum VARCHAR (18) NULL ,
			  WorkCompState CHAR (2) NULL ,
			  NCPDPID VARCHAR (10) NULL ,
			  EntityType CHAR (1) NULL ,
			  LastName VARCHAR (35) NULL ,
			  FirstName VARCHAR (25) NULL ,
			  MiddleName VARCHAR (25) NULL ,
			  Suffix VARCHAR (10) NULL ,
			  NPI VARCHAR (10) NULL ,
			  FacilityNPI VARCHAR (10) NULL ,
			  VerificationGroupID VARCHAR(30) NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Provider ADD 
     CONSTRAINT PK_Provider PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProviderSubSet, ProviderSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Provider ON src.Provider   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Provider')
						AND NAME = 'VerificationGroupID' )
	BEGIN
		ALTER TABLE src.Provider ADD VerificationGroupID VARCHAR(30) NULL ;
	END ; 
GO



