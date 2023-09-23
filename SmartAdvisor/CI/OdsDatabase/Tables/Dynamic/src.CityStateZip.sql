IF OBJECT_ID('src.CityStateZip', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CityStateZip
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ZipCode CHAR (5) NOT NULL ,
			  CtyStKey CHAR (6) NOT NULL ,
			  CpyDtlCode CHAR (1) NULL ,
			  ZipClsCode CHAR (1) NULL ,
			  CtyStName VARCHAR (28) NULL ,
			  CtyStNameAbv VARCHAR (13) NULL ,
			  CtyStFacCode CHAR (1) NULL ,
			  CtyStMailInd CHAR (1) NULL ,
			  PreLstCtyKey VARCHAR (6) NULL ,
			  PreLstCtyNme VARCHAR (28) NULL ,
			  CtyDlvInd CHAR (1) NULL ,
			  AutZoneInd CHAR (1) NULL ,
			  UnqZipInd CHAR (1) NULL ,
			  FinanceNum VARCHAR (6) NULL ,
			  StateAbbrv CHAR (2) NULL ,
			  CountyNum CHAR (3) NULL ,
			  CountyName VARCHAR (25) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CityStateZip ADD 
     CONSTRAINT PK_CityStateZip PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ZipCode, CtyStKey) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CityStateZip ON src.CityStateZip   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
