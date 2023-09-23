IF OBJECT_ID('src.SENTRY_CRITERIA', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_CRITERIA
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  CriteriaID INT NOT NULL ,
			  ParentName VARCHAR (50) NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (150) NULL ,
			  Operators VARCHAR (50) NULL ,
			  PredefinedValues VARCHAR (MAX) NULL ,
			  ValueDataType VARCHAR (50) NULL ,
			  ValueFormat VARCHAR (250) NULL ,
			  NullAllowed SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_CRITERIA ADD 
     CONSTRAINT PK_SENTRY_CRITERIA PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CriteriaID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_CRITERIA ON src.SENTRY_CRITERIA   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
