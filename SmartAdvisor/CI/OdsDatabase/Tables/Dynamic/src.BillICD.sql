IF OBJECT_ID('src.BillICD', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillICD
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
			  BillICDSeq SMALLINT NOT NULL ,
			  CodeType CHAR (1) NOT NULL ,
			  ICDCode VARCHAR (8) NULL ,
			  CodeDate DATETIME NULL ,
			  POA CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillICD ADD 
     CONSTRAINT PK_BillICD PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, BillICDSeq, CodeType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillICD ON src.BillICD   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
