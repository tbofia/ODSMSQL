IF OBJECT_ID('src.Bills_OverrideEndNotes', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_OverrideEndNotes
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              OverrideEndNoteID INT NOT NULL ,
              BillIdNo INT NULL ,
              Line_No SMALLINT NULL ,
              OverrideEndNote SMALLINT NULL ,
              PercentDiscount REAL NULL ,
              ActionId SMALLINT NULL 
             
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_OverrideEndNotes ADD 
        CONSTRAINT PK_Bills_OverrideEndNotes PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, OverrideEndNoteID) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_OverrideEndNotes ON src.Bills_OverrideEndNotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_OverrideEndNotes'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_OverrideEndNotes ON src.Bills_OverrideEndNotes REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
