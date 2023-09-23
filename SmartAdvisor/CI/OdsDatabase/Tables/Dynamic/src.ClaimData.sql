IF OBJECT_ID('src.ClaimData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimData
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  ClaimSeq INT NOT NULL ,
			  TypeCode CHAR (6) NOT NULL ,
			  SubType CHAR (12) NOT NULL ,
			  SubSeq SMALLINT NOT NULL ,
			  NumData NUMERIC (18,6) NULL ,
			  TextData VARCHAR (6000) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimData ADD 
     CONSTRAINT PK_ClaimData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset, ClaimSeq, TypeCode, SubType, SubSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimData ON src.ClaimData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
