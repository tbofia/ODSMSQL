IF OBJECT_ID('src.WFTask', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFTask
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  WFTaskSeq INT NOT NULL ,
			  WFLowSeq INT NULL ,
			  WFTaskRegistrySeq INT NULL ,
			  Name VARCHAR (35) NULL ,
			  Parameter1 VARCHAR (35) NULL ,
			  RecordStatus CHAR (1) NULL ,
			  NodeLeft NUMERIC (8,2) NULL ,
			  NodeTop NUMERIC (8,2) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  NoPrior CHAR (1) NULL ,
			  NoRestart CHAR (1) NULL ,
			  ParameterX VARCHAR (2000) NULL ,
			  DefaultPendGroup VARCHAR (12) NULL ,
			  Configuration NVARCHAR (2000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFTask ADD 
     CONSTRAINT PK_WFTask PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, WFTaskSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFTask ON src.WFTask   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
