IF OBJECT_ID('src.ClaimSysData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimSysData
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  TypeCode CHAR (6) NOT NULL ,
			  SubType CHAR (12) NOT NULL ,
			  SubSeq SMALLINT NOT NULL ,
			  NumData NUMERIC (18,6) NULL ,
			  TextData VARCHAR (6000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimSysData ADD 
     CONSTRAINT PK_ClaimSysData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset, TypeCode, SubType, SubSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimSysData ON src.ClaimSysData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
