IF OBJECT_ID('src.BIReportAdjustmentCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BIReportAdjustmentCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BIReportAdjustmentCategoryId INT NOT NULL ,
			  Name VARCHAR (50) NULL ,
			  Description VARCHAR (500) NULL ,
			  DisplayPriority INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BIReportAdjustmentCategory ADD 
     CONSTRAINT PK_BIReportAdjustmentCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BIReportAdjustmentCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BIReportAdjustmentCategory ON src.BIReportAdjustmentCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
