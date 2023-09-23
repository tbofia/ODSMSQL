IF OBJECT_ID('src.MedicareICQM', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.MedicareICQM
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  MdicqmSeq INT NOT NULL ,
			  ProviderNum VARCHAR (6) NULL ,
			  ProvSuffix CHAR (1) NULL ,
			  ServiceCode VARCHAR (25) NULL ,
			  HCPCS VARCHAR (5) NULL ,
			  Revenue CHAR (3) NULL ,
			  MedicareICQMDescription VARCHAR (40) NULL ,
			  IP1995 INT NULL ,
			  OP1995 INT NULL ,
			  IP1996 INT NULL ,
			  OP1996 INT NULL ,
			  IP1997 INT NULL ,
			  OP1997 INT NULL ,
			  IP1998 INT NULL ,
			  OP1998 INT NULL ,
			  NPI VARCHAR (10) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.MedicareICQM ADD 
     CONSTRAINT PK_MedicareICQM PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, MdicqmSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_MedicareICQM ON src.MedicareICQM   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
