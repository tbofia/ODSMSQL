IF OBJECT_ID('src.CLAIMS', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CLAIMS
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              ClaimIDNo INT NOT NULL ,
              ClaimNo VARCHAR(MAX) NULL ,
              DateLoss DATETIME NULL ,
              CV_Code VARCHAR(2) NULL ,
              DiaryIndex INT NULL ,
              LastSaved DATETIME NULL ,
              PolicyNumber VARCHAR(50) NULL ,
              PolicyHoldersName VARCHAR(30) NULL ,
              PaidDeductible MONEY NULL ,
              Status VARCHAR(1) NULL ,
              InUse VARCHAR(100) NULL ,
              CompanyID INT NULL ,
              OfficeIndex INT NULL ,
              AdjIdNo INT NULL ,
              PaidCoPay MONEY NULL ,
              AssignedUser VARCHAR(15) NULL ,
              Privatized SMALLINT NULL ,
              PolicyEffDate DATETIME NULL ,
              Deductible MONEY NULL ,
              LossState VARCHAR(2) NULL ,
              AssignedGroup INT NULL ,
              CreateDate DATETIME NULL ,
              LastChangedOn DATETIME NULL ,
              AllowMultiCoverage BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CLAIMS ADD 
        CONSTRAINT PK_CLAIMS PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CLAIMS ON src.CLAIMS REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMS')
                        AND NAME = 'AllowMultiCoverage' )
    BEGIN
        ALTER TABLE src.CLAIMS ADD AllowMultiCoverage BIT NULL;
    END;
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns c
				INNER JOIN sys.types t
					ON c.system_type_id = t.system_type_id AND c.user_type_id = t.user_type_id
                WHERE   c.object_id = OBJECT_ID(N'src.CLAIMS')
                    AND c.NAME = 'ClaimNo' 
					AND (t.name <> 'VARCHAR' OR c.max_length <> -1)
						)
    BEGIN
        ALTER TABLE src.CLAIMS ALTER COLUMN ClaimNo VARCHAR(MAX);
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CLAIMS'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CLAIMS ON src.CLAIMS REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
