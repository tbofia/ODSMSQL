IF OBJECT_ID('src.DeductibleRuleCriteriaCoverageType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.DeductibleRuleCriteriaCoverageType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  DeductibleRuleCriteriaId INT NOT NULL ,
			  CoverageType VARCHAR (5) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.DeductibleRuleCriteriaCoverageType ADD 
     CONSTRAINT PK_DeductibleRuleCriteriaCoverageType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DeductibleRuleCriteriaId, CoverageType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_DeductibleRuleCriteriaCoverageType ON src.DeductibleRuleCriteriaCoverageType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
