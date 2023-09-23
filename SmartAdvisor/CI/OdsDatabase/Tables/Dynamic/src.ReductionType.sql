IF OBJECT_ID('src.ReductionType', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ReductionType
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ReductionCode SMALLINT NOT NULL ,
			  ReductionDescription VARCHAR (50) NULL ,
			  BEOverride CHAR (1) NULL ,
			  BEMsg CHAR (1) NULL ,
			  Abbreviation VARCHAR (8) NULL ,
			  DefaultMessageCode VARCHAR (6) NULL ,
			  DefaultDenialMessageCode VARCHAR (6) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ReductionType ADD 
     CONSTRAINT PK_ReductionType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ReductionCode) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ReductionType ON src.ReductionType   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
