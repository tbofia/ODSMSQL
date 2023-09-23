IF OBJECT_ID('src.BIReportAdjustmentCategoryMapping', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BIReportAdjustmentCategoryMapping
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BIReportAdjustmentCategoryId INT NOT NULL ,
			  Adjustment360SubCategoryId INT NOT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BIReportAdjustmentCategoryMapping ADD 
     CONSTRAINT PK_BIReportAdjustmentCategoryMapping PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BIReportAdjustmentCategoryId, Adjustment360SubCategoryId) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BIReportAdjustmentCategoryMapping ON src.BIReportAdjustmentCategoryMapping   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
