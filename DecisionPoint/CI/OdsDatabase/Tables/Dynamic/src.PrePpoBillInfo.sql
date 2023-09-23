IF OBJECT_ID('src.PrePpoBillInfo', 'U') IS NULL
    BEGIN
        CREATE TABLE src.PrePpoBillInfo
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              DateSentToPPO DATETIME NULL ,
              ClaimNo VARCHAR(50) NULL ,
              ClaimIDNo INT NULL ,
              CompanyID INT NULL ,
              OfficeIndex INT NULL ,
              CV_Code VARCHAR(2) NULL ,
              DateLoss DATETIME NULL ,
              Deductible MONEY NULL ,
              PaidCoPay MONEY NULL ,
              PaidDeductible MONEY NULL ,
              LossState VARCHAR(2) NULL ,
              CmtIDNo INT NULL ,
              CmtCoPaymentMax MONEY NULL ,
              CmtCoPaymentPercentage SMALLINT NULL ,
              CmtDedType SMALLINT NULL ,
              CmtDeductible MONEY NULL ,
              CmtFLCopay SMALLINT NULL ,
              CmtPolicyLimit MONEY NULL ,
              CmtStateOfJurisdiction VARCHAR(2) NULL ,
              PvdIDNo INT NULL ,
              PvdTIN VARCHAR(15) NULL ,
              PvdSPC_List VARCHAR(50) NULL ,
              PvdTitle VARCHAR(5) NULL ,
              PvdFlags INT NULL ,
              DateSaved DATETIME NULL ,
              DateRcv DATETIME NULL ,
              InvoiceDate DATETIME NULL ,
              NoLines SMALLINT NULL ,
              AmtCharged MONEY NULL ,
              AmtAllowed MONEY NULL ,
              Region VARCHAR(50) NULL ,
              FeatureID INT NULL ,
              Flags INT NULL ,
              WhoCreate VARCHAR(15) NULL ,
              WhoLast VARCHAR(15) NULL ,
              CmtPaidDeductible MONEY NULL ,
              InsPaidLimit MONEY NULL ,
              StatusFlag VARCHAR(2) NULL ,
              CmtPaidCoPay MONEY NULL ,
              Category INT NULL ,
              CatDesc VARCHAR(1000) NULL ,
              CreateDate DATETIME NULL ,
              PvdZOS VARCHAR(12) NULL ,
              AdmissionDate DATETIME NULL ,
              DischargeDate DATETIME NULL ,
              DischargeStatus SMALLINT NULL ,
              TypeOfBill VARCHAR(4) NULL ,
              PaymentDecision SMALLINT NULL ,
              PPONumberSent SMALLINT NULL ,
              BillIDNo INT NULL ,
              LINE_NO SMALLINT NULL ,
              LINE_NO_DISP SMALLINT NULL ,
              OVER_RIDE SMALLINT NULL ,
              DT_SVC DATETIME NULL ,
              PRC_CD VARCHAR(7) NULL ,
              UNITS REAL NULL ,
              TS_CD VARCHAR(14) NULL ,
              CHARGED MONEY NULL ,
              ALLOWED MONEY NULL ,
              ANALYZED MONEY NULL ,
              REF_LINE_NO SMALLINT NULL ,
              SUBNET VARCHAR(9) NULL ,
              FEE_SCHEDULE MONEY NULL ,
              POS_RevCode VARCHAR(4) NULL ,
              CTGPenalty MONEY NULL ,
              PrePPOAllowed MONEY NULL ,
              PPODate DATETIME NULL ,
              PPOCTGPenalty MONEY NULL ,
              UCRPerUnit MONEY NULL ,
              FSPerUnit MONEY NULL ,
              HCRA_Surcharge MONEY NULL ,
              NDC VARCHAR(13) NULL ,
              PriceTypeCode VARCHAR(2) NULL ,
              PharmacyLine SMALLINT NULL ,
              Endnotes VARCHAR(50) NULL ,
              SentryEN VARCHAR(250) NULL ,
              CTGEN VARCHAR(250) NULL ,
              CTGRuleType VARCHAR(250) NULL ,
              CTGRuleID VARCHAR(250) NULL ,
              OverrideEN VARCHAR(50) NULL ,
              UserId INT NULL ,
              DateOverriden DATETIME NULL ,
              AmountBeforeOverride MONEY NULL ,
              AmountAfterOverride MONEY NULL ,
              CodesOverriden VARCHAR(50) NULL ,
              NetworkID INT NULL ,
              BillSnapshot VARCHAR(30) NULL ,
              PPOSavings MONEY NULL ,
              RevisedDate DATETIME NULL ,
              ReconsideredDate DATETIME NULL ,
              TierNumber SMALLINT NULL ,
              PPOBillInfoID INT NULL ,
              PrePPOBillInfoID INT NOT NULL,
			  CtgCoPayPenalty DECIMAL(19,4) NULL,
			  PpoCtgCoPayPenalty DECIMAL(19,4) NULL,
			  CtgVunPenalty DECIMAL(19,4) NULL,
			  PpoCtgVunPenalty DECIMAL(19,4) NULL
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.PrePpoBillInfo ADD 
        CONSTRAINT PK_PrePpoBillInfo PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PrePpoBillInfoId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_PrePpoBillInfo ON src.PrePpoBillInfo REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF EXISTS ( SELECT  1
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.PrePpoBillInfo')
                    AND c.name = 'Region'
                    AND NOT ( t.name = 'VARCHAR'
                              AND c.max_length = 50
                            ) )
    BEGIN
        ALTER TABLE src.PrePpoBillInfo ALTER COLUMN Region VARCHAR(50) NULL;
    END;
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME = 'CtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.PrePPOBillInfo ADD CtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME = 'PpoCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.PrePPOBillInfo ADD PpoCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME = 'CtgVunPenalty' )
	BEGIN
		ALTER TABLE src.PrePPOBillInfo ADD CtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME = 'PpoCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.PrePPOBillInfo ADD PpoCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME =  'PpoCtgCoPayPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.PrePPOBillInfo.PpoCtgCoPayPenalty' ,  'PpoCtgCoPayPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.PrePPOBillInfo')
						AND NAME =  'PpoCtgVunPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.PrePPOBillInfo.PpoCtgVunPenalty' ,  'PpoCtgVunPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_PrePpoBillInfo'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_PrePpoBillInfo ON src.PrePpoBillInfo REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO



