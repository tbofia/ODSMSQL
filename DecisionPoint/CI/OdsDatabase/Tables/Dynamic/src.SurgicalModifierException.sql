IF OBJECT_ID('src.SurgicalModifierException', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SurgicalModifierException
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  Modifier VARCHAR (2) NOT NULL ,
			  State VARCHAR (2) NOT NULL ,
			  CoverageType VARCHAR (2) NOT NULL ,
			  StartDate DATETIME2 (7) NOT NULL ,
			  EndDate DATETIME2 (7) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SurgicalModifierException ADD 
     CONSTRAINT PK_SurgicalModifierException PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, Modifier, State, CoverageType, StartDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SurgicalModifierException ON src.SurgicalModifierException   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
