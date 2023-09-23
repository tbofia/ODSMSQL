IF OBJECT_ID('src.StateSettingsNewYorkPolicyPreference', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.StateSettingsNewYorkPolicyPreference
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

     ALTER TABLE src.StateSettingsNewYorkPolicyPreference ADD 
     CONSTRAINT PK_StateSettingsNewYorkPolicyPreference PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PolicyPreferenceId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_StateSettingsNewYorkPolicyPreference ON src.StateSettingsNewYorkPolicyPreference   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
