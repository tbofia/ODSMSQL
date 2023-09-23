IF OBJECT_ID('src.BillICDDiagnosis', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillICDDiagnosis
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  BillDiagnosisSeq SMALLINT NOT NULL ,
			  ICDDiagnosisID INT NULL ,
			  POA CHAR (1) NULL ,
			  BilledICDDiagnosis CHAR (8) NULL ,
			  ICDBillUsageTypeID SMALLINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillICDDiagnosis ADD 
     CONSTRAINT PK_BillICDDiagnosis PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, BillDiagnosisSeq, ICDBillUsageTypeID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillICDDiagnosis ON src.BillICDDiagnosis   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
