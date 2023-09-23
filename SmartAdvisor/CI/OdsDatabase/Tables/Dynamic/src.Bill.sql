IF OBJECT_ID('src.Bill', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.Bill
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
			  ClaimSeq INT NULL ,
			  ClaimSysSubSet CHAR (4) NULL ,
			  ProviderSeq BIGINT NULL ,
			  ProviderSubSet CHAR (4) NULL ,
			  PostDate DATETIME NULL ,
			  DOSFirst DATETIME NULL ,
			  Invoiced CHAR (1) NULL ,
			  InvoicedPPO CHAR (1) NULL ,
			  CreateUserID VARCHAR (2) NULL ,
			  CarrierSeqNew VARCHAR (30) NULL ,
			  DocCtrlType CHAR (2) NULL ,
			  DOSLast DATETIME NULL ,
			  PPONetworkID CHAR (2) NULL ,
			  POS CHAR (2) NULL ,
			  ProvType CHAR (3) NULL ,
			  ProvSpecialty1 VARCHAR (8) NULL ,
			  ProvZip VARCHAR (9) NULL ,
			  ProvState CHAR (2) NULL ,
			  SubmitDate DATETIME NULL ,
			  ProvInvoice VARCHAR (14) NULL ,
			  Region SMALLINT NULL ,
			  HospitalSeq INT NULL ,
			  ModUserID VARCHAR (2) NULL ,
			  Status SMALLINT NULL ,
			  StatusPrior SMALLINT NULL ,
			  BillableLines SMALLINT NULL ,
			  TotalCharge MONEY NULL ,
			  BRReduction MONEY NULL ,
			  BRFee MONEY NULL ,
			  TotalAllow MONEY NULL ,
			  TotalFee MONEY NULL ,
			  DupClientCode CHAR (4) NULL ,
			  DupBillSeq INT NULL ,
			  FupStartDate DATETIME NULL ,
			  FupEndDate DATETIME NULL ,
			  SendBackMsg1SiteCode CHAR (3) NULL ,
			  SendBackMsg1 VARCHAR (6) NULL ,
			  SendBackMsg2SiteCode CHAR (3) NULL ,
			  SendBackMsg2 VARCHAR (6) NULL ,
			  PPOReduction MONEY NULL ,
			  PPOPrc SMALLINT NULL ,
			  PPOContractID VARCHAR (30) COLLATE SQL_Latin1_General_CP1_CS_AS NULL ,
			  PPOStatus CHAR (1) NULL ,
			  PPOFee MONEY NULL ,
			  NGDReduction MONEY NULL ,
			  NGDFee MONEY NULL ,
			  URFee MONEY NULL ,
			  OtherData VARCHAR (30) NULL ,
			  ExternalStatus CHAR (1) NULL ,
			  URFlag CHAR (1) NULL ,
			  Visits SMALLINT NULL ,
			  TOS CHAR (2) NULL ,
			  TOB CHAR (1) NULL ,
			  SubProductCode CHAR (1) NULL ,
			  ForcePay CHAR (1) NULL ,
			  PmtAuth VARCHAR (4) NULL ,
			  FlowStatus CHAR (1) NULL ,
			  ConsultDate DATETIME NULL ,
			  RcvdDate DATETIME NULL ,
			  AdmissionType CHAR (1) NULL ,
			  PaidDate DATETIME NULL ,
			  AdmitDate DATETIME NULL ,
			  DischargeDate DATETIME NULL ,
			  TxBillType CHAR (1) NULL ,
			  RcvdBrDate DATETIME NULL ,
			  DueDate DATETIME NULL ,
			  Adjuster VARCHAR (25) NULL ,
			  DOI DATETIME NULL ,
			  RetCtrlFlg CHAR (1) NULL ,
			  RetCtrlNum VARCHAR (9) NULL ,
			  SiteCode CHAR (3) NULL ,
			  SourceID CHAR (2) NULL ,
			  CaseType CHAR (1) NULL ,
			  SubProductID VARCHAR (30) NULL ,
			  SubProductPrice MONEY NULL ,
			  URReduction MONEY NULL ,
			  ProvLicenseNum VARCHAR (30) NULL ,
			  ProvMedicareNum VARCHAR (20) NULL ,
			  ProvSpecialty2 VARCHAR (8) NULL ,
			  PmtExportDate DATETIME NULL ,
			  PmtAcceptDate DATETIME NULL ,
			  ClientTOB VARCHAR (5) NULL ,
			  BRFeeNet MONEY NULL ,
			  PPOFeeNet MONEY NULL ,
			  NGDFeeNet MONEY NULL ,
			  URFeeNet MONEY NULL ,
			  SubProductPriceNet MONEY NULL ,
			  BillSeqNewRev INT NULL ,
			  BillSeqOrgRev INT NULL ,
			  VocPlanSeq SMALLINT NULL ,
			  ReviewDate DATETIME NULL ,
			  AuditDate DATETIME NULL ,
			  ReevalAllow MONEY NULL ,
			  CheckNum VARCHAR (30) NULL ,
			  NegoType CHAR (2) NULL ,
			  DischargeHour CHAR (2) NULL ,
			  UB92TOB CHAR (3) NULL ,
			  MCO VARCHAR (10) NULL ,
			  DRG CHAR (3) NULL ,
			  PatientAccount VARCHAR (20) NULL ,
			  ExaminerRevFlag CHAR (1) NULL ,
			  RefProvName VARCHAR (40) NULL ,
			  PaidAmount MONEY NULL ,
			  AdmissionSource CHAR (1) NULL ,
			  AdmitHour CHAR (2) NULL ,
			  PatientStatus CHAR (2) NULL ,
			  DRGValue MONEY NULL ,
			  CompanySeq SMALLINT NULL ,
			  TotalCoPay MONEY NULL ,
			  UB92ProcMethod CHAR (1) NULL ,
			  TotalDeductible MONEY NULL ,
			  PolicyCoPayAmount MONEY NULL ,
			  PolicyCoPayPct SMALLINT NULL ,
			  DocCtrlID VARCHAR (50) NULL ,
			  ResourceUtilGroup VARCHAR (4) NULL ,
			  PolicyDeductible MONEY NULL ,
			  PolicyLimit MONEY NULL ,
			  PolicyTimeLimit SMALLINT NULL ,
			  PolicyWarningPct SMALLINT NULL ,
			  AppBenefits CHAR (1) NULL ,
			  AppAssignee CHAR (1) NULL ,
			  CreateDate DATETIME NULL ,
			  ModDate DATETIME NULL ,
			  IncrementValue SMALLINT NULL ,
			  AdjVerifRequestDate DATETIME NULL ,
			  AdjVerifRcvdDate DATETIME NULL ,
			  RenderingProvLastName VARCHAR (35) NULL ,
			  RenderingProvFirstName VARCHAR (25) NULL ,
			  RenderingProvMiddleName VARCHAR (25) NULL ,
			  RenderingProvSuffix VARCHAR (10) NULL ,
			  RereviewCount SMALLINT NULL ,
			  DRGBilled CHAR (3) NULL ,
			  DRGCalculated CHAR (3) NULL ,
			  ProvRxLicenseNum VARCHAR (30) NULL ,
			  ProvSigOnFile CHAR (1) NULL ,
			  RefProvFirstName VARCHAR (30) NULL ,
			  RefProvMiddleName VARCHAR (25) NULL ,
			  RefProvSuffix VARCHAR (10) NULL ,
			  RefProvDEANum VARCHAR (9) NULL ,
			  SendbackMsg1Subset CHAR (2) NULL ,
			  SendbackMsg2Subset CHAR (2) NULL ,
			  PPONetworkJurisdictionInd CHAR (1) NULL ,
			  ManualReductionMode SMALLINT NULL ,
			  WholesaleSalesTaxZip VARCHAR (9) NULL ,
			  RetailSalesTaxZip VARCHAR (9) NULL ,
			  PPONetworkJurisdictionInsurerSeq INT NULL ,
			  InvoicedWholesale CHAR (1) NULL ,
			  InvoicedPPOWholesale CHAR (1) NULL ,
			  AdmittingDxRef SMALLINT NULL ,
			  AdmittingDxCode VARCHAR (8) NULL ,
			  ProvFacilityNPI VARCHAR (10) NULL ,
			  ProvBillingNPI VARCHAR (10) NULL ,
			  ProvRenderingNPI VARCHAR (10) NULL ,
			  ProvOperatingNPI VARCHAR (10) NULL ,
			  ProvReferringNPI VARCHAR (10) NULL ,
			  ProvOther1NPI VARCHAR (10) NULL ,
			  ProvOther2NPI VARCHAR (10) NULL ,
			  ProvOperatingLicenseNum VARCHAR (30) NULL ,
			  EHubID VARCHAR (50) NULL ,
			  OtherBillingProviderSubset CHAR (4) NULL ,
			  OtherBillingProviderSeq BIGINT NULL ,
			  ResubmissionReasonCode CHAR (2) NULL ,
			  ContractType CHAR (2) NULL ,
			  ContractAmount MONEY NULL ,
			  PriorAuthReferralNum1 VARCHAR (30) NULL ,
			  PriorAuthReferralNum2 VARCHAR (30) NULL ,
			  DRGCompositeFactor MONEY NULL ,
			  DRGDischargeFraction MONEY NULL ,
			  DRGInpatientMultiplier MONEY NULL ,
			  DRGWeight MONEY NULL ,
			  EFTPmtMethodCode VARCHAR (3) NULL ,
			  EFTPmtFormatCode VARCHAR (10) NULL ,
			  EFTSenderDFIID VARCHAR (27) NULL ,
			  EFTSenderAcctNum VARCHAR (50) NULL ,
			  EFTOrigCoSupplCode VARCHAR (24) NULL ,
			  EFTReceiverDFIID VARCHAR (27) NULL ,
			  EFTReceiverAcctQual VARCHAR (3) NULL ,
			  EFTReceiverAcctNum VARCHAR (50) NULL ,
			  PolicyLimitResult CHAR (1) NULL ,
			  HistoryBatchNumber INT NULL ,
			  ProvBillingTaxonomy VARCHAR (11) NULL ,
			  ProvFacilityTaxonomy VARCHAR (11) NULL ,
			  ProvRenderingTaxonomy VARCHAR (11) NULL ,
			  PPOStackList VARCHAR (255) NULL ,
			  ICDVersion SMALLINT NULL ,
			  ODGFlag SMALLINT NULL ,
			  ProvBillLicenseNum VARCHAR (30) NULL ,
			  ProvFacilityLicenseNum VARCHAR (30) NULL ,
			  ProvVendorExternalID VARCHAR (30) NULL ,
			  BRActualClientCode CHAR (4) NULL ,
			  BROverrideClientCode CHAR (4) NULL ,
			  BillReevalReasonCode VARCHAR (30) NULL ,
			  PaymentClearedDate DATETIME NULL ,
			  EstimatedBRClientCode CHAR(4) NULL ,
			  EstimatedBRJuris CHAR(2) NULL ,

			  OverrideFeeControlRetail CHAR(4) NULL ,
			  OverrideFeeControlWholesale CHAR(4) NULL ,


			  StatementFromDate DATETIME NULL 			 ,StatementThroughDate DATETIME NULL 
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.Bill ADD 
     CONSTRAINT PK_Bill PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, BillSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_Bill ON src.Bill   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'PaymentClearedDate' )
	BEGIN
		ALTER TABLE src.Bill ADD PaymentClearedDate DATETIME NULL ;
	END ; 
GO




IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'EstimatedBRClientCode' )
	BEGIN
		ALTER TABLE src.Bill ADD EstimatedBRClientCode CHAR(4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'EstimatedBRJuris' )
	BEGIN
		ALTER TABLE src.Bill ADD EstimatedBRJuris CHAR(2) NULL ;
	END ; 
GO



IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'OverrideFeeControlRetail' )
	BEGIN
		ALTER TABLE src.Bill ADD OverrideFeeControlRetail CHAR(4) NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'OverrideFeeControlWholesale' )
	BEGIN
		ALTER TABLE src.Bill ADD OverrideFeeControlWholesale CHAR(4) NULL ;
	END ; 
GO





IF  EXISTS ( SELECT  1
			FROM    sys.columns c 
					INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
			WHERE   object_id = OBJECT_ID(N'src.Bill')
					AND c.name = 'PPOStackList' 
					AND NOT ( t.name = 'VARCHAR' 
						 AND c.max_length = '255'
						   ) ) 
	BEGIN
		ALTER TABLE src.Bill ALTER COLUMN PPOStackList VARCHAR(255) NULL ;
	END ; 
GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'StatementFromDate' )
	BEGIN
		ALTER TABLE src.Bill ADD StatementFromDate DATETIME NULL ;
	END ; 
GO

IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.Bill')
						AND NAME = 'StatementThroughDate' )
	BEGIN
		ALTER TABLE src.Bill ADD StatementThroughDate DATETIME NULL ;
	END ; 
GO



