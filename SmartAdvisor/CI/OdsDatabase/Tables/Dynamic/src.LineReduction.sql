IF OBJECT_ID('src.LineReduction', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.LineReduction
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
			  LineSeq SMALLINT NOT NULL ,
			  ReductionCode SMALLINT NOT NULL ,
			  ReductionAmount MONEY NULL ,
			  OverrideAmount MONEY NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.LineReduction ADD 
     CONSTRAINT PK_LineReduction PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LineSeq, ReductionCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_LineReduction ON src.LineReduction   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
