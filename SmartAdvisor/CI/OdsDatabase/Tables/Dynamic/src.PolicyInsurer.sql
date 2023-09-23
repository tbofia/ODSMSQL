IF OBJECT_ID('src.PolicyInsurer', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PolicyInsurer
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  PolicySeq INT NOT NULL ,
			  Jurisdiction CHAR (2) NOT NULL ,
			  InsurerType CHAR (1) NOT NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  InsurerSeq INT NULL ,
			  TerminationDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PolicyInsurer ADD 
     CONSTRAINT PK_PolicyInsurer PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset, PolicySeq, Jurisdiction, InsurerType, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PolicyInsurer ON src.PolicyInsurer   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
