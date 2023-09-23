IF OBJECT_ID('src.FSProcedureMV', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.FSProcedureMV
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Jurisdiction CHAR (2) NOT NULL ,
			  Extension CHAR (3) NOT NULL ,
			  ProcedureCode CHAR (6) NOT NULL ,
			  EffectiveDate DATETIME NOT NULL ,
			  TerminationDate DATETIME NULL ,
			  FSProcDescription VARCHAR (24) NULL ,
			  Sv CHAR (1) NULL ,
			  Star CHAR (1) NULL ,
			  Panel CHAR (1) NULL ,
			  Ip CHAR (1) NULL ,
			  Mult CHAR (1) NULL ,
			  AsstSurgeon CHAR (1) NULL ,
			  SectionFlag CHAR (1) NULL ,
			  Fup CHAR (3) NULL ,
			  Bav SMALLINT NULL ,
			  ProcGroup CHAR (4) NULL ,
			  ViewType SMALLINT NULL ,
			  UnitValue MONEY NULL ,
			  ProUnitValue MONEY NULL ,
			  TechUnitValue MONEY NULL ,
			  SiteCode CHAR (3) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.FSProcedureMV ADD 
     CONSTRAINT PK_FSProcedureMV PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Jurisdiction, Extension, ProcedureCode, EffectiveDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_FSProcedureMV ON src.FSProcedureMV   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
