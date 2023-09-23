IF OBJECT_ID('src.PendComment', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.PendComment
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
			  PendSeq SMALLINT NOT NULL ,
			  PendCommentSeq SMALLINT NOT NULL ,
			  PendComment VARCHAR (7500) NULL ,
			  CreateUserID VARCHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  CreatedByExternalUserName VARCHAR (128) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.PendComment ADD 
     CONSTRAINT PK_PendComment PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, PendSeq, PendCommentSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_PendComment ON src.PendComment   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
