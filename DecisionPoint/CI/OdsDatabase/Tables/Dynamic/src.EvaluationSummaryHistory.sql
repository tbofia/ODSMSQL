IF OBJECT_ID('src.EvaluationSummaryHistory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EvaluationSummaryHistory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EvaluationSummaryHistoryId INT NOT NULL ,
			  DemandClaimantId INT NULL ,
			  EvaluationSummary NVARCHAR (MAX) NULL ,
			  CreatedBy NVARCHAR (50) NULL ,
			  CreatedDate DATETIMEOFFSET NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EvaluationSummaryHistory ADD 
     CONSTRAINT PK_EvaluationSummaryHistory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EvaluationSummaryHistoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EvaluationSummaryHistory ON src.EvaluationSummaryHistory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
