IF OBJECT_ID('src.ClaimICDDiagnosis', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimICDDiagnosis
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  ClaimSeq INT NOT NULL ,
			  ClaimDiagnosisSeq SMALLINT NOT NULL ,
			  ICDDiagnosisID INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimICDDiagnosis ADD 
     CONSTRAINT PK_ClaimICDDiagnosis PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, ClaimSeq, ClaimDiagnosisSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimICDDiagnosis ON src.ClaimICDDiagnosis   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
