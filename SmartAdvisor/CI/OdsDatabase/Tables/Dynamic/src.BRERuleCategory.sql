IF OBJECT_ID('src.BRERuleCategory', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BRERuleCategory
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BRERuleCategoryID VARCHAR (30) NOT NULL ,
			  CategoryDescription VARCHAR (500) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BRERuleCategory ADD 
     CONSTRAINT PK_BRERuleCategory PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BRERuleCategoryID) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BRERuleCategory ON src.BRERuleCategory   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
