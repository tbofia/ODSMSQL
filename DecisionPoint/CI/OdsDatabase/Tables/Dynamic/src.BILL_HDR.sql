IF OBJECT_ID('src.BILL_HDR', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BILL_HDR
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              CMT_HDR_IDNo INT NULL ,
              DateSaved DATETIME NULL ,
              DateRcv DATETIME NULL ,
              InvoiceNumber VARCHAR(40) NULL ,
              InvoiceDate DATETIME NULL ,
              FileNumber VARCHAR(50) NULL ,
              Note VARCHAR(20) NULL ,
              NoLines SMALLINT NULL ,
              AmtCharged MONEY NULL ,
              AmtAllowed MONEY NULL ,
              ReasonVersion SMALLINT NULL ,
              Region VARCHAR(50) NULL ,
              PvdUpdateCounter SMALLINT NULL ,
              FeatureID INT NULL ,
              ClaimDateLoss DATETIME NULL ,
              CV_Type VARCHAR(2) NULL ,
              Flags INT NULL ,
              WhoCreate VARCHAR(15) NULL ,
              WhoLast VARCHAR(15) NULL ,
              AcceptAssignment SMALLINT NULL ,
              EmergencyService SMALLINT NULL ,
              CmtPaidDeductible MONEY NULL ,
              InsPaidLimit MONEY NULL ,
              StatusFlag VARCHAR(2) NULL ,
              OfficeId INT NULL ,
              CmtPaidCoPay MONEY NULL ,
              AmbulanceMethod SMALLINT NULL ,
              StatusDate DATETIME NULL ,
              Category INT NULL ,
              CatDesc VARCHAR(1000) NULL ,
              AssignedUser VARCHAR(15) NULL ,
              CreateDate DATETIME NULL ,
              PvdZOS VARCHAR(12) NULL ,
              PPONumberSent SMALLINT NULL ,
              AdmissionDate DATETIME NULL ,
              DischargeDate DATETIME NULL ,
              DischargeStatus SMALLINT NULL ,
              TypeOfBill VARCHAR(4) NULL ,
              SentryMessage VARCHAR(1000) NULL ,
              AmbulanceZipOfPickup VARCHAR(12) NULL ,
              AmbulanceNumberOfPatients SMALLINT NULL ,
              WhoCreateID INT NULL ,
              WhoLastId INT NULL ,
              NYRequestDate DATETIME NULL ,
              NYReceivedDate DATETIME NULL ,
              ImgDocId VARCHAR(50) NULL ,
              PaymentDecision SMALLINT NULL ,
              PvdCMSId VARCHAR(6) NULL ,
              PvdNPINo VARCHAR(15) NULL ,
              DischargeHour VARCHAR(2) NULL ,
              PreCertChanged SMALLINT NULL ,
              DueDate DATETIME NULL ,
              AttorneyIDNo INT NULL ,
              AssignedGroup INT NULL ,
              LastChangedOn DATETIME NULL ,
              PrePPOAllowed MONEY NULL ,
              PPSCode SMALLINT NULL ,
              SOI SMALLINT NULL ,
              StatementStartDate DATETIME NULL ,
              StatementEndDate DATETIME NULL ,
              DeductibleOverride BIT NULL ,
              AdmissionType TINYINT NULL ,
              CoverageType VARCHAR(2) NULL ,
              PricingProfileId INT NULL ,
              DesignatedPricingState VARCHAR(2) NULL ,
              DateAnalyzed DATETIME NULL ,
              SentToPpoSysId INT NULL ,
			  PricingState VARCHAR(2) NULL,
			  BillVpnEligible  BIT NULL,
			  ApportionmentPercentage DECIMAL(5,2) NULL,
			  BillSourceId TINYINT NULL,
			  OutOfStateProviderNumber INT NULL,
			  FloridaDeductibleRuleEligible BIT NULL
            )
        ON  DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BILL_HDR ADD 
        CONSTRAINT PK_Bill_Hdr PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);
		
		ALTER INDEX PK_Bill_Hdr ON src.BILL_HDR REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END;
GO

-- Add Coveragetype column to src.Bill_Hdr.
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'CoverageType' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD CoverageType VARCHAR(2) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'PricingProfileId' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD PricingProfileId INT NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'DesignatedPricingState' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD DesignatedPricingState VARCHAR(2) NULL;
    END;
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.BILL_HDR')
                    AND c.name = 'Region'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.BILL_HDR ALTER COLUMN Region VARCHAR(50) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'DateAnalyzed' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD DateAnalyzed DATETIME NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'SentToPpoSysId' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD SentToPpoSysId INT NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'PricingState' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD PricingState VARCHAR(2) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'BillVpnEligible' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD BillVpnEligible BIT NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
                        AND NAME = 'ApportionmentPercentage' )
    BEGIN
        ALTER TABLE src.BILL_HDR ADD ApportionmentPercentage DECIMAL(5,2) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
						AND NAME = 'BillSourceId' )
	BEGIN
		ALTER TABLE src.BILL_HDR ADD BillSourceId TINYINT NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
						AND NAME = 'OutOfStateProviderNumber' )
	BEGIN
		ALTER TABLE src.BILL_HDR ADD OutOfStateProviderNumber INT NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILL_HDR')
						AND NAME = 'FloridaDeductibleRuleEligible' )
	BEGIN
		ALTER TABLE src.BILL_HDR ADD FloridaDeductibleRuleEligible BIT NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bill_Hdr'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bill_Hdr ON src.BILL_HDR REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO







