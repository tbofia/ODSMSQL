IF OBJECT_ID('src.ModifierDictionary', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ModifierDictionary
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ModifierDictionaryId INT NOT NULL ,
			  Modifier VARCHAR (2) NULL ,
			  StartDate DATETIME2 (7) NULL ,
			  EndDate DATETIME2 (7) NULL ,
			  Description VARCHAR (100) NULL ,
			  Global BIT NULL ,
			  AnesMedDirect BIT NULL ,
			  AffectsPricing BIT NULL ,
			  IsCoSurgeon BIT NULL ,
			  IsAssistantSurgery BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ModifierDictionary ADD 
     CONSTRAINT PK_ModifierDictionary PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ModifierDictionaryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ModifierDictionary ON src.ModifierDictionary   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
