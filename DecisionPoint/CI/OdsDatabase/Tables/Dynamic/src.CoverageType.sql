 -- Renaming src.lk_CVTYPE table to src.CoverageType for 10.7 DP Schema changes
 IF OBJECT_ID('src.lkp_CVTYPE', 'U') IS NOT NULL
    BEGIN
	SET XACT_ABORT ON;
	BEGIN TRANSACTION
	-- Create the backup table for src.lk_CVTYPE
	CREATE TABLE src.lkp_CVTYPE_BAK
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              LongName VARCHAR(30) NULL ,
              ShortName VARCHAR(2) NOT NULL ,
			  CbreCoverageTypeCode VARCHAR(2) NULL,
			  CoverageTypeCategoryCode VARCHAR(4) NULL,
			  PricingMethodId TINYINT NULL
			  )
	INSERT INTO src.lkp_CVTYPE_BAK SELECT *  FROM  src.lkp_CVTYPE

	-- Rename the existing src.lk_CVTYPE tbale to src.CoverageType including stg table, view & Function.
	EXEC sp_rename 'src.lkp_CVTYPE.PK_lkp_CVTYPE', 'PK_CoverageType', N'INDEX'
	EXEC sp_rename 'src.lkp_CVTYPE', 'CoverageType'
	--Drop Stg, View & functions here , and will be created as a part of install.bat
	IF OBJECT_ID('stg.lkp_CVTYPE', 'U') IS NOT NULL 
	DROP TABLE stg.lkp_CVTYPE 
	
	IF OBJECT_ID('dbo.lkp_CVTYPE', 'V') IS NOT NULL
    DROP VIEW dbo.lkp_CVTYPE;
	
	IF OBJECT_ID('dbo.if_lkp_CVTYPE', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_lkp_CVTYPE;
	
	COMMIT TRANSACTION
	END 
GO


IF OBJECT_ID('src.CoverageType', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CoverageType
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              LongName VARCHAR(30) NULL ,
              ShortName VARCHAR(2) NOT NULL ,
			  CbreCoverageTypeCode VARCHAR(2) NULL,
			  CoverageTypeCategoryCode VARCHAR(4) NULL,
			  PricingMethodId TINYINT NULL
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CoverageType ADD 
        CONSTRAINT PK_CoverageType PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ShortName)WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CoverageType ON src.CoverageType REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CoverageType')
						AND NAME = 'CbreCoverageTypeCode' )
	BEGIN
		ALTER TABLE src.CoverageType ADD CbreCoverageTypeCode VARCHAR(2) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CoverageType')
						AND NAME = 'CoverageTypeCategoryCode' )
	BEGIN
		ALTER TABLE src.CoverageType ADD CoverageTypeCategoryCode VARCHAR(4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CoverageType')
						AND NAME = 'PricingMethodId' )
	BEGIN
		ALTER TABLE src.CoverageType ADD PricingMethodId TINYINT NULL  ;
	END ; 
GO



-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CoverageType'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CoverageType ON src.CoverageType REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO





