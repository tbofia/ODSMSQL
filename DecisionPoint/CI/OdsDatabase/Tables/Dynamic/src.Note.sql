IF OBJECT_ID('src.Note', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Note
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  NoteId int NOT NULL,
	          DateCreated datetimeoffset(7) NULL,
	          DateModified datetimeoffset(7) NULL,
	          CreatedBy varchar(15) NULL,
	          ModifiedBy varchar(15) NULL,
	          Flag tinyint NULL,
	          Content varchar(250) NULL,
	          NoteContext smallint NULL,
	          DemandClaimantId int NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Note ADD 
        CONSTRAINT PK_Note PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,NoteId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Note ON src.Note REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Note'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Note ON src.Note REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
