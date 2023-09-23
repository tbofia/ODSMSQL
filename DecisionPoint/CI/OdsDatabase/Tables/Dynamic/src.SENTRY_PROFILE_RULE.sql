IF OBJECT_ID('src.SENTRY_PROFILE_RULE', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_PROFILE_RULE
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProfileID INT NOT NULL ,
			  RuleID INT NOT NULL ,
			  Priority INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_PROFILE_RULE ADD 
     CONSTRAINT PK_SENTRY_PROFILE_RULE PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProfileID, RuleID, Priority) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_PROFILE_RULE ON src.SENTRY_PROFILE_RULE   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
