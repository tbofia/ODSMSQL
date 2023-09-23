IF OBJECT_ID('src.CLAIMANT', 'U') IS NULL
    BEGIN
        CREATE TABLE src.CLAIMANT
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL , 
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CmtIDNo INT NOT NULL ,
              ClaimIDNo INT NULL ,
              CmtSSN VARCHAR(11) NULL ,
              CmtLastName VARCHAR(60) NULL ,
              CmtFirstName VARCHAR(35) NULL ,
              CmtMI VARCHAR(1) NULL ,
              CmtDOB DATETIME NULL ,
              CmtSEX VARCHAR(1) NULL ,
              CmtAddr1 VARCHAR(55) NULL ,
              CmtAddr2 VARCHAR(55) NULL ,
              CmtCity VARCHAR(30) NULL ,
              CmtState VARCHAR(2) NULL ,
              CmtZip VARCHAR(12) NULL ,
              CmtPhone VARCHAR(25) NULL ,
              CmtOccNo VARCHAR(11) NULL ,
              CmtAttorneyNo INT NULL ,
              CmtPolicyLimit MONEY NULL ,
              CmtStateOfJurisdiction VARCHAR(2) NULL ,
              CmtDeductible MONEY NULL ,
              CmtCoPaymentPercentage SMALLINT NULL ,
              CmtCoPaymentMax MONEY NULL ,
              CmtPPO_Eligible SMALLINT NULL ,
              CmtCoordBenefits SMALLINT NULL ,
              CmtFLCopay SMALLINT NULL ,
              CmtCOAExport DATETIME NULL ,
              CmtPGFirstName VARCHAR(30) NULL ,
              CmtPGLastName VARCHAR(30) NULL ,
              CmtDedType SMALLINT NULL ,
              ExportToClaimIQ SMALLINT NULL ,
              CmtInactive SMALLINT NULL ,
              CmtPreCertOption SMALLINT NULL ,
              CmtPreCertState VARCHAR(2) NULL ,
              CreateDate DATETIME NULL ,
              LastChangedOn DATETIME NULL ,
              OdsParticipant BIT NULL ,
              CoverageType VARCHAR(2) NULL ,
              DoNotDisplayCoverageTypeOnEOB BIT NULL ,
			  ShowAllocationsOnEob BIT NULL ,
			  SetPreAllocation BIT NULL,
			  PharmacyEligible TINYINT NULL ,
			  SendCardToClaimant TINYINT NULL,
			  ShareCoPayMaximum BIT NULL

            ) ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (DATA_COMPRESSION = PAGE);

        ALTER TABLE src.CLAIMANT ADD 
        CONSTRAINT PK_CLAIMANT PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CmtIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_CLAIMANT ON src.CLAIMANT REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Add Coveragetype column to src.claimant.
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
                        AND NAME = 'CoverageType' )
BEGIN
    ALTER TABLE src.CLAIMANT ADD CoverageType VARCHAR(2) NULL
END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
                        AND NAME = 'DoNotDisplayCoverageTypeOnEOB' )
BEGIN
    ALTER TABLE src.CLAIMANT ADD DoNotDisplayCoverageTypeOnEOB BIT NULL
END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
                        AND NAME = 'ShowAllocationsOnEob' )
BEGIN
    ALTER TABLE src.CLAIMANT ADD ShowAllocationsOnEob BIT NULL
END
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
                        AND NAME = 'SetPreAllocation' )
BEGIN
    ALTER TABLE src.CLAIMANT ADD SetPreAllocation BIT NULL
END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
						AND NAME = 'PharmacyEligible' )
	BEGIN
		ALTER TABLE src.CLAIMANT ADD PharmacyEligible TINYINT NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
						AND NAME = 'SendCardToClaimant' )
	BEGIN
		ALTER TABLE src.CLAIMANT ADD SendCardToClaimant TINYINT NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.CLAIMANT')
						AND NAME = 'ShareCoPayMaximum' )
	BEGIN
		ALTER TABLE src.CLAIMANT ADD ShareCoPayMaximum BIT NULL ;
	END ; 
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_CLAIMANT'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_CLAIMANT ON src.CLAIMANT REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO





