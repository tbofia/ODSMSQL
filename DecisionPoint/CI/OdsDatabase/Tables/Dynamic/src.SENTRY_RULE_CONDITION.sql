IF OBJECT_ID('src.SENTRY_RULE_CONDITION', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_RULE_CONDITION
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleID INT NOT NULL ,
			  LineNumber INT NOT NULL ,
			  GroupFlag VARCHAR (50) NULL ,
			  CriteriaID INT NULL ,
			  Operator VARCHAR (50) NULL ,
			  ConditionValue VARCHAR (60) NULL ,
			  AndOr VARCHAR (50) NULL ,
			  UdfConditionId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_RULE_CONDITION ADD 
     CONSTRAINT PK_SENTRY_RULE_CONDITION PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleID, LineNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_RULE_CONDITION ON src.SENTRY_RULE_CONDITION   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
