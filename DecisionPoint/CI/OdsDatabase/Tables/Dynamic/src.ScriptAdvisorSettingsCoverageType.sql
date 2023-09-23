IF OBJECT_ID('src.ScriptAdvisorSettingsCoverageType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ScriptAdvisorSettingsCoverageType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ScriptAdvisorSettingsId TINYINT NOT NULL ,
			  CoverageType VARCHAR (2) NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ScriptAdvisorSettingsCoverageType ADD 
     CONSTRAINT PK_ScriptAdvisorSettingsCoverageType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ScriptAdvisorSettingsId, CoverageType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ScriptAdvisorSettingsCoverageType ON src.ScriptAdvisorSettingsCoverageType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
