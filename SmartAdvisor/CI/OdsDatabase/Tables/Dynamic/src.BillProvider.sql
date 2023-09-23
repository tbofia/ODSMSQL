IF OBJECT_ID('src.BillProvider', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillProvider
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
			  BillProviderSeq INT NOT NULL ,
			  Qualifier CHAR (2) NULL ,
			  LastName VARCHAR (40) NULL ,
			  FirstName VARCHAR (30) NULL ,
			  MiddleName VARCHAR (25) NULL ,
			  Suffix VARCHAR (10) NULL ,
			  NPI VARCHAR (10) NULL ,
			  LicenseNum VARCHAR (30) NULL ,
			  DEANum VARCHAR (9) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillProvider ADD 
     CONSTRAINT PK_BillProvider PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, BillProviderSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillProvider ON src.BillProvider   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
