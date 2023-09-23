IF OBJECT_ID('src.Medispan', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Medispan
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  NDC CHAR (11) NOT NULL ,
			  DEA VARCHAR (5) NULL ,
			  Name1 VARCHAR (25) NULL ,
			  Name2 VARCHAR (4) NULL ,
			  Name3 VARCHAR (11) NULL ,
			  Strength INT NULL ,
			  Unit INT NULL ,
			  Pkg CHAR (2) NULL ,
			  Factor SMALLINT NULL ,
			  GenericDrug CHAR (1) NULL ,
			  Desicode CHAR (1) NULL ,
			  Rxotc CHAR (1) NULL ,
			  GPI VARCHAR (14) NULL ,
			  Awp1 INT NULL ,
			  Awp0 INT NULL ,
			  Awp2 INT NULL ,
			  EffectiveDt2 DATETIME NULL ,
			  EffectiveDt1 DATETIME NULL ,
			  EffectiveDt0 DATETIME NULL ,
			  FDAEquivalence CHAR (3) NULL ,
			  NDCFormat CHAR (1) NULL ,
			  RestrictDrugs CHAR (1) NULL ,
			  GPPC VARCHAR (8) NULL ,
			  Status CHAR (1) NULL ,
			  UpdateDate DATETIME NULL ,
			  AAWP INT NULL ,
			  GAWP INT NULL ,
			  RepackagedCode VARCHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Medispan ADD 
     CONSTRAINT PK_Medispan PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, NDC) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Medispan ON src.Medispan   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
