IF OBJECT_ID('src.AcceptedTreatmentDate', 'U') IS NULL
    BEGIN
        CREATE TABLE src.AcceptedTreatmentDate
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  AcceptedTreatmentDateId int NOT NULL,
			  DemandClaimantId int  NULL,
			  TreatmentDate datetimeoffset(7) NULL,
			  Comments varchar(255) NULL,
			  TreatmentCategoryId tinyint NULL,
			  LastUpdatedBy varchar(15) NULL,
			  LastUpdatedDate datetimeoffset(7) NULL 

            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.AcceptedTreatmentDate ADD 
        CONSTRAINT PK_AcceptedTreatmentDate PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,AcceptedTreatmentDateId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_AcceptedTreatmentDate ON src.AcceptedTreatmentDate REBUILD WITH(STATISTICS_INCREMENTAL = ON);

	END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_AcceptedTreatmentDate'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_AcceptedTreatmentDate ON src.AcceptedTreatmentDate REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
