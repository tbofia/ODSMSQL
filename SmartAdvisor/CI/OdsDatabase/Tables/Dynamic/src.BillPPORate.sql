IF OBJECT_ID('src.BillPPORate', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillPPORate
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
			  LinkName VARCHAR (12) NOT NULL ,
			  RateType VARCHAR (8) NOT NULL ,
			  Applied CHAR (1) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillPPORate ADD 
     CONSTRAINT PK_BillPPORate PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LinkName, RateType) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillPPORate ON src.BillPPORate   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
