IF OBJECT_ID('src.ClaimDiag', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimDiag
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubSet CHAR (4) NOT NULL ,
			  ClaimSeq INT NOT NULL ,
			  ClaimDiagSeq SMALLINT NOT NULL ,
			  DiagCode VARCHAR (8) NULL ,
			 
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimDiag ADD 
     CONSTRAINT PK_ClaimDiag PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubSet, ClaimSeq, ClaimDiagSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimDiag ON src.ClaimDiag   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO


