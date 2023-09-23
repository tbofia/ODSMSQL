IF OBJECT_ID('src.FSServiceCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.FSServiceCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  ServiceCode VARCHAR (30) NOT NULL ,
			  GeoAreaCode VARCHAR (12) NOT NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  Description VARCHAR (255) NULL ,
			  TermDate DATETIME NULL ,
			  CodeSource VARCHAR (6) NULL ,
			  CodeGroup VARCHAR (12) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.FSServiceCode ADD 
     CONSTRAINT PK_FSServiceCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, ServiceCode, GeoAreaCode, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_FSServiceCode ON src.FSServiceCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
