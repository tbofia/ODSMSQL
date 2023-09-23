IF OBJECT_ID('src.Line', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Line
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  BillSeq INT NOT NULL ,
			  LineSeq SMALLINT NOT NULL ,
			  DupClientCode CHAR (4) NULL ,
			  DupBillSeq INT NULL ,
			  DOS DATETIME NULL ,
			  ProcType CHAR (1) NULL ,
			  PPOOverride MONEY NULL ,
			  ClientLineType VARCHAR (5) NULL ,
			  ProvType CHAR (3) NULL ,
			  URQtyAllow SMALLINT NULL ,
			  URQtySvd SMALLINT NULL ,
			  DOSTo DATETIME NULL ,
			  URAllow MONEY NULL ,
			  URCaseSeq INT NULL ,
			  RevenueCode CHAR (4) NULL ,
			  ProcBilled VARCHAR (30) NULL ,
			  URReviewSeq SMALLINT NULL ,
			  URPriority SMALLINT NULL ,
			  ProcCode VARCHAR (30) NULL ,
			  Units DECIMAL(11,3) NULL ,
			  AllowUnits DECIMAL(11,3) NULL ,
			  Charge MONEY NULL ,
			  BRAllow MONEY NULL ,
			  PPOAllow MONEY NULL ,
			  PayOverride MONEY NULL ,
			  ProcNew VARCHAR (30) NULL ,
			  AdjAllow MONEY NULL ,
			  ReevalAmount MONEY NULL ,
			  POS CHAR (2) NULL ,
			  DxRefList VARCHAR (30) NULL ,
			  TOS CHAR (2) NULL ,
			  ReevalTxtPtr SMALLINT NULL ,
			  FSAmount MONEY NULL ,
			  UCAmount MONEY NULL ,
			  CoPay MONEY NULL ,
			  Deductible MONEY NULL ,
			  CostToChargeRatio FLOAT NULL ,
			  RXNumber VARCHAR (20) NULL ,
			  DaysSupply SMALLINT NULL ,
			  DxRef VARCHAR (4) NULL ,
			  ExternalID VARCHAR (30) NULL ,
			  ItemCostInvoiced MONEY NULL ,
			  ItemCostAdditional MONEY NULL ,
			  Refill CHAR (1) NULL ,
			  ProvSecondaryID VARCHAR (30) NULL ,
			  Certification CHAR (1) NULL ,
			  ReevalTxtSrc VARCHAR (3) NULL ,
			  BasisOfCost CHAR (1) NULL ,
			  DMEFrequencyCode CHAR (1) NULL ,
			  ProvRenderingNPI VARCHAR (10) NULL ,
			  ProvSecondaryIDQualifier CHAR (2) NULL ,
			  PaidProcCode VARCHAR (30) NULL ,
			  PaidProcType VARCHAR (3) NULL ,
			  URStatus CHAR (1) NULL ,
			  URWorkflowStatus CHAR (1) NULL ,
			  OverrideAllowUnits DECIMAL(11,3) NULL ,
			  LineSeqOrgRev SMALLINT NULL ,
			  ODGFlag SMALLINT NULL ,
			  CompoundDrugIndicator CHAR (1) NULL ,
			  PriorAuthNum VARCHAR (50) NULL ,
			  ReevalParagraphJurisdiction CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Line ADD 
     CONSTRAINT PK_Line PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq, LineSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Line ON src.Line   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.Line')
					AND c.name = 'Units' 
					AND NOT ( t.name = 'DECIMAL' 
						 AND c.precision = CAST(PARSENAME(REPLACE('11,3',',','.'),2) AS INT) 
						 AND c.scale = CAST(PARSENAME(REPLACE('11,3',',','.'),1) AS INT) 
						   ) ) 
	BEGIN
		ALTER TABLE src.Line ALTER COLUMN Units DECIMAL(11,3) NULL ;
	END ; 
GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.Line')
					AND c.name = 'AllowUnits' 
					AND NOT ( t.name = 'DECIMAL' 
						 AND c.precision = CAST(PARSENAME(REPLACE('11,3',',','.'),2) AS INT) 
						 AND c.scale = CAST(PARSENAME(REPLACE('11,3',',','.'),1) AS INT) 
						   ) ) 
	BEGIN
		ALTER TABLE src.Line ALTER COLUMN AllowUnits DECIMAL(11,3) NULL ;
	END ; 
GO
IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.Line')
					AND c.name = 'OverrideAllowUnits' 
					AND NOT ( t.name = 'DECIMAL' 
						 AND c.precision = CAST(PARSENAME(REPLACE('11,3',',','.'),2) AS INT) 
						 AND c.scale = CAST(PARSENAME(REPLACE('11,3',',','.'),1) AS INT) 
						   ) ) 
	BEGIN
		ALTER TABLE src.Line ALTER COLUMN OverrideAllowUnits DECIMAL(11,3) NULL ;
	END ; 
GO


