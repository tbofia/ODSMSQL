IF OBJECT_ID('src.ModifierToProcedureCode', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ModifierToProcedureCode
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ProcedureCode VARCHAR (5) NOT NULL ,
			  Modifier VARCHAR (2) NOT NULL ,
			  StartDate DATETIME2 (7) NOT NULL ,
			  EndDate DATETIME2 (7) NULL ,
			  SojFlag SMALLINT NULL ,
			  RequiresGuidelineReview BIT NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ModifierToProcedureCode ADD 
     CONSTRAINT PK_ModifierToProcedureCode PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ProcedureCode, Modifier, StartDate) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ModifierToProcedureCode ON src.ModifierToProcedureCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ModifierToProcedureCode')
						AND NAME = 'Reference' )
	BEGIN
		ALTER TABLE src.ModifierToProcedureCode ADD Reference VARCHAR(255) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ModifierToProcedureCode')
						AND NAME = 'Comments' )
	BEGIN
		ALTER TABLE src.ModifierToProcedureCode ADD Comments VARCHAR(255) NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                WHERE name = 'PK_ModifierToProcedureCode' 
                AND is_incremental = 1)  
BEGIN
ALTER INDEX PK_ModifierToProcedureCode ON src.ModifierToProcedureCode   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 

END ;
GO


