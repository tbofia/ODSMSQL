IF OBJECT_ID('src.BillReevalReason', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BillReevalReason
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillReevalReasonCode VARCHAR (30) NOT NULL ,
			  SiteCode CHAR (3) NOT NULL ,
			  BillReevalReasonCategorySeq INT NULL ,
			  ShortDescription VARCHAR (40) NULL ,
			  LongDescription VARCHAR (255) NULL ,
			  Active BIT NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BillReevalReason ADD 
     CONSTRAINT PK_BillReevalReason PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillReevalReasonCode, SiteCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BillReevalReason ON src.BillReevalReason   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
