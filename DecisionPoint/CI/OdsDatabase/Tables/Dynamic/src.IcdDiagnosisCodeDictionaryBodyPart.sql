IF OBJECT_ID('src.IcdDiagnosisCodeDictionaryBodyPart', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.IcdDiagnosisCodeDictionaryBodyPart
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  DiagnosisCode VARCHAR (8) NOT NULL ,
			  IcdVersion TINYINT NOT NULL ,
			  StartDate DATETIME2 (7) NOT NULL ,
			  NcciBodyPartId TINYINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.IcdDiagnosisCodeDictionaryBodyPart ADD 
     CONSTRAINT PK_IcdDiagnosisCodeDictionaryBodyPart PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, DiagnosisCode, IcdVersion, StartDate, NcciBodyPartId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_IcdDiagnosisCodeDictionaryBodyPart ON src.IcdDiagnosisCodeDictionaryBodyPart   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
