IF OBJECT_ID('src.ProcedureServiceCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ProcedureServiceCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProcedureServiceCategoryId TINYINT NOT NULL ,
			  ProcedureServiceCategoryName VARCHAR (50) NULL ,
			  ProcedureServiceCategoryDescription VARCHAR (100) NULL ,
			  LegacyTableName VARCHAR (100) NULL ,
			  LegacyBitValue INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ProcedureServiceCategory ADD 
     CONSTRAINT PK_ProcedureServiceCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProcedureServiceCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ProcedureServiceCategory ON src.ProcedureServiceCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
