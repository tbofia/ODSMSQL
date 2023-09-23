IF OBJECT_ID('src.ClaimInsurer', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimInsurer
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  ClaimSeq INT NOT NULL ,
			  InsurerType CHAR (1) NOT NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  InsurerSeq INT NULL ,
			  TerminationDate DATETIME NULL ,
			  ExternalPolicyNumber VARCHAR (30) NULL ,
			  UnitStatClaimID VARCHAR (35) NULL ,
			  UnitStatPolicyID VARCHAR (30) NULL ,
			  PolicyEffectiveDate DATETIME NULL ,
			  SelfInsured CHAR (1) NULL ,
			  ClaimAdminClaimNum VARCHAR (35) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimInsurer ADD 
     CONSTRAINT PK_ClaimInsurer PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset, ClaimSeq, InsurerType, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimInsurer ON src.ClaimInsurer   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
