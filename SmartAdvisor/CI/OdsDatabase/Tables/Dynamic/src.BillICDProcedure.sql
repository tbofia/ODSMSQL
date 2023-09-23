IF OBJECT_ID('src.BillICDProcedure', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillICDProcedure
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
			  BillProcedureSeq SMALLINT NOT NULL ,
			  ICDProcedureID INT NULL ,
			  CodeDate DATETIME NULL ,
			  BilledICDProcedure CHAR (8) NULL ,
			  ICDBillUsageTypeID SMALLINT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillICDProcedure ADD 
     CONSTRAINT PK_BillICDProcedure PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, BillProcedureSeq, ICDBillUsageTypeID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillICDProcedure ON src.BillICDProcedure   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
