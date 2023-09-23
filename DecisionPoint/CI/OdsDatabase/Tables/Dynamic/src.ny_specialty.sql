IF OBJECT_ID('src.ny_specialty', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ny_specialty
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              RatingCode VARCHAR(12) NOT NULL ,
              Desc_ VARCHAR(70) NULL 
            
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ny_specialty ADD 
        CONSTRAINT PK_ny_specialty PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RatingCode) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ny_specialty ON src.ny_specialty REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ny_Specialty')
						AND NAME = 'CbreSpecialtyCode' )
	BEGIN
		ALTER TABLE src.ny_Specialty ADD CbreSpecialtyCode VARCHAR(12) NULL ;
	END ; 
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ny_specialty'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ny_specialty ON src.ny_specialty REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

