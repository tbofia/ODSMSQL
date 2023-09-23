IF OBJECT_ID('src.Bills_Pharm', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Bills_Pharm
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,  
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              BillIdNo INT NOT NULL ,
              Line_No SMALLINT NOT NULL ,
              LINE_NO_DISP SMALLINT NULL ,
              DateOfService DATETIME NULL ,
              NDC VARCHAR(13) NULL ,
              PriceTypeCode VARCHAR(2) NULL ,
              Units REAL NULL ,
              Charged MONEY NULL ,
              Allowed MONEY NULL ,
              EndNote VARCHAR(20) NULL ,
              Override SMALLINT NULL ,
              Override_Rsn VARCHAR(10) NULL ,
              Analyzed MONEY NULL ,
              CTGPenalty MONEY NULL ,
              PrePPOAllowed MONEY NULL ,
              PPODate DATETIME NULL ,
              POS_RevCode VARCHAR(4) NULL ,
              DPAllowed MONEY NULL ,
              HCRA_Surcharge MONEY NULL ,
              EndDateOfService DATETIME NULL ,
              RepackagedNdc VARCHAR(13) NULL ,
              OriginalNdc VARCHAR(13) NULL ,
              UnitOfMeasureId TINYINT NULL ,
              PackageTypeOriginalNdc VARCHAR(2) NULL ,
			  PpoCtgPenalty DECIMAL(19, 4) NULL ,
			  ServiceCode VARCHAR (25) NULL ,
              PreApportionedAmount DECIMAL(19,4) NULL,
			  DeductibleApplied DECIMAL(19,4) NULL,
			  BillReviewResults DECIMAL(19,4) NULL,
			  PreOverriddenDeductible DECIMAL(19,4) NULL,
		      RemainingBalance DECIMAL (19,4) NULL,
			  CtgCoPayPenalty DECIMAL(19,4) NULL,
              PpoCtgCoPayPenalty DECIMAL(19,4) NULL,
			  CtgVunPenalty DECIMAL(19,4) NULL,
			  PpoCtgVunPenalty DECIMAL(19,4) NULL

			 ,RenderingNpi VARCHAR(15) NULL 
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Bills_Pharm ADD 
        CONSTRAINT PK_Bills_Pharm PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo, Line_No) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Bills_Pharm ON src.Bills_Pharm REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'DeductibleApplied' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD DeductibleApplied DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PreOverriddenDeductible' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PreOverriddenDeductible DECIMAL(19,4) NULL ;
	END ; 
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME =  'PreDeductibleAllowed' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills_Pharm.PreDeductibleAllowed' ,  'BillReviewResults'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'BillReviewResults' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD BillReviewResults DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'RemainingBalance' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD RemainingBalance DECIMAL(19,4) NULL;	
	END	
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'CtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD CtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PpoCtgCoPayPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PpoCtgCoPayPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'CtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD CtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PpoCtgVunPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PpoCtgVunPenalty DECIMAL(19,4) NULL ;
	END ; 
GO


IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'RenderingNpi' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD RenderingNpi VARCHAR(15) NULL ;
	END ; 
GO


SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME =  'PpoCtgCoPayPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills_Pharm.PpoCtgCoPayPenalty' ,  'PpoCtgCoPayPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO



SET XACT_ABORT ON 
IF EXISTS ( SELECT  1
				FROM    sys.columns c 
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME =  'PpoCtgVunPenalty' )
	BEGIN
		BEGIN TRANSACTION
			EXEC SP_RENAME 'src.Bills_Pharm.PpoCtgVunPenalty' ,  'PpoCtgVunPenaltyPercentage'  , 'COLUMN' 
		COMMIT TRANSACTION
	END
GO


-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Bills_Pharm'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Bills_Pharm ON src.Bills_Pharm REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

-- Looks like this was introduced in DP 9.5 but never made it into the ODS.  MASA seems to expect is, so
-- while I'm here, let's add it.
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PpoCtgPenalty' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PpoCtgPenalty DECIMAL(19, 4) NULL;
	
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'ServiceCode' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD ServiceCode VARCHAR(25) NULL ;
	
	END 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bills_Pharm')
						AND NAME = 'PreApportionedAmount' )
	BEGIN
		ALTER TABLE src.Bills_Pharm ADD PreApportionedAmount DECIMAL(19,4) NULL;	
	END	
GO










