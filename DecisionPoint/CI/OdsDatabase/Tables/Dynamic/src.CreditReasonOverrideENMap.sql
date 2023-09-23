IF OBJECT_ID('src.CreditReasonOverrideENMap', 'U') IS NULL
BEGIN
	CREATE TABLE src.CreditReasonOverrideENMap (
		OdsPostingGroupAuditId INT NOT NULL
		,OdsCustomerId INT NOT NULL
		,OdsCreateDate DATETIME2(7) NOT NULL
		,OdsSnapshotDate DATETIME2(7) NOT NULL
		,OdsRowIsCurrent BIT NOT NULL
		,OdsHashbytesValue VARBINARY(8000) NULL
		,DmlOperation CHAR(1) NOT NULL
		,CreditReasonOverrideENMapId INT NOT NULL
		,CreditReasonId INT NULL
		,OverrideEndnoteId SMALLINT NULL
		) ON DP_Ods_PartitionScheme (OdsCustomerId)
		WITH (DATA_COMPRESSION = PAGE);

	ALTER TABLE src.CreditReasonOverrideENMap ADD CONSTRAINT PK_CreditReasonOverrideENMap PRIMARY KEY CLUSTERED (
		OdsPostingGroupAuditId
		,OdsCustomerId
		,CreditReasonOverrideENMapId
		)
		WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_CreditReasonOverrideENMap ON src.CreditReasonOverrideENMap REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.CreditReasonOverrideENMap')
                    AND c.name = 'CreditReasonId'
                    AND t.name <> 'int')
    BEGIN
        ALTER TABLE src.CreditReasonOverrideENMap ALTER COLUMN CreditReasonId INT NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CreditReasonOverrideENMap'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CreditReasonOverrideENMap ON src.CreditReasonOverrideENMap REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
