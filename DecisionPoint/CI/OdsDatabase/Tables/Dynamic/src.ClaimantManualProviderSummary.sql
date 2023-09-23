IF OBJECT_ID('src.ClaimantManualProviderSummary', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimantManualProviderSummary
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ManualProviderId INT NOT NULL ,
			  DemandClaimantId INT NOT NULL ,
			  FirstDateOfService DATETIME2 (7) NULL ,
			  LastDateOfService DATETIME2 (7) NULL ,
			  Visits INT NULL ,
			  ChargedAmount DECIMAL(19, 4) NULL ,
			  EvaluatedAmount DECIMAL(19, 4) NULL ,
			  MinimumEvaluatedAmount DECIMAL(19, 4) NULL ,
			  MaximumEvaluatedAmount DECIMAL(19, 4) NULL ,
			  Comments VARCHAR (255) NULL 

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimantManualProviderSummary ADD 
     CONSTRAINT PK_ClaimantManualProviderSummary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ManualProviderId, DemandClaimantId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimantManualProviderSummary ON src.ClaimantManualProviderSummary   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
