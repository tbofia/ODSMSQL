IF OBJECT_ID('src.SENTRY_RULE', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_RULE
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleID INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (MAX) NULL ,
			  CreatedBy VARCHAR (50) NULL ,
			  CreationDate DATETIME NULL ,
			  PostFixNotation VARCHAR (MAX) NULL ,
			  Priority INT NULL ,
			  RuleTypeID SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_RULE ADD 
     CONSTRAINT PK_SENTRY_RULE PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_RULE ON src.SENTRY_RULE   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
