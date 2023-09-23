IF OBJECT_ID('src.ODGData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ODGData
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ICDDiagnosisID INT NOT NULL ,
			  ProcedureCode VARCHAR (30) NOT NULL ,
			  ICDDescription VARCHAR (300) NULL ,
			  ProcedureDescription VARCHAR (800) NULL ,
			  IncidenceRate MONEY NULL ,
			  ProcedureFrequency MONEY NULL ,
			  Visits25Perc SMALLINT NULL ,
			  Visits50Perc SMALLINT NULL ,
			  Visits75Perc SMALLINT NULL ,
			  VisitsMean MONEY NULL ,
			  CostsMean MONEY NULL ,
			  AutoApprovalCode VARCHAR (5) NULL ,
			  PaymentFlag SMALLINT NULL ,
			  CostPerVisit MONEY NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ODGData ADD 
     CONSTRAINT PK_ODGData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ICDDiagnosisID, ProcedureCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ODGData ON src.ODGData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
