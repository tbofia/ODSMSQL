IF OBJECT_ID('src.LineMod', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.LineMod
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
			  ModSeq SMALLINT NOT NULL ,
			  UserEntered CHAR (1) NULL ,
			  ModSiteCode CHAR (3) NULL ,
			  Modifier VARCHAR (6) NULL ,
			  ReductionCode SMALLINT NULL ,
			  ModSubset CHAR (2) NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ReasonClientCode CHAR (4) NULL ,
			  ReasonBillSeq INT NULL ,
			  ReasonLineSeq SMALLINT NULL ,
			  ReasonType CHAR (1) NULL ,
			  ReasonValue VARCHAR (30) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.LineMod ADD 
     CONSTRAINT PK_LineMod PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LineSeq, ModSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_LineMod ON src.LineMod   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
