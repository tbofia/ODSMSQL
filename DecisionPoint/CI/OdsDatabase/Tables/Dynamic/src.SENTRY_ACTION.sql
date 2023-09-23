IF OBJECT_ID('src.SENTRY_ACTION', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_ACTION
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ActionID INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (100) NULL ,
			  CompatibilityKey VARCHAR (50) NULL ,
			  PredefinedValues VARCHAR (MAX) NULL ,
			  ValueDataType VARCHAR (50) NULL ,
			  ValueFormat VARCHAR (250) NULL ,
			  BillLineAction INT NULL ,
			  AnalyzeFlag SMALLINT NULL ,
			  ActionCategoryIDNo INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_ACTION ADD 
     CONSTRAINT PK_SENTRY_ACTION PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ActionID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_ACTION ON src.SENTRY_ACTION   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
