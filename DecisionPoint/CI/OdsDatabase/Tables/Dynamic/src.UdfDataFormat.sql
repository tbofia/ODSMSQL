IF OBJECT_ID('src.UdfDataFormat', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.UdfDataFormat
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  UdfDataFormatId SMALLINT NOT NULL ,
			  DataFormatName VARCHAR (30) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.UdfDataFormat ADD 
     CONSTRAINT PK_UdfDataFormat PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, UdfDataFormatId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_UdfDataFormat ON src.UdfDataFormat   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
