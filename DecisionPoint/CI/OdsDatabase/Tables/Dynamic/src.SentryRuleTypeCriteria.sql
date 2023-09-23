IF OBJECT_ID('src.SentryRuleTypeCriteria', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SentryRuleTypeCriteria
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleTypeId INT NOT NULL ,
			  CriteriaId INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SentryRuleTypeCriteria ADD 
     CONSTRAINT PK_SentryRuleTypeCriteria PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleTypeId, CriteriaId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SentryRuleTypeCriteria ON src.SentryRuleTypeCriteria   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
