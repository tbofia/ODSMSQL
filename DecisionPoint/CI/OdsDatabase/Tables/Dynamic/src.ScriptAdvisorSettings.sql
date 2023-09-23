IF OBJECT_ID('src.ScriptAdvisorSettings', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ScriptAdvisorSettings
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ScriptAdvisorSettingsId TINYINT NOT NULL ,
			  IsPharmacyEligible BIT NULL ,
			  EnableSendCardToClaimant BIT NULL ,
			  EnableBillSource BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ScriptAdvisorSettings ADD 
     CONSTRAINT PK_ScriptAdvisorSettings PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ScriptAdvisorSettingsId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ScriptAdvisorSettings ON src.ScriptAdvisorSettings   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
