IF OBJECT_ID('src.BillControlHistory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillControlHistory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillControlHistorySeq BIGINT NOT NULL ,
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  BillControlSeq SMALLINT NOT NULL ,
			  CreateDate DATETIME NULL ,
			  Control CHAR (1) NULL ,
			  ExternalID VARCHAR (50) NULL ,
			  EDIBatchLogSeq BIGINT NULL ,
			  Deleted BIT NULL ,
			  ModUserID CHAR (2) NULL ,
			  ExternalID2 VARCHAR (50) NULL ,
			  Message VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillControlHistory ADD 
     CONSTRAINT PK_BillControlHistory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillControlHistorySeq, ClientCode, BillSeq, BillControlSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillControlHistory ON src.BillControlHistory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
