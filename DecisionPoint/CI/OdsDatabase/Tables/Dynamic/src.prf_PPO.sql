IF OBJECT_ID('src.prf_PPO', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.prf_PPO
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PPOSysId INT NOT NULL ,
			  ProfileId INT NULL ,
			  PPOId INT NULL ,
			  bStatus SMALLINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
			  AutoSend SMALLINT NULL ,
			  AutoResend SMALLINT NULL ,
			  BypassMatching SMALLINT NULL ,
			  UseProviderNetworkEnrollment SMALLINT NULL ,
			  TieredTypeId SMALLINT NULL ,
			  Priority SMALLINT NULL ,
			  PolicyEffectiveDate DATETIME NULL ,
			  BillFormType INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.prf_PPO ADD 
     CONSTRAINT PK_prf_PPO PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PPOSysId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_prf_PPO ON src.prf_PPO   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
