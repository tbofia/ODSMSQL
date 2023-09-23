IF OBJECT_ID('src.StateSettingsNewJerseyPolicyPreference', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNewJerseyPolicyPreference
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  PolicyPreferenceId INT NOT NULL ,
			  ShareCoPayMaximum BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.StateSettingsNewJerseyPolicyPreference ADD 
     CONSTRAINT PK_StateSettingsNewJerseyPolicyPreference PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PolicyPreferenceId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNewJerseyPolicyPreference ON src.StateSettingsNewJerseyPolicyPreference   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
