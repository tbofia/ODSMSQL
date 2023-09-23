IF OBJECT_ID('src.RuleType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.RuleType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleTypeID INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (150) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.RuleType ADD 
     CONSTRAINT PK_RuleType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleTypeID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_RuleType ON src.RuleType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
