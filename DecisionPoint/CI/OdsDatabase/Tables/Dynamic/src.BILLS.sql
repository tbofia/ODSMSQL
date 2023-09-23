IF OBJECT_ID('src.BILLS', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BILLS
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillIDNo INT NOT NULL ,
              LINE_NO SMALLINT NOT NULL ,
              LINE_NO_DISP SMALLINT NULL ,
              OVER_RIDE SMALLINT NULL ,
              DT_SVC DATETIME NULL ,
              PRC_CD VARCHAR(7) NULL ,
              UNITS REAL NULL ,
              TS_CD VARCHAR(14) NULL ,
              CHARGED MONEY NULL ,
              ALLOWED MONEY NULL ,
              ANALYZED MONEY NULL ,
              REASON1 INT NULL ,
              REASON2 INT NULL ,
              REASON3 INT NULL ,
              REASON4 INT NULL ,
              REASON5 INT NULL ,
              REASON6 INT NULL ,
              REASON7 INT NULL ,
              REASON8 INT NULL ,
              REF_LINE_NO SMALLINT NULL ,
              SUBNET VARCHAR(9) NULL ,
              OverrideReason SMALLINT NULL ,
              FEE_SCHEDULE MONEY NULL ,
              POS_RevCode VARCHAR(4) NULL ,
              CTGPenalty MONEY NULL ,
              PrePPOAllowed MONEY NULL ,
              PPODate DATETIME NULL ,
              PPOCTGPenalty MONEY NULL ,
              UCRPerUnit MONEY NULL ,
              FSPerUnit MONEY NULL ,
              HCRA_Surcharge MONEY NULL ,
              EligibleAmt MONEY NULL ,
              DPAllowed MONEY NULL ,
              EndDateOfService DATETIME NULL ,
              AnalyzedCtgPenalty DECIMAL(19, 4) NULL ,
              AnalyzedCtgPpoPenalty DECIMAL(19, 4) NULL ,
              RepackagedNdc VARCHAR(13) NULL ,
              OriginalNdc VARCHAR(13) NULL ,
              UnitOfMeasureId TINYINT NULL ,
              PackageTypeOriginalNdc VARCHAR(2) NULL ,
			  ServiceCode VARCHAR(25) NULL ,
			  PreApportionedAmount DECIMAL(19,4) NULL ,
			  DeductibleApplied DECIMAL(19,4) NULL,
			  BillReviewResults DECIMAL(19,4) NULL,
			  PreOverriddenDeductible DECIMAL(19,4) NULL,
		      RemainingBalance DECIMAL (19,4) NULL,
			  CtgCoPayPenalty DECIMAL(19,4) NULL,
			  PpoCtgCoPayPenalty DECIMAL(19,4) NULL,
			  AnalyzedCtgCoPayPenalty DECIMAL(19,4) NULL,
			  AnalyzedPpoCtgCoPayPenalty DECIMAL(19,4) NULL,
			  CtgVunPenalty DECIMAL(19,4) NULL,
			  PpoCtgVunPenalty DECIMAL(19,4) NULL,
			  AnalyzedCtgVunPenalty DECIMAL(19,4) NULL,
			  AnalyzedPpoCtgVunPenalty DECIMAL(19,4) NULL

			 ,RenderingNpi VARCHAR(15) NULL 
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BILLS ADD 
        CONSTRAINT PK_Bills PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIDNo, LINE_NO) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills ON src.BILLS REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'ChargemasterCode' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.BillS.ChargemasterCode' , 'ServiceCode' , 'COLUMN'
			ALTER TABLE src.Bills ALTER COLUMN ServiceCode VARCHAR(25) NULL ;
		COMMIT TRANSACTION
	END 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'ServiceCode' )
	BEGIN
		ALTER TABLE src.BILLS ADD ServiceCode VARCHAR(25) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'PreApportionedAmount' )
	BEGIN
		ALTER TABLE src.BILLS ADD PreApportionedAmount DECIMAL(19,4) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'DeductibleApplied' )
	BEGIN
		ALTER TABLE src.BILLS ADD DeductibleApplied DECIMAL(19,4) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'PreOverriddenDeductible' )
	BEGIN
		ALTER TABLE src.BILLS ADD PreOverriddenDeductible DECIMAL(19,4) NULL ;
	END ; 
GO

SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME =  'PreDeductibleAllowed' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.BILLS.PreDeductibleAllowed' ,  'BillReviewResults'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'BillReviewResults' )
	BEGIN
		ALTER TABLE src.BILLS ADD BillReviewResults DECIMAL(19,4) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.BILLS')
						AND NAME = 'RemainingBalance' )
	BEGIN
		ALTER TABLE src.BILLS ADD RemainingBalance DECIMAL(19,4) NULL ;
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'CtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD CtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'PpoCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD PpoCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'AnalyzedCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD AnalyzedCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'AnalyzedPpoCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD AnalyzedPpoCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'CtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD CtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'PpoCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD PpoCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'AnalyzedCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD AnalyzedCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'AnalyzedPpoCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills ADD AnalyzedPpoCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME = 'RenderingNpi' )
	BEGIN
		ALTER TABLE src.Bills ADD RenderingNpi VARCHAR(15) NULL ;
	END ; 
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME =  'PpoCtgCoPayPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills.PpoCtgCoPayPenalty' ,  'PpoCtgCoPayPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME =  'AnalyzedPpoCtgCoPayPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills.AnalyzedPpoCtgCoPayPenalty' ,  'AnalyzedPpoCtgCoPayPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME =  'PpoCtgVunPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills.PpoCtgVunPenalty' ,  'PpoCtgVunPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills')
						AND NAME =  'AnalyzedPpoCtgVunPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills.AnalyzedPpoCtgVunPenalty' ,  'AnalyzedPpoCtgVunPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills ON src.BILLS REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO













