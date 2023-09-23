IF OBJECT_ID('src.Bills_Pharm_CTG_Endnotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm_CTG_Endnotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              EndNote SMALLINT NOT NULL ,
              RuleType VARCHAR(2) NULL ,
              RuleId INT NULL ,
              PreCertAction SMALLINT NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL 
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm_CTG_Endnotes ADD 
        CONSTRAINT PK_Bills_Pharm_CTG_Endnotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO, EndNote) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm_CTG_Endnotes ON src.Bills_Pharm_CTG_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Pharm_CTG_Endnotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Pharm_CTG_Endnotes ON src.Bills_Pharm_CTG_Endnotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
