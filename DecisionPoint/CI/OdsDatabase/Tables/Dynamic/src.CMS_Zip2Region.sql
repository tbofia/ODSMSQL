IF OBJECT_ID('src.CMS_Zip2Region', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.CMS_Zip2Region
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  StartDate DATETIME NOT NULL ,
			  EndDate DATETIME NULL ,
			  ZIP_Code VARCHAR (5) NOT NULL ,
			  State VARCHAR (2) NULL ,
			  Region VARCHAR (2) NULL ,
			  AmbRegion VARCHAR (2) NULL ,
			  RuralFlag SMALLINT NULL ,
			  ASCRegion SMALLINT NULL ,
			  PlusFour SMALLINT NULL ,
			  CarrierId INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.CMS_Zip2Region ADD 
     CONSTRAINT PK_CMS_Zip2Region PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, StartDate, ZIP_Code) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_CMS_Zip2Region ON src.CMS_Zip2Region   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
