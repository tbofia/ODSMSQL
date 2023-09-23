IF OBJECT_ID('src.ScriptAdvisorBillSource', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ScriptAdvisorBillSource
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillSourceId TINYINT NOT NULL ,
			  BillSource VARCHAR (15) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ScriptAdvisorBillSource ADD 
     CONSTRAINT PK_ScriptAdvisorBillSource PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillSourceId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ScriptAdvisorBillSource ON src.ScriptAdvisorBillSource   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
