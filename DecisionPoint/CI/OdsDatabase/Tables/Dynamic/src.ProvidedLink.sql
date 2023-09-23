IF OBJECT_ID('src.ProvidedLink', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProvidedLink
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProvidedLinkId INT NOT NULL ,
			  Title VARCHAR (100) NULL ,
			  URL VARCHAR (150) NULL ,
			  OrderIndex TINYINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProvidedLink ADD 
     CONSTRAINT PK_ProvidedLink PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProvidedLinkId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProvidedLink ON src.ProvidedLink   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
