IF OBJECT_ID('src.Region', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Region
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  Extension CHAR (3) NOT NULL ,
			  EndZip CHAR (5) NOT NULL ,
			  Beg VARCHAR (5) NULL ,
			  Region SMALLINT NULL ,
			  RegionDescription VARCHAR (4) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Region ADD 
     CONSTRAINT PK_Region PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, Extension, EndZip) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Region ON src.Region   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
