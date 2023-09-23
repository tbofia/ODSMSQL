IF OBJECT_ID('src.DeductibleRuleCriteria', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.DeductibleRuleCriteria
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  DeductibleRuleCriteriaId INT NOT NULL ,
			  PricingRuleDateCriteriaId TINYINT NULL ,
			  StartDate DATETIME NULL ,
			  EndDate DATETIME NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.DeductibleRuleCriteria ADD 
     CONSTRAINT PK_DeductibleRuleCriteria PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DeductibleRuleCriteriaId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_DeductibleRuleCriteria ON src.DeductibleRuleCriteria   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
