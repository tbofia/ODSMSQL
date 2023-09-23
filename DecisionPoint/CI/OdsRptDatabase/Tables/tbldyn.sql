IF OBJECT_ID('adm.AppVersion', 'U') IS NULL
BEGIN

    CREATE TABLE adm.AppVersion
        (
            AppVersionId INT IDENTITY(1, 1) ,
            AppVersion VARCHAR(10) NULL ,
            AppVersionDate DATETIME2(7) NULL
        );

    ALTER TABLE adm.AppVersion ADD 
    CONSTRAINT PK_AppVersion PRIMARY KEY CLUSTERED (AppVersionId);

END
GO


IF OBJECT_ID('adm.ReportJobAudit', 'U') IS NULL
BEGIN
CREATE TABLE adm.ReportJobAudit(
	ReportJobAuditId INT NOT NULL IDENTITY(1,1),
	ReportID INT NULL,
	CommandID INT NULL,
	JobStatus INT NULL,
	CmdStatus INT NULL,
	Job_StartDate DATETIME NULL,
	Job_LastUpdate DATETIME NULL,
	Cmd_LastUpdate DATETIME NULL
	);
 ALTER TABLE adm.ReportJobAudit ADD 
        CONSTRAINT PK_ReportJobAudit PRIMARY KEY CLUSTERED (ReportJobAuditId);
END
GO
IF OBJECT_ID('rpt.CustomerBillExclnListThreshold', 'U') IS NULL
BEGIN
CREATE TABLE rpt.CustomerBillExclnListThreshold(
	CustomerId int NULL,
	CustomerName varchar(250) NULL,
	CustomerDatabase varchar(250) NULL,
	BillIdNo int NULL,
	BillCreateDateYear int NULL,
	Charged money NULL,
	Allowed money NULL,
	Rundate datetime NULL
);
END
GO

IF OBJECT_ID('rpt.PrePPOBillInfo_Endnotes', 'U') IS NULL
BEGIN
CREATE TABLE rpt.PrePPOBillInfo_Endnotes(
	OdsCustomerId int NOT NULL,
	billIDNo int NULL,
	line_no int NULL,
	linetype int NULL,
	Endnotes varchar(50) NULL,
	OVER_RIDE int NULL,
	ALLOWED money NULL,
	ANALYZED money NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO


IF OBJECT_ID('dbo.AdjustorWorkspaceDemandPackage_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.AdjustorWorkspaceDemandPackage_Output(
	OdsCustomerId INT,
	Customer nvarchar(200) NULL,
	Company varchar(50) NULL,
	Office varchar(40) NULL,
	SOJ varchar(2) NULL,
	RequestedByUserName varchar(50) NULL,
	DateTimeReceived date NULL,
	DemandClaimantId int NULL,
	DemandPackageId int NULL,
	PageCount int NULL,
	Size int NULL,
	FileCount int NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END
GO

IF OBJECT_ID('dbo.AdjustorWorkspaceServiceRequested_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.AdjustorWorkspaceServiceRequested_Output(
	 OdsCustomerId INT
	,OdsPostingGroupAuditId INT 
	,DemandPackageId INT
	,DateTimeReceived datetimeoffset(7) NULL
	,DemandPackageRequestedServiceId INT
	,DemandPackageRequestedServiceName VARCHAR(100)
	,IsRush INT
	,IsSupplemental INT
	,RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END
GO

IF OBJECT_ID('dbo.DP_PerformanceReport_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.DP_PerformanceReport_Output (
	 OdsCustomerId INT NOT NULL
	,StartOfMonth datetime NOT NULL
	,Customer nvarchar(200) NOT NULL
	,Year int NOT NULL
	,Month int NOT NULL
	,Company varchar(50) NOT NULL
	,Office varchar(40) NOT NULL
	,SOJ varchar(2) NOT NULL
	,Coverage varchar(2) NOT NULL
	,Form_Type varchar(12) NOT NULL
	,ClaimIDNo int NULL
	,CmtIDNo int NULL
	,Total_Claims int NULL
	,Total_Claimants int NULL
	,Total_Bills int NULL
	,Total_Lines int NULL
	,Total_Units int NULL
	,Total_Provider_Charges money NULL
	,Total_Final_Allowed money NULL
	,Total_Reductions money NULL
	,Total_Bill_Review_Reductions money NULL
	,BillsWithOneOrMoreDuplicateLinesCount int NULL
	,PartialDuplicateBills int NULL
	,DuplicateBillsCount int NULL
	,Dup_Lines_Count int NULL
	,Duplicate_Reductions money NULL
	,BenefitsExhausted_Bills_Count int NULL
	,BenefitsExhausted_Lines_Count int NULL
	,BenefitsExhausted_Reductions money NULL
	,Analyst_Reductions money NULL
	,Fee_Schedule_Reductions money NULL
	,Benchmark_Reductions money NULL
	,CTG_Reductions money NULL
	,VPN_Reductions money NULL
	,Override_Impact money NULL
	,ReportTypeID INT NOT NULL
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	,LastUpdate datetime NULL
	);
END
GO



IF OBJECT_ID('stg.DP_PerformanceReport_BenefitsExhaustedReductions', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_BenefitsExhaustedReductions
BEGIN
CREATE TABLE stg.DP_PerformanceReport_BenefitsExhaustedReductions (
	 OdsCustomerId INT NOT NULL
	,BillIDNo INT
	,line_no INT
	,line_type INT
	,EndNote INT
	,charged MONEY
	,allowed MONEY
	,BenefitsExhaustedReductions MONEY DEFAULT 0.00
	,BenefitsExhaustedReductionsFlag INT DEFAULT 0
	,LLevel INT DEFAULT 0
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	)
END
GO
IF OBJECT_ID('stg.DP_PerformanceReport_Input', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_Input
BEGIN
CREATE TABLE stg.DP_PerformanceReport_Input (
	OdsCustomerId int NOT NULL,
	billIDNo int,
	line_type int,
	line_no int,
	CreateDate datetime,
	CompanyID int,
	Company varchar(100),
	OfficeID int,
	Office varchar(100),
	Coverage varchar(2),
	claimNo varchar(255),
	ClaimIDNo int,
	CmtIDNo int,
	SOJ varchar(2),
	Form_Type varchar(12),
	ProviderZipOfService varchar(12),
	TypeOfBill varchar(4),
	DiagnosisCode varchar(8),
	ProcedureCode varchar(15),
	ProviderSpecialty varchar(max),
	ProviderType varchar(10),
	ProviderType_Desc varchar(100),
	line_no_disp int,
	ref_line_no int,
	over_ride int,
	charged money,
	allowed money,
	PreApportionedAmount Decimal (19,4),
	analyzed money,
	units real,
	reporttype int,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO


IF OBJECT_ID('stg.DP_PerformanceReport_linelevelprioritized', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_linelevelprioritized
BEGIN
CREATE TABLE stg.DP_PerformanceReport_linelevelprioritized(
	 OdsCustomerId INT NOT NULL
	,billIDNo INT
	,line_no INT
	,line_type INT
	,BenefitsExhaustedReductions MONEY DEFAULT 0.00
	,AnalystReductions MONEY DEFAULT 0.00
	,AnalystORReductions MONEY DEFAULT 0.00
	,DuplicateReductions MONEY DEFAULT 0.00
	,BenchmarkReductions MONEY DEFAULT 0.00
	,VPNReductions MONEY DEFAULT 0.00
	,FeeScheduleReductions MONEY DEFAULT 0.00
	,CTGReductions MONEY DEFAULT 0.00
	,Overrides MONEY DEFAULT 0.00
	,VPNReductionsFlag INT DEFAULT 0
	,DuplicateReductionsFlag INT DEFAULT 0
	,BenefitsExhaustedReductionsFlag INT DEFAULT 0
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	)
END
GO

IF OBJECT_ID('stg.DP_PerformanceReport_MaxPrePPOBillInfo', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_MaxPrePPOBillInfo
BEGIN
CREATE TABLE stg.DP_PerformanceReport_MaxPrePPOBillInfo(
	 OdsCustomerId INT NOT NULL
	,billIDNo INT
	,line_no INT
	,line_type INT
	,Endnotes VARCHAR (50)
	,OVER_RIDE INT
	,ALLOWED MONEY DEFAULT 0.00
	,ANALYZED MONEY DEFAULT 0.00
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	)
END
GO

IF OBJECT_ID('stg.DP_PerformanceReport_PostVPNReductions', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_PostVPNReductions
BEGIN
CREATE TABLE stg.DP_PerformanceReport_PostVPNReductions (
	 OdsCustomerId INT NOT NULL
	,billIDNo INT
	,line_no INT
	,line_type INT
	,charged MONEY
	,allowed MONEY
	,categoryIDNo INT
	,OVER_RIDE SMALLINT
	,IsZeroAllowedDuplicateLine BIT
	,analyzed MONEY
	,AnalystReductions MONEY DEFAULT 0.00
	,AnalystORReductions MONEY DEFAULT 0.00
	,DuplicateReductions MONEY DEFAULT 0.00
	,BenchmarkReductions MONEY DEFAULT 0.00
	,VPNReductions MONEY DEFAULT 0.00
	,FeeScheduleReductions MONEY DEFAULT 0.00
	,CTGReductions MONEY DEFAULT 0.00
	,Overrides MONEY DEFAULT 0.00
	,VPNReductionsFlag INT DEFAULT 0
	,DuplicateReductionsFlag INT DEFAULT 0
	,LLevel INT DEFAULT 0
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	)
END
GO

IF OBJECT_ID('stg.DP_PerformanceReport_PreVPNReductions', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_PreVPNReductions
BEGIN
CREATE TABLE stg.DP_PerformanceReport_PreVPNReductions (
	 OdsCustomerId INT NOT NULL
	,billIDNo INT
	,line_no INT
	,line_type INT
	,charged MONEY
	,allowed MONEY
	,categoryIDNo INT
	,OVER_RIDE SMALLINT
	,IsZeroAllowedDuplicateLine BIT
	,analyzed MONEY
	,AnalystReductions MONEY DEFAULT 0.00
	,AnalystORReductions MONEY DEFAULT 0.00
	,DuplicateReductions MONEY DEFAULT 0.00
	,BenchmarkReductions MONEY DEFAULT 0.00
	,VPNReductions MONEY DEFAULT 0.00
	,FeeScheduleReductions MONEY DEFAULT 0.00
	,CTGReductions MONEY DEFAULT 0.00
	,Overrides MONEY DEFAULT 0.00
	,VPNReductionsFlag INT DEFAULT 0
	,DuplicateReductionsFlag INT DEFAULT 0
	,LLevel INT DEFAULT 0
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	)
END
GO

IF OBJECT_ID('dbo.DP_PerformanceReport_3rdParty_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.DP_PerformanceReport_3rdParty_Output(
	OdsCustomerId int NOT NULL,
	StartOfMonth datetime NOT NULL,
	Customer varchar(100) NOT NULL,
	Year int NULL,
	Month int NULL,
	Company varchar(100) NULL,
	Office varchar(100) NULL,
	SOJ varchar(2) NULL,
	Coverage varchar(2) NULL,
	Form_Type varchar(12) NULL,
	ClaimIDNo int NULL,
	CmtIDNo int NULL,
	Total_Claims int NULL,
	Total_Claimants int NULL,
	Total_Bills int NULL,
	Total_Lines int NULL,
	Total_Units float NULL,
	Total_Provider_Charges money NULL,
	Total_Final_Allowed money NULL,
	Total_Reductions money NULL,
	Total_BillAdjustments money NULL,
	Standard money NULL,
	Premium money NULL,
	FeeSchedule money NULL,
	Benchmark money NULL,
	VPN money NULL,
	Override money NULL,
	ReportTypeID int NOT NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO
IF OBJECT_ID('stg.DP_PerformanceReport_3rdParty_Adjustments', 'U') IS NOT NULL
DROP TABLE stg.DP_PerformanceReport_3rdParty_Adjustments
BEGIN
CREATE TABLE stg.DP_PerformanceReport_3rdParty_Adjustments(
	OdsCustomerId INT NOT NULL,
	billIDNo INT NULL,
	line_no INT NULL,
	line_type INT NULL,
	Standard MONEY NULL,
	Premium MONEY NULL,
	FeeSchedule MONEY NULL,
	Benchmark MONEY NULL,
	VPN money NULL,
	Override MONEY NULL,
	ReportType INT NOT NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO

IF OBJECT_ID('dbo.ERDReport', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.ERDReport (
		  OdsCustomerId INT NOT NULL,
		  ReportName VARCHAR(500) NULL,
		  CustomerName VARCHAR(500) NULL,
		  ClaimIDNo INT NULL,
		  ClaimNo VARCHAR(500) NULL,
		  ClaimantIDNo INT NULL,
		  CoverageType VARCHAR(2) NULL,
		  CoverageTypeDesc VARCHAR(200) NULL,
		  Company VARCHAR(250) NULL,
		  Office VARCHAR(250) NULL,
		  SOJ VARCHAR(2) NULL,
		  County VARCHAR(100) NULL,
		  AdjustorFirstName VARCHAR(200) NULL,
		  AdjustorLastName VARCHAR(200) NULL,
		  ClaimDateLoss DATETIME NULL,
		  LastDateOfService DATETIME NULL,
		  InjuryNatureId INT NULL,
		  InjuryNatureDesc VARCHAR(250),
		  ERDDuration_Weeks INT NULL,
		  ERDDuration_Days INT NULL,
		  AllowedTreatmentDuration_Days INT NULL,
		  AllowedTreatmentDuration_Weeks INT NULL,
		  Charged MONEY NULL,
		  Allowed MONEY NULL,
		  ChargedAfterERD MONEY NULL,
		  AllowedAfterERD MONEY NULL,
		  RunDate DATETIME NULL
		);
END
GO
IF OBJECT_ID('dbo.IndustryComparison_Output', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.IndustryComparison_Output
            (
              OdsCustomerId INT,
			  ReportName VARCHAR(50) NULL ,
              DisplayName VARCHAR(255) NULL ,
              Code VARCHAR(50) NULL ,
              [Desc] VARCHAR(MAX) NULL ,
              MajorGroup VARCHAR(200) NULL ,
              CoverageType VARCHAR(20) NULL ,
              CoverageTypeDesc VARCHAR(100) NULL ,
              FormType VARCHAR(20) NULL ,
              State VARCHAR(20) NULL ,
              County VARCHAR(50) NULL ,
              ProviderSpecialty VARCHAR(100) NULL ,
              ProviderSpecialty_Desc VARCHAR(MAX) NULL ,
              ProviderType VARCHAR(100) NULL ,
              ProviderType_Desc VARCHAR(MAX) NULL ,
              Year INT NULL ,
              Quarter VARCHAR(8) NULL ,
              DateQuarter DATETIME NULL ,
              TotalCharged MONEY NULL ,
              IndTotalCharged MONEY NULL ,
              TotalAllowed MONEY NULL ,
              IndTotalAllowed MONEY NULL ,
              ClaimCnt INT NULL ,
              IndClaimCnt INT NULL ,
              ClaimantCnt INT NULL ,
              IndClaimantCnt INT NULL ,
              TotalReduction MONEY NULL ,
              IndTotalReduction MONEY NULL ,
              TotalBills INT NULL ,
              IndTotalBills INT NULL ,
              TotalLines INT NULL ,
              IndTotalLines INT NULL ,
              TotalUnits NUMERIC(9,2) NULL ,
              IndTotalUnits NUMERIC(9,2) NULL ,
              RunDate DATETIME DEFAULT GETDATE() NOT NULL
            );
    END;
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.IndustryComparison_Output')
                        AND NAME = 'CreateDate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.IndustryComparison_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.IndustryComparison_Output.CreateDate', 'RunDate', 'COLUMN'; 
    END;
GO



IF OBJECT_ID('stg.IndustryComparison_CountyClient', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_CountyClient
BEGIN
 CREATE TABLE stg.IndustryComparison_CountyClient(
	 ReportName Varchar(50) 
	,OdsCustomerID int
	,CoverageType Varchar(20)
	,FormType Varchar(20)
	,State Varchar(20)
	,County Varchar(50)
	,Year Int
	,Quarter Int
	,TotalClaims Int
	,TotalClaimants Int
	,TotalCharged Money
	,TotalAllowed Money
	,TotalReductions Money
	,TotalBills Int
	,TotalUnits real
	,TotalLines Int
)
END
GO
IF OBJECT_ID('stg.IndustryComparison_CountyIndustry', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_CountyIndustry
BEGIN
CREATE TABLE stg.IndustryComparison_CountyIndustry(
	ReportName varchar(6) NOT NULL,
	CoverageType varchar(20) NULL,
	FormType varchar(20) NULL,
	State varchar(20) NULL,
	County varchar(50) NULL,
	Year int NULL,
	Quarter int NULL,
	IndTotalClaims int NULL,
	IndTotalClaimants int NULL,
	IndTotalCharged money NULL,
	IndTotalAllowed money NULL,
	IndTotalReductions money NULL,
	IndTotalBills int NULL,
	IndTotalUnits numeric(9, 2) NULL,
	IndTotalLines int NULL
)
END
GO


IF OBJECT_ID('stg.IndustryComparison_DiagnosisCodeClient', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_DiagnosisCodeClient 
BEGIN
 CREATE TABLE stg.IndustryComparison_DiagnosisCodeClient(
	 ReportName Varchar(50) 
	,OdsCustomerID int
	,CoverageType Varchar(20)
	,FormType Varchar(20)
	,State Varchar(20)
	,County Varchar(50)
	,Year Int
	,Quarter Int
	,DiagnosisCode Varchar(50)
	,TotalClaims Int
	,TotalClaimants Int
	,TotalCharged Money
	,TotalAllowed Money
	,TotalReductions Money
	,TotalBills Int
	,TotalUnits real
	,TotalLines Int
)
END 
GO
IF OBJECT_ID('stg.IndustryComparison_DiagnosisCodeIndustry', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_DiagnosisCodeIndustry
BEGIN
CREATE TABLE stg.IndustryComparison_DiagnosisCodeIndustry(
	ReportName varchar(9) NOT NULL,
	CoverageType varchar(20) NULL,
	FormType varchar(20) NULL,
	State varchar(20) NULL,
	County varchar(50) NULL,
	Year int NULL,
	Quarter int NULL,
	DiagnosisCode varchar(50) NULL,
	IndTotalClaims int NULL,
	IndTotalClaimants int NULL,
	IndTotalCharged money NULL,
	IndTotalAllowed money NULL,
	IndTotalReductions money NULL,
	IndTotalBills int NULL,
	IndTotalUnits numeric(9, 2) NULL,
	IndTotalLines int NULL
)
END
GO


IF OBJECT_ID('stg.IndustryComparison_ProcedureCodeClient', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_ProcedureCodeClient
BEGIN
 CREATE TABLE stg.IndustryComparison_ProcedureCodeClient(
	 ReportName Varchar(50) 
	,OdsCustomerID int
	,CoverageType Varchar(20)
	,FormType Varchar(20)
	,State Varchar(20)
	,County Varchar(50)
	,Year Int
	,Quarter Int
	,ProcedureCode Varchar(50)
	,TotalClaims Int
	,TotalClaimants Int
	,TotalCharged Money
	,TotalAllowed Money
	,TotalReductions Money
	,TotalBills Int
	,TotalUnits real
	,TotalLines Int
	)
END
GO
IF OBJECT_ID('stg.IndustryComparison_ProcedureCodeIndustry', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_ProcedureCodeIndustry
BEGIN
CREATE TABLE stg.IndustryComparison_ProcedureCodeIndustry(
	ReportName varchar(13) NOT NULL,
	CoverageType varchar(20) NULL,
	FormType varchar(20) NULL,
	State varchar(20) NULL,
	County varchar(50) NULL,
	Year int NULL,
	Quarter int NULL,
	ProcedureCode varchar(50) NULL,
	IndTotalClaims int NULL,
	IndTotalClaimants int NULL,
	IndTotalCharged money NULL,
	IndTotalAllowed money NULL,
	IndTotalReductions money NULL,
	IndTotalBills int NULL,
	IndTotalUnits numeric(9, 2) NULL,
	IndTotalLines int NULL
)
END
GO


IF OBJECT_ID('stg.IndustryComparison_ProviderSpecialtyClient', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_ProviderSpecialtyClient
BEGIN
 CREATE TABLE stg.IndustryComparison_ProviderSpecialtyClient(
	 ReportName Varchar(50) 
	,OdsCustomerID int
	,CoverageType Varchar(20)
	,FormType Varchar(20)
	,State Varchar(20)
	,County Varchar(50)
	,Year Int
	,Quarter Int
	,ProviderSpecialty Varchar(50)
	,TotalClaims Int
	,TotalClaimants Int
	,TotalCharged Money
	,TotalAllowed Money
	,TotalReductions Money
	,TotalBills Int
	,TotalUnits real
	,TotalLines Int
	)
END
GO
IF OBJECT_ID('stg.IndustryComparison_ProviderSpecialtyIndustry', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_ProviderSpecialtyIndustry
BEGIN
CREATE TABLE stg.IndustryComparison_ProviderSpecialtyIndustry(
	ReportName varchar(17) NOT NULL,
	CoverageType varchar(20) NULL,
	FormType varchar(20) NULL,
	State varchar(20) NULL,
	County varchar(50) NULL,
	Year int NULL,
	Quarter int NULL,
	ProviderSpecialty varchar(50) NULL,
	IndTotalClaims int NULL,
	IndTotalClaimants int NULL,
	IndTotalCharged money NULL,
	IndTotalAllowed money NULL,
	IndTotalReductions money NULL,
	IndTotalBills int NULL,
	IndTotalUnits numeric(9, 2) NULL,
	IndTotalLines int NULL
)
END
GO


IF OBJECT_ID('stg.IndustryComparison_ProviderTypeClient', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_ProviderTypeClient
BEGIN
 CREATE TABLE stg.IndustryComparison_ProviderTypeClient(
	 ReportName Varchar(50) 
	,OdsCustomerID int
	,CoverageType Varchar(20)
	,FormType Varchar(20)
	,State Varchar(20)
	,County Varchar(50)
	,Year Int
	,Quarter Int
	,ProviderType Varchar(50)
	,TotalClaims Int
	,TotalClaimants Int
	,TotalCharged Money
	,TotalAllowed Money
	,TotalReductions Money
	,TotalBills Int
	,TotalUnits real
	,TotalLines Int
	)
END
GO
IF OBJECT_ID('stg.IndustryComparison_ProviderTypeIndustry', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_ProviderTypeIndustry
BEGIN
CREATE TABLE stg.IndustryComparison_ProviderTypeIndustry(
	ReportName varchar(12) NOT NULL,
	CoverageType varchar(20) NULL,
	FormType varchar(20) NULL,
	State varchar(20) NULL,
	County varchar(50) NULL,
	Year int NULL,
	Quarter int NULL,
	ProviderType varchar(50) NULL,
	IndTotalClaims int NULL,
	IndTotalClaimants int NULL,
	IndTotalCharged money NULL,
	IndTotalAllowed money NULL,
	IndTotalReductions money NULL,
	IndTotalBills int NULL,
	IndTotalUnits numeric(9, 2) NULL,
	IndTotalLines int NULL
)
END
GO
IF OBJECT_ID('dbo.LossYearReport', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.LossYearReport (
		 ReportName VARCHAR(255) NOT NULL
		,OdsCustomerId INT NOT NULL
		,CustomerName VARCHAR(255) NOT NULL
		,CompanyName VARCHAR(max) NULL
		,SOJ VARCHAR(2) NULL
		,AgeGroup VARCHAR(100) NULL
		,YOL VARCHAR(4) NULL
		,Year INT NULL
		,Quarter VARCHAR(8) NULL
		,DateQuarter DATETIME NULL
		,FormType VARCHAR(20) NULL
		,CoverageType VARCHAR(5) NULL
		,CoverageTypeDesc VARCHAR(100) NULL
		,InjuryNatureId INT NULL
	    ,InjuryNatureDesc VARCHAR(MAX) NULL
		,EncounterTypeId INT NULL
		,EncounterTypeDesc VARCHAR(MAX) NULL
		,Period VARCHAR(100) NULL
		,ServiceGroup VARCHAR(max) NULL
		,RevenueGroup VARCHAR(max) NULL
		,BillType VARCHAR(200) NULL
		,Gender VARCHAR(2) NULL
		,OutlierCat VARCHAR(max) NULL
		,ClaimantState VARCHAR(2) NULL
		,ClaimantCounty VARCHAR(100) NULL
		,ProviderState VARCHAR(2) NULL
		,ProviderSpecialty VARCHAR(500) NULL
		,PlaceOfService VARCHAR(250) NULL
		,InjuryType VARCHAR(500) NULL
		,ClaimCnt INT NULL
		,IndClaimCnt INT NULL
		,ClaimantCnt INT NULL
		,IndClaimantCnt INT NULL
		,ProviderCnt INT NULL
		,IndProviderCnt INT NULL
		,BillCnt INT NULL
		,IndBillCnt INT NULL
		,DOSCnt INT NULL
		,IndDOSCnt INT NULL
		,LineCnt INT NULL
		,IndLineCnt INT NULL
		,UnitsCnt INT NULL
		,IndUnitsCnt INT NULL
		,Charged MONEY NULL
		,IndCharged MONEY NULL
		,Allowed MONEY NULL
		,IndAllowed MONEY NULL
		,IsAllowedGreaterThanZero INT NULL
		,RunDate DATETIME NOT NULL DEFAULT GETDATE()
		)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO

IF OBJECT_ID('stg.LossYearReport_Client', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_Client; 
BEGIN
CREATE TABLE stg.LossYearReport_Client 
(
		 ReportID INT
		,ReportName VARCHAR(500)
		,OdsCustomerID INT
		,CompanyName VARCHAR(50)
		,SOJ VARCHAR(2)
		,AgeGroup VARCHAR(50)
		,DateQuarter DATETIME
		,FormType VARCHAR(12)
		,CoverageType VARCHAR(2)
		,EncounterTypePriority INT NULL
		,ServiceGroup VARCHAR(500)
		,RevenueCodeCategoryId INT NULL
		,Gender VARCHAR(3)
		,Outlier_cat VARCHAR(100)
		,ClaimantState VARCHAR(2)
		,ClaimantCounty VARCHAR(200)
		,ProviderSpecialty VARCHAR(50)
		,ProviderState VARCHAR(2)
		,IsAllowedGreaterThanZero INT NULL
		,Allowed MONEY
		,Charged MONEY
		,Units REAL
		,ClaimantCnt INT
		,DOSCnt INT
		,InjuryNatureId INT NULL
		,Period VARCHAR(100) NULL
	    
);
END
GO






IF OBJECT_ID('stg.LossYearReport_EncounterTypeId', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_EncounterTypeId; 
BEGIN

	CREATE TABLE stg.LossYearReport_EncounterTypeId(
		OdsCustomerId INT NULL,
		BillIDNo INT NULL,
		EncounterTypeId INT NULL,
		RunDate DATETIME NOT NULL
	);

END
GO


IF OBJECT_ID('stg.LossYearReport_Filtered', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_Filtered
BEGIN
	CREATE TABLE stg.LossYearReport_Filtered (
		OdsCustomerId INT NOT NULL
		,CompanyName VARCHAR(50) NULL
		,SOJ VARCHAR(2) NULL
		,AgeGroup VARCHAR(50) NULL
		,DateQuarter DATETIME NULL
		,FormType VARCHAR(12) NULL
		,CoverageType VARCHAR(2) NULL
		,EncounterTypePriority INT NULL
		,ServiceGroup VARCHAR(500) NULL
		,RevenueCodeCategoryId INT NULL
		,Gender VARCHAR(2) NULL
		,Outlier_cat VARCHAR(100) NULL
		,ClaimantState VARCHAR(2) NULL
		,ClaimantCounty VARCHAR(50) NULL
		,ProviderSpecialty VARCHAR(50) NULL
		,ProviderState VARCHAR(10) NULL
		,InjuryNatureId INT NULL
		,CmtIdNo INT NULL
		,DT_SVC DATETIME NULL
		,Period VARCHAR(80) NULL
		,IsAllowedGreaterThanZero INT NOT NULL
		,Allowed MONEY NULL
		,Charged MONEY NULL
		,Units REAL NULL
		);
END
GO
IF OBJECT_ID('stg.LossYearReport_Industry', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_Industry
BEGIN
CREATE TABLE stg.LossYearReport_Industry (
	 ReportID INT NULL
	,ReportName VARCHAR(500) NULL
	,SOJ VARCHAR(2) NULL
	,AgeGroup VARCHAR(50) NULL
	,DateQuarter DATETIME NULL
	,FormType VARCHAR(12) NULL
	,CoverageType VARCHAR(2) NULL
	,EncounterTypePriority INT NULL
	,ServiceGroup VARCHAR(500) NULL
	,RevenueCodeCategoryId INT NULL
	,Gender VARCHAR(3) NULL
	,Outlier_cat VARCHAR(100) NULL
	,ClaimantState VARCHAR(2) NULL
	,ClaimantCounty VARCHAR(200) NULL
	,ProviderSpecialty VARCHAR(50) NULL
	,ProviderState VARCHAR(2) NULL
	,IsAllowedGreaterThanZero INT NULL
	,IndAllowed MONEY NULL
	,IndCharged MONEY NULL
	,IndUnits FLOAT NULL
	,IndClaimantCnt INT NULL
	,IndDOSCnt INT NULL
	,InjuryNatureId INT NULL
	,Period VARCHAR(100) NULL
	
);
END
GO

IF OBJECT_ID('stg.LossYearReport_Input', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_Input;
BEGIN
CREATE TABLE stg.LossYearReport_Input (
	 OdsCustomerId INT NOT NULL
	,BillIDNo INT NULL
	,LINE_NO INT NULL
	,LineType INT NULL
	,CMT_HDR_IDNo INT NULL
	,ClaimIDNo INT NULL
	,CmtIDNo INT NULL
	,DateLoss DATETIME NULL
	,CreateDate DATETIME NULL
	,AnchorDate DATETIME NULL
	,AnchorDateQuarter DATETIME NULL
	,OfficeId INT NULL
	,PvdZOS VARCHAR(12) NULL
	,[State] VARCHAR(10) NULL
	,County VARCHAR(50) NULL
	,TypeOfBill VARCHAR(4) NULL
	,BillTypeDesc VARCHAR(max) NULL
	,CV_Code VARCHAR(2) NULL
	,Form_Type VARCHAR(12) NULL
	,Migrated INT NULL
	,AdmissionDate DATETIME NULL
	,DischargeDate DATETIME NULL
	,CmtDOB DATETIME NULL
	,CmtSEX VARCHAR(2) NULL
	,CmtSOJ VARCHAR(2) NULL
	,CmtState VARCHAR(2) NULL
	,CmtCounty VARCHAR(50) NULL
	,CmtZip VARCHAR(12) NULL
	,CompanyName VARCHAR(50) NULL
	,PRC_CD VARCHAR(20) NULL
	,POS_RevCode VARCHAR(20) NULL
	,POSDesc VARCHAR(255) NULL
	,DT_SVC DATETIME NULL
	,PvdIDNo INT NULL
	,PvdZip VARCHAR(12) NULL
	,PvdSPC_List VARCHAR(50) NULL
	,PvdTitle VARCHAR(5) NULL
	,Cmt_Allowed Money NULL
	,CHARGED money NULL
	,ALLOWED money NULL
	,UNITS real NULL
	,DX VARCHAR(10) NULL
	,DX_SeqNum SMALLINT NULL
	,DX_IcdVersion tinyINT NULL
	,ICD VARCHAR(10) NULL
	,ICD_SeqNum SMALLINT NULL
	,ICD_IcdVersion tinyINT NULL
	,Period_Days INT NULL
	,Period VARCHAR(80) NULL
	,Age INT NULL
	,AgeGroup VARCHAR(50) NULL
	,Outlier_cat VARCHAR(100) NULL
	,Bill_Type VARCHAR(100) NULL
	,DX_Score float NULL
	,ER_Bill_Flag INT NULL
	,RevenueCodeCategoryId INT NULL
	,YOL INT NULL
	,ServiceGroup VARCHAR(500) NULL
	,Outlier INT NULL
	,InjuryNatureId INT NULL
	,EncounterTypeId INT NULL
	,RunDate DATETIME NOT NULL DEFAULT GETDATE()
	
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO
IF OBJECT_ID('dbo.PPO_ActivityReport_MasterCoverage_Flashback', 'U') IS NULL
BEGIN
CREATE TABLE dbo.PPO_ActivityReport_MasterCoverage_Flashback(
	OdsCustomerId int NOT NULL,
	StartOfMonth datetime NOT NULL,
	Customer varchar(100) NOT NULL,
	Year int NOT NULL,
	Month int NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	SOJ varchar(2) NOT NULL,
	Coverage varchar(2) NOT NULL,
	Form_Type varchar(8) NOT NULL,
	Total_Bills float NULL,
	Total_Provider_Charges money NULL,
	Total_Bill_Review_Reductions money NULL,
	ReportTypeID int NOT NULL,
	RunDate datetime NOT NULL
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PPO_ActivityReport_MasterCoverage_Flashback'
		AND COLUMN_NAME = 'Total_Bills'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.PPO_ActivityReport_MasterCoverage_Flashback
	ALTER COLUMN Total_Bills FLOAT;

END



IF OBJECT_ID('dbo.PPO_ActivityReport_MasterCoverage_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.PPO_ActivityReport_MasterCoverage_Output(
	OdsCustomerId int NOT NULL,
	StartOfMonth datetime NOT NULL,
	Customer varchar(100) NOT NULL,
	Year int NOT NULL,
	Month int NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	SOJ varchar(2) NOT NULL,
	Coverage varchar(2) NOT NULL,
	Form_Type varchar(8) NOT NULL,
	Total_Bills float NULL,
	Total_Provider_Charges money NULL,
	Total_Bill_Review_Reductions money NULL,
	ReportTypeID int NOT NULL,
	RunDate datetime NOT NULL
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO


IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'PPO_ActivityReport_MasterCoverage_Output'
		AND COLUMN_NAME = 'Total_Bills'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.PPO_ActivityReport_MasterCoverage_Output
	ALTER COLUMN Total_Bills FLOAT;

END
GO

IF OBJECT_ID('dbo.VPN_Monitoring_NetworkRepricedSubmitted_Flashback', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Flashback(
	StartOfMonth datetime NULL,
	OdsCustomerId int NULL,
	Customer varchar(100) NULL,
	SOJ varchar(2) NULL,
	NetworkName varchar(50) NULL,
	BillType varchar(8) NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	CV_Type varchar(2) NULL,
	Company varchar(50) NULL,
	Office varchar(40) NULL,
	BillsCount float NOT NULL,
	BillsRepriced float NOT NULL,
	ProviderCharges money NOT NULL,
	BRAllowable money NOT NULL,
	InNetworkCharges money NOT NULL,
	InNetworkAmountAllowed money NOT NULL,
	Savings money NOT NULL,
	Credits money NOT NULL,
	NetSavings money NOT NULL,
	ReportTypeId INT NULL,
	RunDate datetime NOT NULL);
END
GO



IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkRepricedSubmitted_Flashback'
		AND COLUMN_NAME = 'BillsCount'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Flashback
	ALTER COLUMN BillsCount FLOAT;

END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkRepricedSubmitted_Flashback'
		AND COLUMN_NAME = 'BillsRePriced'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Flashback
	ALTER COLUMN BillsRePriced FLOAT;

END
GO
IF OBJECT_ID('dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback(
	StartOfMonth datetime NULL,
	OdsCustomerId int NOT NULL,
	Customer varchar(100) NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	SOJ varchar(2) NOT NULL,
	BillType varchar(8) NOT NULL,
	CV_Type varchar(2) NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	InNetworkCharges money NULL,
	InNetworkAmountAllowed money NULL,
	Savings money NULL,
	Credits money NULL,
	NetSavings money NULL,
	BillsCount float NULL,
	BillsRePriced float NULL,
	ProviderCharges money NULL,
	BRAllowable money NULL,
	ReportTypeId INT NULL,
	RunDate datetime NOT NULL);
END
GO


IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkUniqueSubmitted_Flashback'
		AND COLUMN_NAME = 'BillsCount'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback
	ALTER COLUMN BillsCount FLOAT;

END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkUniqueSubmitted_Flashback'
		AND COLUMN_NAME = 'BillsRePriced'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Flashback
	ALTER COLUMN BillsRePriced FLOAT;

END
GO

IF OBJECT_ID('stg.PPO_ActivityReport_MasterCoverage_Input', 'U') IS NOT NULL
DROP TABLE stg.PPO_ActivityReport_MasterCoverage_Input
BEGIN

CREATE TABLE stg.PPO_ActivityReport_MasterCoverage_Input(
	OdsCustomerId int NOT NULL,
	BillIDNo int NOT NULL,
	CreateDate datetime NULL,
	Form_Type varchar(8) NOT NULL,
	TypeOfBill varchar(4) NULL,
	CompanyID int NULL,
	Company varchar(50) NOT NULL,
	OfficeID int NULL,
	Office varchar(40) NOT NULL,
	Coverage varchar(2) NULL,
	SOJ varchar(2) NULL,
	LINE_NO_DISP smallint NULL,
	LINE_NO smallint NOT NULL,
	REF_LINE_NO int NULL,
	LineType int NOT NULL,
	OVER_RIDE smallint NULL,
	CHARGED money NOT NULL,
	ALLOWED money NOT NULL,
	PreApportionedAmount decimal(19, 4) NULL,
	ANALYZED money NOT NULL,
	UNITS real NOT NULL,
	ReportTypeId int NOT NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE()
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO

IF OBJECT_ID('dbo.ProcedureCodeAnalysis_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.ProcedureCodeAnalysis_Output(
	OdsCustomerId INT NOT NULL,
	ReportName varchar(50) NULL,
	DisplayName varchar(255) NULL,
	Code varchar(50) NULL,
	[Desc] varchar(max) NULL,
	MajorGroup varchar(200) NULL,
	CoverageType varchar(20) NULL,
	CoverageTypeDesc varchar(100) NULL,
	FormType varchar(20) NULL,
	[State] varchar(20) NULL,
	County varchar(50) NULL,
	Company varchar(100) NULL,
	Office varchar(100) NULL,
	[Year] int NULL,
	[Quarter] varchar(8) NULL,
	DateQuarter varchar(20) NULL,
	TotalCharged money NULL,
	IndTotalCharged money NULL,
	TotalAllowed money NULL,
	IndTotalAllowed money NULL,
	ClaimCnt int NULL,
	IndClaimCnt int NULL,
	ClaimantCnt int NULL,
	IndClaimantCnt int NULL,
	TotalReduction money NULL,
	IndTotalReduction money NULL,
	TotalBills int NULL,
	IndTotalBills int NULL,
	TotalLines int NULL,
	IndTotalLines int NULL,
	TotalUnits int NULL,
	IndTotalUnits int NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE() 
);
END
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.ProcedureCodeAnalysis_Output')
                        AND NAME = 'CreateDate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.ProcedureCodeAnalysis_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.ProcedureCodeAnalysis_Output.CreateDate', 'RunDate', 'COLUMN'; 
    END;
GO




IF OBJECT_ID('stg.ProcedureCodeAnalysisClient', 'U') IS NOT NULL
DROP TABLE stg.ProcedureCodeAnalysisClient; 
BEGIN
 CREATE TABLE stg.ProcedureCodeAnalysisClient (
	 ReportName VARCHAR(50)
	,OdsCustomerID INT
	,CoverageType VARCHAR(20)
	,FormType VARCHAR(20)
	,STATE VARCHAR(20)
	,County VARCHAR(50)
	,Company VARCHAR(100)
	,Office VARCHAR(100)
	,Year INT
	,Quarter INT
	,ProcedureCode VARCHAR(50)
	,TotalClaims INT
	,TotalClaimants INT
	,TotalCharged MONEY
	,TotalAllowed MONEY
	,TotalReductions MONEY
	,TotalBills INT
	,TotalUnits REAL
	,TotalLines INT
	)
END 
GO
IF OBJECT_ID('stg.ProcedureCodeAnalysisIndustry', 'U') IS NOT NULL
DROP TABLE stg.ProcedureCodeAnalysisIndustry; 
BEGIN
CREATE TABLE stg.ProcedureCodeAnalysisIndustry(
	ReportName varchar(13) NOT NULL,
	CoverageType varchar(20) NULL,
	FormType varchar(20) NULL,
	State varchar(20) NULL,
	County varchar(50) NULL,
	Company varchar(100) NULL,
	Office varchar(100) NULL,
	Year int NULL,
	Quarter int NULL,
	ProcedureCode varchar(50) NULL,
	IndTotalClaims int NULL,
	IndTotalClaimants int NULL,
	IndTotalCharged money NULL,
	IndTotalAllowed money NULL,
	IndTotalReductions money NULL,
	IndTotalBills int NULL,
	IndTotalUnits numeric(9, 2) NULL,
	IndTotalLines int NULL
);
END 
GO


IF OBJECT_ID('dbo.ProviderAnalyticsBillHeader', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsBillHeader tbale to dbo.ProviderDataExplorerBillHeader.
	EXEC sp_rename 'dbo.ProviderAnalyticsBillHeader.PK_ProviderAnalyticsBillHeader', 'PK_ProviderDataExplorerBillHeader', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsBillHeader', 'ProviderDataExplorerBillHeader'	
END
GO

IF OBJECT_ID('dbo.ProviderDataExplorerBillHeader', 'U') IS NULL

BEGIN
CREATE TABLE dbo.ProviderDataExplorerBillHeader
(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,		
	BillId INT NOT NULL,
	ClaimantHeaderId INT NULL,
	DateSaved DATETIME NULL,	
	ClaimDateLoss DATETIME NULL,
	CVType VARCHAR(2) NULL,
	Flags INT NULL,	
	CreateDate DATETIME NULL,
	ProviderZipofService VARCHAR(12) NULL,
	TypeofBill VARCHAR(4) NULL,
	LastChangedOn DATETIME NULL,	
	CVTypeDescription VARCHAR(100) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()	

	)ON rpt_PartitionScheme(OdsCustomerId)
	WITH
	(
      DATA_COMPRESSION = PAGE
	  )

	ALTER TABLE dbo.ProviderDataExplorerBillHeader ADD
	CONSTRAINT PK_ProviderDataExplorerBillHeader PRIMARY KEY 
	(
		OdsPostingGroupAuditId ,
		OdsCustomerId ,
		BillId				
	);

END
GO



IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='DMLOperation'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN DMLOperation 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsCreatedDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN OdsCreatedDate 

END;
 
 GO
 

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsHashBytesValue'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN OdsHashBytesValue 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsRowisCurrent'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN OdsRowisCurrent 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsSnapshotDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN OdsSnapshotDate 

END;
 
 GO


 IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='Category'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN Category 

END;
 
 GO

 
 IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='CatDesc'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillHeader DROP COLUMN CatDesc 

END;
 
 GO




IF OBJECT_ID('dbo.ProviderAnalyticsBillLine', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsBillLine tbale to dbo.ProviderDataExplorerBillLine.
	EXEC sp_rename 'dbo.ProviderAnalyticsBillLine.PK_ProviderAnalyticsBillLine', 'PK_ProviderDataExplorerBillLine', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsBillLine', 'ProviderDataExplorerBillLine'	
END
GO

IF OBJECT_ID('dbo.ProviderDataExplorerBillLine', 'U') IS NULL
			
BEGIN
CREATE TABLE dbo.ProviderDataExplorerBillLine(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,		
	BillId INT NOT NULL,
	LineNumber INT NOT NULL,	
	OverRide SMALLINT NULL,
	DateofService DATETIME NOT NULL,
	ProcedureCode VARCHAR(13) NULL,
	Units REAL NOT NULL,	
	Charged MONEY NOT NULL,
	Allowed MONEY NOT NULL,
	Analyzed MONEY NULL,
	RefLineNo SMALLINT NULL,
	POSRevCode VARCHAR(4) NULL,	
	Adjustment MONEY NULL,
	FormType VARCHAR(10) NULL,	
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,	
	CodeDescription VARCHAR(2500) NULL,
	Category VARCHAR(500) NULL,
	SubCategory VARCHAR(500) NULL,
	BillLineType VARCHAR(50) NOT NULL,
	BundlingFlag INT NULL,
	ExceptionFlag BIT NOT NULL DEFAULT 0,
	ExceptionComments VARCHAR(500) NULL,
	VisitType VARCHAR(100) NULL,
	BillInjuryDescription VARCHAR(100) NULL,
	ProviderZoSLat FLOAT NULL,
	ProviderZoSLong FLOAT NULL,
	ProviderZoSState VARCHAR(50) NULL,	
	ModalityType VARCHAR(100) NULL,
	ModalityUnitType VARCHAR(100) NULL,	
	RunDate DATETIME NOT NULL DEFAULT GETDATE(),	
	SubFormType VARCHAR(500) NULL,
	Modifier VARCHAR(20) NULL,
	EndNote VARCHAR(MAX) NULL

	)ON rpt_PartitionScheme(OdsCustomerId)
	WITH(
		 DATA_COMPRESSION = PAGE
		)

	ALTER TABLE dbo.ProviderDataExplorerBillLine ADD
	CONSTRAINT PK_ProviderDataExplorerBillLine PRIMARY KEY CLUSTERED
	(
		OdsPostingGroupAuditId,
		OdsCustomerId,
		BillId,
		LineNumber,
		BillLineType 
	);
END
GO

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='DMLOperation'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN DMLOperation 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsCreatedDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN OdsCreatedDate 

END;
 
 GO
  

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsHashBytesValue'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN OdsHashBytesValue 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsRowisCurrent'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN OdsRowisCurrent 

END;
 
 GO
  

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsSnapshotDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine DROP COLUMN OdsSnapshotDate 

END;
 
 GO

 IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='Modifier'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine ADD Modifier VARCHAR(20) NULL

END;
 
 GO
 
IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='EndNote'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerBillLine' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerBillLine ADD EndNote VARCHAR(MAX) NULL

END;
 
 GO
 
 
 

IF OBJECT_ID('dbo.ProviderAnalyticsEtlAudit', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsEtlAudit tbale to dbo.ProviderDataExplorerEtlAudit.
	EXEC sp_rename 'dbo.ProviderAnalyticsEtlAudit.PK_ProviderAnalyticsEtlAudit', 'PK_ProviderDataExplorerEtlAudit', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsEtlAudit', 'ProviderDataExplorerEtlAudit'	
END

GO

IF OBJECT_ID('dbo.ProviderDataExplorerEtlAudit','U') IS NULL	

BEGIN
CREATE TABLE dbo.ProviderDataExplorerEtlAudit(
	AuditId INT IDENTITY(1,1) NOT NULL,
	AuditFor VARCHAR(50) NOT NULL,
	AuditProcess VARCHAR(50) NOT NULL,
	DataAsOfOdsPostingGroupAuditId INT NOT NULL,
	StartDatetime DATETIME NOT NULL,
	EndDatetime DATETIME NULL,
	CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	ReportId INT NULL
)

	ALTER TABLE dbo.ProviderDataExplorerEtlAudit ADD 
	CONSTRAINT PK_ProviderDataExplorerEtlAudit PRIMARY KEY CLUSTERED
	(
		AuditId
	);

END
GO

IF OBJECT_ID('dbo.ProviderDataExplorerIndustryCustomerOutput','U') IS NULL	
BEGIN
CREATE TABLE dbo.ProviderDataExplorerIndustryCustomerOutput(
	OdsCustomerId INT NULL,
	CustomerName VARCHAR(100) NULL,
	ProviderClusterName VARCHAR(250) NULL,
	FormType NVARCHAR(10) NULL,
	SubFormType VARCHAR(200) NULL,
	CoverageLine VARCHAR(50) NULL,
	StateofJurisdiction VARCHAR(2) NULL,
	InjuryType VARCHAR(100) NULL,
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,
	Category VARCHAR(100) NULL,
	SubCategory VARCHAR(250) NULL,
	AvgActualTenure INT NULL,
	AvgExpectedTenure INT NULL,
	TotalCharged MONEY NULL,
	TotalAllowed MONEY NULL,
	TotalAdjustment MONEY NULL,
	TotalClaims INT NULL,
	TotalClaimants INT NULL,
	TotalBills INT NULL,
	TotalLines INT NULL,
	RunDate DATETIME  DEFAULT GETDATE()
);
END
GO



IF OBJECT_ID('dbo.ProviderDataExplorerIndustryEtlAudit','U') IS NULL	
 BEGIN
CREATE TABLE dbo.ProviderDataExplorerIndustryEtlAudit
	(
	AuditId INT IDENTITY(1,1) NOT NULL,
	AuditFor VARCHAR(50) NOT NULL,
	AuditProcess VARCHAR(50) NOT NULL,	
	StartDatetime DATETIME NOT NULL,
	EndDatetime DATETIME NULL,
	CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	UpdatedDate DATETIME NOT NULL DEFAULT GETDATE(),
	ReportId INT NULL
	)

	ALTER TABLE dbo.ProviderDataExplorerIndustryEtlAudit ADD 
	CONSTRAINT PK_ProviderDataExplorerIndustryEtlAudit PRIMARY KEY CLUSTERED
	(
		AuditId
	);
END
GO

IF OBJECT_ID('dbo.ProviderDataExplorerIndustryOutput','U') IS NULL	
BEGIN
CREATE TABLE dbo.ProviderDataExplorerIndustryOutput(
	ProviderClusterName VARCHAR(250) NULL,
	FormType NVARCHAR(10) NULL,
	SubFormType VARCHAR(200) NULL,
	CoverageLine VARCHAR(50) NULL,
	StateofJurisdiction VARCHAR(2) NULL,
	InjuryType VARCHAR(100) NULL,
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,
	Category VARCHAR(100) NULL,
	SubCategory VARCHAR(250) NULL,
	AvgActualTenure INT NULL,
	AvgExpectedTenure INT NULL,
	TotalCharged MONEY NULL,
	TotalAllowed MONEY NULL,
	TotalAdjustment MONEY NULL,
	TotalClaims INT NULL,
	TotalClaimants INT NULL,
	TotalBills INT NULL,
	TotalLines INT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END

GO



IF OBJECT_ID('dbo.ProviderAnalyticsProvider', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsProvider tbale to dbo.ProviderDataExplorerProvider.
	EXEC sp_rename 'dbo.ProviderAnalyticsProvider.PK_ProviderAnalyticsProvider', 'PK_ProviderDataExplorerProvider', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsProvider', 'ProviderDataExplorerProvider'	
END

GO

IF OBJECT_ID('dbo.ProviderDataExplorerProvider', 'U') IS NULL

BEGIN
CREATE TABLE dbo.ProviderDataExplorerProvider(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,		
	ProviderId INT NOT NULL,	
	ProviderTIN VARCHAR(15) NULL,
	ProviderFirstName VARCHAR(35) NULL,
    ProviderLastName  VARCHAR(60) NULL,	
	ProviderGroup VARCHAR(60) NULL,	
	ProviderState VARCHAR(2) NULL,
	ProviderZip VARCHAR(12) NULL,	
	ProviderSPCList VARCHAR(50) NULL,
	ProviderNPINumber VARCHAR(10) NULL,	
	ProviderName VARCHAR(150) NULL,
	ProviderTypeID VARCHAR(10) NULL,
	ProviderClusterId VARCHAR(100) NULL,
	ProviderClusterName VARCHAR(350) NULL,	
	Specialty VARCHAR(255) NULL,
	ClusterSpecialty VARCHAR(2000) NULL,
	CreatedDate DATETIME NULL,	
	RunDate DATETIME NOT NULL DEFAULT GETDATE()

	)	
	ON rpt_PartitionScheme(OdsCustomerId)
		 WITH(  
				DATA_COMPRESSION = PAGE
		 )
		
	ALTER TABLE dbo.ProviderDataExplorerProvider ADD
	CONSTRAINT PK_ProviderDataExplorerProvider PRIMARY KEY CLUSTERED
	(
		OdsPostingGroupAuditId,
		OdsCustomerId,
		ProviderId	
	);

END
GO 

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='DMLOperation'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN DMLOperation 

END;
 
 GO
  

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsCreatedDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN OdsCreatedDate 

END;
 
 GO
  

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsHashBytesValue'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN OdsHashBytesValue 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsRowIsCurrent'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN OdsRowIsCurrent 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsSnapshotDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN OdsSnapshotDate 

END;
 
 GO

IF NOT EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='ProviderClusterName'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 
						AND CHARACTER_MAXIMUM_LENGTH = 350
)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider ALTER COLUMN ProviderClusterName VARCHAR(350) NULL 

END;
 
 GO

 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='LastChangedOn'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerProvider' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerProvider DROP COLUMN LastChangedOn 

END;
 
 GO
 

IF OBJECT_ID('dbo.ProviderAnalyticsClaimantHeader', 'U') IS NOT NULL
BEGIN
	-- Rename the existing dbo.ProviderAnalyticsClaimantHeader tbale to dbo.ProviderDataExplorerClaimantHeader.
	EXEC sp_rename 'dbo.ProviderAnalyticsClaimantHeader.PK_ProviderAnalyticsClaimantHeader', 'PK_ProviderDataExplorerClaimantHeader', N'INDEX'
	EXEC sp_rename 'dbo.ProviderAnalyticsClaimantHeader', 'ProviderDataExplorerClaimantHeader'	
END

GO

IF OBJECT_ID('dbo.ProviderDataExplorerClaimantHeader','U') IS NULL
	
BEGIN
CREATE TABLE dbo.ProviderDataExplorerClaimantHeader(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	ClaimId INT NOT NULL,
	ClaimNumber VARCHAR(500) NULL,
	DateLoss DATETIME NULL,
	CVCode VARCHAR(2) NULL,
	LossState VARCHAR(2) NULL,
	ClaimantId INT NULL,	
	ClaimantState VARCHAR(2) NULL,
	ClaimantZip VARCHAR(12) NULL,
	ClaimantStateofJurisdiction VARCHAR(2) NULL,
	CoverageType VARCHAR(25) NULL,
	ClaimantHeaderId INT NOT NULL,
	ProviderId VARCHAR(32) NOT NULL,
	CreateDate DATETIME NULL,
	LastChangedOn DATETIME NULL,
	MinimumDateofService DATE NULL,
	MaximumDateofService DATE NULL,
	DOSTenureInDays INT NULL,
	ExpectedTenureInDays INT NULL,
	ExpectedRecoveryDate DATE NULL,	
	CustomerName VARCHAR(250) NULL,
	InjuryDescription VARCHAR(100) NULL,
	InjuryNatureId TINYINT NULL,
	InjuryNaturePriority TINYINT NULL,	
	DerivedCVType VARCHAR(25) NULL,
	DerivedCVDesc VARCHAR(500) NULL,
	ClaimantZipLat FLOAT NULL,
	ClaimantZipLong FLOAT NULL,
	MSADesignation VARCHAR(10) NULL,
	CBSADesignation VARCHAR(10) NULL,
	CVCodeDesciption VARCHAR(100) NULL,
	CoverageTypeDescription VARCHAR(100) NULL ,	
	RunDate DATETIME NOT NULL DEFAULT GETDATE()

	) ON rpt_PartitionScheme(OdsCustomerId)
	 WITH(
	      DATA_COMPRESSION = PAGE
		 )

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader ADD
	CONSTRAINT PK_ProviderDataExplorerClaimantHeader PRIMARY KEY CLUSTERED
	(	
		OdsPostingGroupAuditId,
		OdsCustomerId,		
		ClaimantHeaderId
	
	);
END
GO

IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='DmlOperation'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN DmlOperation 

END;
 
 GO
 
 
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsCreateDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN OdsCreateDate 

END;
 
 GO

  
  IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsHashbytesValue'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN OdsHashbytesValue 

END;
 
 GO
  
  
  IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsSnapshotDate'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN OdsSnapshotDate 

END;
 
 GO


IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE COLUMN_NAME ='OdsRowIsCurrent'  
						AND TABLE_SCHEMA = 'dbo'  
						AND TABLE_NAME ='ProviderDataExplorerClaimantHeader' 

)
BEGIN

	ALTER TABLE dbo.ProviderDataExplorerClaimantHeader DROP COLUMN OdsRowIsCurrent 

END;
 
 GO



IF OBJECT_ID('stg.ProviderAnalyticsBillHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderAnalyticsBillHeader
GO

IF OBJECT_ID('stg.ProviderDataExplorerBillHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerBillHeader
BEGIN
CREATE TABLE stg.ProviderDataExplorerBillHeader(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	BillIdNo INT NOT NULL,
	ClaimantHdrIdNo INT NULL,
	DateSaved DATETIME NULL,	
	ClaimDateLoss DATETIME NULL,
	CVType VARCHAR(2) NULL,
	Flags INT NULL,		
	CreateDate DATETIME NULL,
	PvdZOS VARCHAR(12) NULL,	
	TypeOfBill VARCHAR(4) NULL,	
	LastChangedOn DATETIME NULL,
	CVTypeDescription VARCHAR(100) NULL,	
	RunDate DATETIME NOT NULL DEFAULT GETDATE()		
);
END
GO




IF OBJECT_ID('stg.ProviderAnalyticsBillLine', 'U') IS NOT NULL
DROP TABLE stg.ProviderAnalyticsBillLine

GO

IF OBJECT_ID('stg.ProviderDataExplorerBillLine', 'U') IS NOT NULL
		DROP TABLE stg.ProviderDataExplorerBillLine
BEGIN
CREATE TABLE stg.ProviderDataExplorerBillLine(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	BillIdNo INT NOT NULL,
	LineNumber SMALLINT NOT NULL,	
	OverRide SMALLINT NULL,
	DTSVC DATETIME NOT NULL,
	PRCCD VARCHAR(13) NULL,
	Units REAL NOT NULL,
	Charged MONEY NOT NULL,
	Allowed MONEY NOT NULL,
	Analyzed MONEY NULL,
	RefLineNo SMALLINT NULL,	
	POSRevCode VARCHAR(4) NULL,
	Adjustment MONEY NULL, 
	FormType VARCHAR(10) NULL,
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,
	ProviderZipOfService VARCHAR(20) NULL,
	BillLineType VARCHAR(50) NOT NULL,
	ExceptionFlag BIT NOT NULL DEFAULT 0,
	ExceptionComments VARCHAR(500) NULL,
	BundlingFlag INT NULL,
	CodeDescription	VARCHAR	(2500) NULL,
	CodeCategory	VARCHAR	(1500) NULL,
	CodeSubCategory	VARCHAR	(1500) NULL,
	IsCodeNumeric BIT NULL,
	SubFormType VARCHAR(500) NULL,
	BillInjuryDescription VARCHAR(100) NULL,
	Modifier VARCHAR(20) NULL,
	EndNote VARCHAR(MAX) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()

	);
END
GO

IF OBJECT_ID('stg.ProviderDataExplorerIndustryBillHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerIndustryBillHeader;

BEGIN
CREATE TABLE Stg.ProviderDataExplorerIndustryBillHeader(
	OdsCustomerId INT NOT NULL,
	BillId INT NOT NULL,
	ClaimantHeaderId INT NULL,
	CVType VARCHAR(2) NULL,
	CVTypeDescription VARCHAR(100) NULL,
	Flags INT NULL,	
	TypeofBill VARCHAR(4) NULL,		
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
	);

END
GO

IF OBJECT_ID('stg.ProviderDataExplorerIndustryBillLine', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerIndustryBillLine;

BEGIN
CREATE TABLE Stg.ProviderDataExplorerIndustryBillLine(
	OdsCustomerId INT NOT NULL,
	BillId INT NOT NULL,
	LineNumber INT NOT NULL,
	OverRide SMALLINT NULL,
	DateofService DATETIME NOT NULL,
	ProcedureCode VARCHAR(13) NULL,	
	Charged MONEY NOT NULL,
	Allowed MONEY NOT NULL,	
	RefLineNo SMALLINT NULL,
	POSRevCode VARCHAR(4) NULL,
	Adjustment MONEY NULL,
	FormType VARCHAR(10) NULL,
	CodeType VARCHAR(25) NULL,
	Code VARCHAR(50) NULL,
	CodeDescription VARCHAR(2500) NULL,
	Category VARCHAR(500) NULL,
	SubCategory VARCHAR(500) NULL,
	BillLineType VARCHAR(50) NOT NULL,
	BundlingFlag INT NULL,
	ExceptionFlag BIT NOT NULL DEFAULT 0,
	ExceptionComments VARCHAR(500) NULL,
	SubFormType VARCHAR(500) NULL,
	IsCodeNumeric INT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
	);

END
GO

IF OBJECT_ID('stg.ProviderDataExplorerIndustryClaimantHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerIndustryClaimantHeader;

BEGIN
CREATE TABLE Stg.ProviderDataExplorerIndustryClaimantHeader
(
	OdsCustomerId INT NOT NULL,
	ClaimId INT NOT NULL,
	DateLoss DATETIME NULL,
	CVCode VARCHAR(2) NULL,
	ClaimantId INT NULL,
	ClaimantStateofJurisdiction VARCHAR(2) NULL,
	CoverageType VARCHAR(25) NULL,
	ClaimantHeaderId INT NOT NULL,
	ProviderId INT NULL,
	MinimumDateofService DATE NULL,
	MaximumDateofService DATE NULL,
	DOSTenureInDays INT NULL,
	ExpectedTenureInDays INT NULL,
	InjuryDescription VARCHAR(100) NULL,
	DerivedCVType VARCHAR(25) NULL,
	DerivedCVDesc VARCHAR(500) NULL,
	CVCodeDesciption VARCHAR(100) NULL,
	CoverageTypeDescription VARCHAR(100) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
	);

END
GO

IF OBJECT_ID('stg.ProviderDataExplorerIndustryProvider', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerIndustryProvider;

BEGIN
CREATE TABLE Stg.ProviderDataExplorerIndustryProvider
	(
	OdsCustomerId INT NOT NULL,
	ProviderId INT NOT NULL,
	ProviderTIN VARCHAR(15) NULL,
	ProviderFirstName VARCHAR(35) NULL,
	ProviderLastName VARCHAR(60) NULL,
	ProviderGroup VARCHAR(60) NULL,
	ProviderState VARCHAR(2) NULL,
	ProviderZip VARCHAR(12) NULL,
	ProviderNPINumber VARCHAR(10) NULL,
	ProviderName VARCHAR(150) NULL,
	ProviderTypeID VARCHAR(10) NULL,
	ProviderClusterId VARCHAR(100) NULL,
	ProviderClusterName VARCHAR(350) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
	);

END
GO

IF OBJECT_ID('stg.ProviderAnalyticsProvider', 'U') IS NOT NULL
DROP TABLE stg.ProviderAnalyticsProvider

GO

IF OBJECT_ID('stg.ProviderDataExplorerProvider', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerProvider
BEGIN
CREATE TABLE stg.ProviderDataExplorerProvider(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	ProviderIdNo INT NOT NULL,
	ProviderTIN VARCHAR(15) NULL,
	ProviderFirstName VARCHAR(35) NULL,
	ProviderLastName VARCHAR(60) NULL,
	ProviderGroup VARCHAR(60) NULL,
	ProviderState VARCHAR(2) NULL,
	ProviderZip VARCHAR(12) NULL,	
	ProviderSPCList VARCHAR(50) NULL,
	ProviderNPINumber VARCHAR(10) NULL,	
	CreatedDate DATETIME NULL,	
	ProviderName	VARCHAR(150) NULL,
	ProviderTypeID VARCHAR(10) NULL,
	ProviderClusterID VARCHAR(100) NULL,
	Specialty VARCHAR(255) NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END
GO


IF OBJECT_ID('stg.ProviderAnalyticsClaimantHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderAnalyticsClaimantHeader

GO

IF OBJECT_ID('stg.ProviderDataExplorerClaimantHeader', 'U') IS NOT NULL
DROP TABLE stg.ProviderDataExplorerClaimantHeader
BEGIN
CREATE TABLE stg.ProviderDataExplorerClaimantHeader(
	OdsPostingGroupAuditId INT NOT NULL,
	OdsCustomerId INT NOT NULL,	
	ClaimIdNo INT NULL,
	ClaimNo VARCHAR(500) NULL,
	DateLoss DATETIME NULL,
	CVCode VARCHAR(2) NULL,	
	LossState VARCHAR(2) NULL,
	ClaimantIdNo INT NULL,	
	ClaimantState VARCHAR(2) NULL,
	ClaimantZip VARCHAR(12) NULL,
	ClaimantStateOfJurisdiction VARCHAR(2) NULL,
	CoverageType VARCHAR(2) NULL,	
	ClaimantHdrIdNo INT NOT NULL,
	ProviderIdNo INT NOT NULL,
	CreateDate DATETIME NULL,
	LastChangedOn DATETIME NULL,
	CustomerName VARCHAR(100) NULL,	
	CVCodeDesciption VARCHAR(100) NULL,
	CoverageTypeDescription  VARCHAR(100) NULL,
	ExpectedTenureInDays INT NULL,
	ExpectedRecoveryDate DATE NULL	,
	InjuryDescription VARCHAR(100) NULL,
	InjuryNatureId TINYINT NULL,
	InjuryNaturePriority TINYINT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
);
END
GO


IF OBJECT_ID('dbo.SelfServePerformanceReport_Operations', 'U') IS NULL
BEGIN

CREATE TABLE dbo.SelfServePerformanceReport_Operations(
	OdsCustomerId INT NULL,
	Company VARCHAR(100) NULL,
	OfficeName VARCHAR(100) NULL,
	SOJ VARCHAR(2) NULL,
	BillID INT NULL,
	BillCreateDate DATETIME NULL,
	BillCommitDate DATETIME NULL,
	CarrierReceivedDate DATETIME NULL,
	MitchellReceivedDate DATETIME NULL,
	BillLine INT NULL,
	OverrideDateTime DATETIME NULL,
	UserId INT NULL,
	AdjustorId INT NULL,
	OfficeIdNo INT NULL,
	BillType VARCHAR(12) NULL,
	[1stNurseCompleteDate] DATETIME NULL,
	[2ndNurseCompleteDate] DATETIME NULL,
	[3rdNurseCompleteDate] DATETIME NULL,
	BillsSentToPPODate DATETIME NULL,
	BillsReceivedFromPPODate DATETIME NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
) 

END
GO

IF OBJECT_ID('dbo.SelfServePerformanceReport_Savings', 'U') IS NULL
BEGIN

CREATE TABLE dbo.SelfServePerformanceReport_Savings(
	OdsCustomerId INT NULL,
	CustomerName VARCHAR(100) NULL,
	Company VARCHAR(100) NULL,
	Office VARCHAR(100) NULL,
	SOJ VARCHAR(2) NULL,
	ClaimCoverageType VARCHAR(5) NULL,
	BillCoverageType VARCHAR(5) NULL,
	FormType VARCHAR(12) NULL,
	ClaimID VARCHAR(255) NULL,
	ClaimantID INT NULL,
	ProviderTIN VARCHAR(15) NULL,
	BillID INT NULL,
	BillCreateDate DATETIME NULL,
	BillCommitDate DATETIME NULL,
	MitchellCompleteDate DATETIME NULL,
	ClaimCreateDate DATETIME NULL,
	ClaimDateofLoss DATETIME NULL,
	ExpectedRecoveryDate DATETIME NULL,
	BillLine INT NULL,
	ProcedureCode VARCHAR(15) NULL,
	ProcedureCodeDescription VARCHAR(max) NULL,
	ProcedureCodeMajorGroup VARCHAR(100) NULL,
	BodyPart VARCHAR(100) NULL,
	ReductionType VARCHAR(100) NULL,
	AdjSubCatName VARCHAR(50) NULL,
	DuplicateBillFlag SMALLINT NULL,
	DuplicateLineFlag SMALLINT NULL,
	Adjustment MONEY NULL,
	ProviderCharges MONEY NULL,
	TotalAllowed MONEY NULL,
	TotalUnits REAL NULL,
	ExpectedRecoveryDuration INT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
) 

END
GO


IF OBJECT_ID('stg.SelfServePerformanceReport_Savings_Adjustments', 'U') IS NOT NULL
DROP TABLE stg.SelfServePerformanceReport_Savings_Adjustments
BEGIN

CREATE TABLE stg.SelfServePerformanceReport_Savings_Adjustments(
	OdsCustomerId INT NOT NULL,
	billIDNo INT NULL,
	line_no INT NULL,
	line_type INT NULL,
	ReductionType VARCHAR(100) NULL,
	AdjSubCatName VARCHAR(50) NULL,
	Adjustment MONEY NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
)

END
GO



IF OBJECT_ID('stg.SelfServePerformanceReport_Savings_Data', 'U') IS NOT NULL
DROP TABLE stg.SelfServePerformanceReport_Savings_Data
BEGIN

CREATE TABLE stg.SelfServePerformanceReport_Savings_Data(
	OdsCustomerId INT NULL,
	CustomerName VARCHAR(100) NULL,
	Company VARCHAR(100) NULL,
	Office VARCHAR(100) NULL,
	SOJ VARCHAR(2) NULL,
	ClaimCoverageType VARCHAR(5) NULL,
	BillCoverageType VARCHAR(5) NULL,
	FormType VARCHAR(12) NULL,
	ClaimID VARCHAR(255) NULL,
	ClaimantID INT NULL,
	ProviderTIN VARCHAR(15) NULL,
	BillID INT NULL,
	BillCreateDate DATETIME NULL,
	BillCommitDate DATETIME NULL,
	MitchellCompleteDate DATETIME NULL,
	ClaimCreateDate DATETIME NULL,
	ClaimDateofLoss DATETIME NULL,
	ExpectedRecoveryDate DATETIME NULL,
	BillLine INT NULL,
	LineType INT NULL,
	ProcedureCode VARCHAR(15) NULL,
	ProcedureCodeDescription VARCHAR(max) NULL,
	ProcedureCodeMajorGroup VARCHAR(100) NULL,
	BodyPart VARCHAR(100) NULL,
	ProviderCharges MONEY NULL,
	TotalAllowed MONEY NULL,
	TotalUnits REAL NULL,
	ExpectedRecoveryDuration INT NULL,
	RunDate DATETIME NOT NULL DEFAULT GETDATE()
) 


END
GO



IF OBJECT_ID('dbo.VPN_Monitoring_NetworkCredits_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkCredits_Output
    (
        OdsCustomerId INT NOT NULL ,
        Customer VARCHAR(100) NOT NULL ,
        Period DATETIME NOT NULL ,
        SOJ VARCHAR(2) NULL ,
        CV_Type VARCHAR(10) NULL ,
        BillType VARCHAR(8) NULL ,
        Network VARCHAR(50) NULL ,
        Company VARCHAR(50) NULL ,
        Office VARCHAR(40) NULL ,
        ActivityFlagDesc VARCHAR(50) NULL ,
        CreditReasonDesc VARCHAR(100) NULL ,
        Credits MONEY NULL ,
        RunDate DATETIME NULL
    ); 
END

GO





IF OBJECT_ID('dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output(
	StartOfMonth datetime NULL,
	OdsCustomerId int NULL,
	Customer varchar(100) NULL,
	SOJ varchar(2) NULL,
	NetworkName varchar(50) NULL,
	BillType varchar(8) NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	CV_Type varchar(2) NULL,
	Company varchar(50) NULL,
	Office varchar(40) NULL,
	BillsCount float NOT NULL,
	BillsRepriced float NOT NULL,
	ProviderCharges money NOT NULL,
	BRAllowable money NOT NULL,
	InNetworkCharges money NOT NULL,
	InNetworkAmountAllowed money NOT NULL,
	Savings money NOT NULL,
	Credits money NOT NULL,
	NetSavings money NOT NULL,
	ReportTypeId INT NULL,
	RunDate datetime NOT NULL);
END
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output')
                        AND NAME = 'LastUpdate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output.LastUpdate', 'RunDate', 'COLUMN'; 
    END;
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkRepricedSubmitted_Output'
		AND COLUMN_NAME = 'BillsCount'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	ALTER COLUMN BillsCount FLOAT;

END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkRepricedSubmitted_Output'
		AND COLUMN_NAME = 'BillsRepriced'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
	ALTER COLUMN BillsRepriced FLOAT;

END
GO

IF OBJECT_ID('dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output(
	StartOfMonth datetime NULL,
	OdsCustomerId int NOT NULL,
	Customer varchar(100) NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	SOJ varchar(2) NOT NULL,
	BillType varchar(8) NOT NULL,
	CV_Type varchar(2) NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	InNetworkCharges money NULL,
	InNetworkAmountAllowed money NULL,
	Savings money NULL,
	Credits money NULL,
	NetSavings money NULL,
	BillsCount float NULL,
	BillsRePriced float NULL,
	ProviderCharges money NULL,
	BRAllowable money NULL,
	ReportTypeId INT NULL,
	RunDate datetime NOT NULL);
END
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output')
                        AND NAME = 'LastUpdate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output.LastUpdate', 'RunDate', 'COLUMN'; 
    END;
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkUniqueSubmitted_Output'
		AND COLUMN_NAME = 'BillsCount'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
	ALTER COLUMN BillsCount FLOAT;

END
GO

IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'VPN_Monitoring_NetworkUniqueSubmitted_Output'
		AND COLUMN_NAME = 'BillsRePriced'
		AND DATA_TYPE = 'float')
BEGIN 

	ALTER TABLE dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
	ALTER COLUMN BillsRePriced FLOAT;

END
GO

IF OBJECT_ID('dbo.VPN_Monitoring_TAT_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_TAT_Output(
	OdsCustomerId INT NOT NULL,
	StartOfMonth datetime NOT NULL,
	Client nvarchar(100) NOT NULL,
	BillIdNo int NOT NULL,
	ClaimIdNo int NOT NULL,
	SOJ varchar(2) NOT NULL,
	NetworkId int NOT NULL,
	NetworkName varchar(50) NOT NULL,
	SentDate datetime NOT NULL,
	ReceivedDate datetime NULL,
	HoursLockedToVPN int NOT NULL,
	TATInHours int NULL,
	TAT int NULL,
	BillCreateDate datetime NULL,
	ParNonPar nchar(10) NULL,
	SubNetwork varchar(50) NULL,
	AmtCharged money NULL,
	BillType nchar(10) NULL,
	Bucket varchar(50) NULL,
	ValueBucket varchar(50) NULL,
	RunDate datetime NULL);
END
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_TAT_Output')
                        AND NAME = 'LastUpdate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_TAT_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.VPN_Monitoring_TAT_Output.LastUpdate', 'RunDate', 'COLUMN'; 
    END;
GO



IF OBJECT_ID('stg.VPN_Monitoring_NetworkRepriced', 'U') IS NOT NULL
DROP TABLE stg.VPN_Monitoring_NetworkRepriced
BEGIN
    CREATE TABLE stg.VPN_Monitoring_NetworkRepriced
        (
            StartOfMonth DATETIME NULL ,
            ReportYear INT NULL ,
            ReportMonth INT NULL ,
            OdsCustomerId INT  NULL ,
            SOJ VARCHAR(2) NULL , --
            NetworkName VARCHAR(50) NULL ,
            BillType VARCHAR(8) NULL ,
            CV_Type VARCHAR(2)  NULL ,
            Company VARCHAR(50)  NULL ,
            Office VARCHAR(40)  NULL ,
            InNetworkCharges MONEY NULL ,
            InNetworkAmountAllowed MONEY NULL ,
            Savings MONEY NULL ,
            VPNAllowed MONEY NULL ,
            Credits MONEY NULL ,
            NetSavings MONEY NULL ,
            DateTimeStamp DATETIME NULL
        )
END
GO

IF OBJECT_ID('stg.VPN_Monitoring_NetworkSubmitted', 'U') IS NOT NULL
DROP TABLE stg.VPN_Monitoring_NetworkSubmitted
BEGIN
CREATE TABLE stg.VPN_Monitoring_NetworkSubmitted(
	StartOfMonth datetime NULL,
	OdsCustomerId int NOT NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	SOJ varchar(2) NOT NULL,
	NetworkName varchar(50) NULL,
	BillType varchar(8) NOT NULL,
	CV_Type varchar(2) NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	BillsCount int NULL,
	BillsCount_Weekend int NULL,
	BillsCount_WeekDay int NULL,
	BillsRePriced int NULL,
	BillsRePriced_Weekend int NULL,
	BillsRePriced_WeekDay int NULL,
	ProviderCharges money NULL,
	ProviderCharges_Weekend money NULL,
	ProviderCharges_WeekDay money NULL,
	BRAllowable money NULL,
	BRAllowable_Weekend money NULL,
	BRAllowable_WeekDay money NULL) 
END
GO
IF OBJECT_ID('stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered', 'U') IS NOT NULL
DROP TABLE stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered
BEGIN
CREATE TABLE stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered(
	LogDate datetime NULL,
	EventId int NULL,
	BillIdNo int NULL,
	ProcessInfo smallint NULL,
	NetworkId int NULL,
	StartOfMonth datetime NULL,
	OdsCustomerId int NOT NULL,
	ReportYear int NULL,
	ReportMonth int NULL,
	SOJ varchar(2) NOT NULL,
	BillType varchar(8) NOT NULL,
	CV_Type varchar(2) NOT NULL,
	Company varchar(50) NOT NULL,
	Office varchar(40) NOT NULL,
	ProviderCharges money NOT NULL,
	BRAllowable money NOT NULL,
	NetworkName varchar(50) NULL,
	SubNetwork varchar(50) NULL)
END
GO

