IF OBJECT_ID('src.SPECIALTY', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SPECIALTY
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  SpcIdNo INT NULL ,
			  Code VARCHAR (50) NOT NULL ,
			  Description VARCHAR (70) NULL ,
			  PayeeSubTypeID INT NULL ,
			  TieredTypeID SMALLINT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SPECIALTY ADD 
     CONSTRAINT PK_SPECIALTY PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Code) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SPECIALTY ON src.SPECIALTY   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
