IF OBJECT_ID('src.WFTaskLink', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.WFTaskLink
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  FromTaskSeq INT NOT NULL ,
			  LinkWhen SMALLINT NOT NULL ,
			  ToTaskSeq INT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.WFTaskLink ADD 
     CONSTRAINT PK_WFTaskLink PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, FromTaskSeq, LinkWhen) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_WFTaskLink ON src.WFTaskLink   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
