IF OBJECT_ID('src.EvaluationSummaryTemplateVersion', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.EvaluationSummaryTemplateVersion
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  EvaluationSummaryTemplateVersionId INT NOT NULL ,
			  Template NVARCHAR (MAX) NULL ,
			  TemplateHash VARBINARY(32) NULL ,
			  CreatedDate DATETIMEOFFSET NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.EvaluationSummaryTemplateVersion ADD 
     CONSTRAINT PK_EvaluationSummaryTemplateVersion PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, EvaluationSummaryTemplateVersionId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_EvaluationSummaryTemplateVersion ON src.EvaluationSummaryTemplateVersion   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
