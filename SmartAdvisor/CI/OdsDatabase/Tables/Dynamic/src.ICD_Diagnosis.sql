IF OBJECT_ID('src.ICD_Diagnosis', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ICD_Diagnosis
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ICDDiagnosisID INT NOT NULL ,
			  Code CHAR (8) NULL ,
			  ShortDesc VARCHAR (60) NULL ,
			  Description VARCHAR (300) NULL ,
			  Detailed BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ICD_Diagnosis ADD 
     CONSTRAINT PK_ICD_Diagnosis PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ICDDiagnosisID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ICD_Diagnosis ON src.ICD_Diagnosis   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
