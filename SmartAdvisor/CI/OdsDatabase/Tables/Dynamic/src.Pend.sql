IF OBJECT_ID('src.Pend', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Pend
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
			  PendDate DATETIME NULL ,
			  ReleaseFlag CHAR (1) NULL ,
			  PendToID VARCHAR (13) NULL ,
			  Priority CHAR (1) NULL ,
			  ReleaseDate DATETIME NULL ,
			  ReasonCode VARCHAR (8) NULL ,
			  PendByUserID CHAR (2) NULL ,
			  ReleaseByUserID CHAR (2) NULL ,
			  AutoPendFlag CHAR (1) NULL ,
			  RuleID CHAR (5) NULL ,
			  WFTaskSeq INT NULL ,
			  ReleasedByExternalUserName VARCHAR (128) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Pend ADD 
     CONSTRAINT PK_Pend PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, PendSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Pend ON src.Pend   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
