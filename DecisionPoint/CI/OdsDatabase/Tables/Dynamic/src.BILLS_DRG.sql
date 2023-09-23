IF OBJECT_ID('src.BILLS_DRG', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.BILLS_DRG
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  BillIdNo INT NOT NULL ,
			  PricerPassThru MONEY NULL ,
			  PricerCapital_Outlier_Amt MONEY NULL ,
			  PricerCapital_OldHarm_Amt MONEY NULL ,
			  PricerCapital_IME_Amt MONEY NULL ,
			  PricerCapital_HSP_Amt MONEY NULL ,
			  PricerCapital_FSP_Amt MONEY NULL ,
			  PricerCapital_Exceptions_Amt MONEY NULL ,
			  PricerCapital_DSH_Amt MONEY NULL ,
			  PricerCapitalPayment MONEY NULL ,
			  PricerDSH MONEY NULL ,
			  PricerIME MONEY NULL ,
			  PricerCostOutlier MONEY NULL ,
			  PricerHSP MONEY NULL ,
			  PricerFSP MONEY NULL ,
			  PricerTotalPayment MONEY NULL ,
			  PricerReturnMsg VARCHAR (255) NULL ,
			  ReturnDRG VARCHAR (3) NULL ,
			  ReturnDRGDesc VARCHAR (125) NULL ,
			  ReturnMDC VARCHAR (3) NULL ,
			  ReturnMDCDesc VARCHAR (100) NULL ,
			  ReturnDRGWt REAL NULL ,
			  ReturnDRGALOS REAL NULL ,
			  ReturnADX VARCHAR (8) NULL ,
			  ReturnSDX VARCHAR (8) NULL ,
			  ReturnMPR VARCHAR (8) NULL ,
			  ReturnPR2 VARCHAR (8) NULL ,
			  ReturnPR3 VARCHAR (8) NULL ,
			  ReturnNOR VARCHAR (8) NULL ,
			  ReturnNO2 VARCHAR (8) NULL ,
			  ReturnCOM VARCHAR (255) NULL ,
			  ReturnCMI SMALLINT NULL ,
			  ReturnDCC VARCHAR (8) NULL ,
			  ReturnDX1 VARCHAR (8) NULL ,
			  ReturnDX2 VARCHAR (8) NULL ,
			  ReturnDX3 VARCHAR (8) NULL ,
			  ReturnMCI SMALLINT NULL ,
			  ReturnOR1 VARCHAR (8) NULL ,
			  ReturnOR2 VARCHAR (8) NULL ,
			  ReturnOR3 VARCHAR (8) NULL ,
			  ReturnTRI SMALLINT NULL ,
			  SOJ VARCHAR (2) NULL ,
			  OPCERT VARCHAR (7) NULL ,
			  BlendCaseInclMalp REAL NULL ,
			  CapitalCost REAL NULL ,
			  HospBadDebt REAL NULL ,
			  ExcessPhysMalp REAL NULL ,
			  SparcsPerCase REAL NULL ,
			  AltLevelOfCare REAL NULL ,
			  DRGWgt REAL NULL ,
			  TransferCapital REAL NULL ,
			  NYDrgType SMALLINT NULL ,
			  LOS SMALLINT NULL ,
			  TrimPoint SMALLINT NULL ,
			  GroupBlendPercentage REAL NULL ,
			  AdjustmentFactor REAL NULL ,
			  HospLongStayGroupPrice REAL NULL ,
			  TotalDRGCharge MONEY NULL ,
			  BlendCaseAdj REAL NULL ,
			  CapitalCostAdj REAL NULL ,
			  NonMedicareCaseMix REAL NULL ,
			  HighCostChargeConverter REAL NULL ,
			  DischargeCasePaymentRate MONEY NULL ,
			  DirectMedicalEducation MONEY NULL ,
			  CasePaymentCapitalPerDiem MONEY NULL ,
			  HighCostOutlierThreshold MONEY NULL ,
			  ISAF REAL NULL ,
			  ReturnSOI SMALLINT NULL ,
			  CapitalCostPerDischarge MONEY NULL ,
			  ReturnSOIDesc VARCHAR (20) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.BILLS_DRG ADD 
     CONSTRAINT PK_BILLS_DRG PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillIdNo) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_BILLS_DRG ON src.BILLS_DRG   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.BILLS_DRG')
					AND c.name = 'ReturnDRGDesc' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '125'
						   ) ) 
	BEGIN
		ALTER TABLE src.BILLS_DRG ALTER COLUMN ReturnDRGDesc VARCHAR(125) NULL ;
	END ; 
GO

IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.BILLS_DRG')
					AND c.name = 'ReturnMDCDesc' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '100'
						   ) ) 
	BEGIN
		ALTER TABLE src.BILLS_DRG ALTER COLUMN ReturnMDCDesc VARCHAR(100) NULL ;
	END ; 
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1 
                FROM sys.stats
                WHERE name = 'PK_BILLS_DRG' 
                AND is_incremental = 1)  BEGIN
ALTER INDEX PK_BILLS_DRG ON src.BILLS_DRG   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
END ;
GO

