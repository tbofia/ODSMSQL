IF OBJECT_ID('stg.Bills_Pharm', 'U') IS NOT NULL 
	DROP TABLE stg.Bills_Pharm  
BEGIN
	CREATE TABLE stg.Bills_Pharm
		(
		  BillIdNo INT NULL,
		  Line_No SMALLINT NULL,
		  LINE_NO_DISP SMALLINT NULL,
		  DateOfService DATETIME NULL,
		  NDC VARCHAR (13) NULL,
		  PriceTypeCode VARCHAR (2) NULL,
		  Units REAL NULL,
		  Charged MONEY NULL,
		  Allowed MONEY NULL,
		  EndNote VARCHAR (20) NULL,
		  Override SMALLINT NULL,
		  Override_Rsn VARCHAR (10) NULL,
		  Analyzed MONEY NULL,
		  CTGPenalty MONEY NULL,
		  PrePPOAllowed MONEY NULL,
		  PPODate DATETIME NULL,
		  POS_RevCode VARCHAR (4) NULL,
		  DPAllowed MONEY NULL,
		  HCRA_Surcharge MONEY NULL,
		  EndDateOfService DATETIME NULL,
		  RepackagedNdc VARCHAR (13) NULL,
		  OriginalNdc VARCHAR (13) NULL,
		  UnitOfMeasureId TINYINT NULL,
		  PackageTypeOriginalNdc VARCHAR (2) NULL,
		  PpoCtgPenalty DECIMAL (19,4) NULL,
		  ServiceCode VARCHAR (25) NULL,
		  PreApportionedAmount DECIMAL (19,4) NULL,
		  DeductibleApplied DECIMAL (19,4) NULL,
		  BillReviewResults DECIMAL (19,4) NULL,
		  PreOverriddenDeductible DECIMAL (19,4) NULL,
		  RemainingBalance DECIMAL (19,4) NULL,
		  CtgCoPayPenalty DECIMAL (19,4) NULL,
		  PpoCtgCoPayPenaltyPercentage DECIMAL (19,4) NULL,
		  CtgVunPenalty DECIMAL (19,4) NULL,
		  PpoCtgVunPenaltyPercentage DECIMAL (19,4) NULL,
		  RenderingNpi VARCHAR (15) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

