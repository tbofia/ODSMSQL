IF OBJECT_ID('adm.Process', 'U') IS NULL
BEGIN
    CREATE TABLE adm.Process
        (
            ProcessId SMALLINT NOT NULL ,
			ReportId INT,
            ProcessDescription VARCHAR(255) NOT NULL ,
			ProductName VARCHAR(255) NOT NULL,
            TargetSchemaName VARCHAR(10) NOT NULL ,
            TargetTableName VARCHAR(255) NOT NULL ,
			FilterDateColumnName VARCHAR(255) NULL,
            IsActive BIT NOT NULL,
			IsReportedOn BIT NOT NULL,
			IndexScript VARCHAR(MAX) NULL
        );

    ALTER TABLE adm.Process ADD 
    CONSTRAINT PK_EtlProcess PRIMARY KEY CLUSTERED (ProcessId);
END
GO

IF OBJECT_ID('adm.ReportCommand', 'U') IS NULL
    BEGIN
		CREATE TABLE adm.ReportCommand 
		  (
			ReportID INT NOT NULL,
			ReportName VARCHAR(100) NOT NULL,
			CommandID INT NOT NULL,
			CommandName VARCHAR(100) NOT NULL,
			CommandString VARCHAR(MAX) NULL,
			Argument VARCHAR(250) NULL,
			);
		ALTER TABLE adm.ReportCommand ADD 
        CONSTRAINT PK_ReportCommand PRIMARY KEY CLUSTERED (ReportID,CommandID);
    END
    
 GO
 IF OBJECT_ID('adm.ReportJob', 'U') IS NULL
BEGIN
CREATE TABLE adm.ReportJob(
	ReportID int NOT NULL,
	ReportJobName varchar(255) NULL,
	SourceDatabaseName varchar(255) NOT NULL,
	EmailTo varchar(255) NOT NULL,
	CustomerListType int NOT NULL,
	RunType int NOT NULL,
	SnapshotDate datetime NULL,
	Priority int NOT NULL,
	Enabled int NOT NULL,
	RunWeekDay int NULL,
	IsDaily int NULL,
	IsWeekly int NULL,
	IsMonthly int NULL,
	IsQuarterly int NULL
)

 ALTER TABLE adm.ReportJob ADD 
        CONSTRAINT PK_ReportJob PRIMARY KEY CLUSTERED (ReportID);
END

GO
IF OBJECT_ID('adm.ReportParameters', 'U') IS NULL
BEGIN
CREATE TABLE adm.ReportParameters(
	ReportId int NOT NULL,
	ParameterName varchar(50) NOT NULL,
	ParameterDesc varchar(500) NULL,
	ParameterValue varchar(600) NULL,
	CreatedDate datetime NOT NULL DEFAULT GETDATE() )

	ALTER TABLE adm.ReportParameters ADD 
	CONSTRAINT PK_ReportParameters PRIMARY KEY CLUSTERED (
		ReportId ASC,
		ParameterName ASC)
END

GO

IF OBJECT_ID('rpt.CustomerReportSubscription', 'U') IS NULL
BEGIN
CREATE TABLE rpt.CustomerReportSubscription(
	ReportID INT NOT NULL,
	CustomerId INT NOT NULL,
	IsActive BIT NOT NULL,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NULL
);
END
GO



IF OBJECT_ID('rpt.ProviderAnalyticsCodeHierarchy', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsCodeHierarchy

GO

IF OBJECT_ID('rpt.ProviderDataExplorerCodeHierarchy','U') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerCodeHierarchy(
	CodeStart VARCHAR(50) NOT NULL,
	CodeEnd VARCHAR(50) NOT NULL,
	Category VARCHAR(200) NULL,
	SubCategory VARCHAR(200) NULL,
	Description VARCHAR(250) NULL,
	CodeType VARCHAR(50) NOT NULL,
	IsCodeNumeric bit NULL
)
	ALTER TABLE rpt.ProviderDataExplorerCodeHierarchy ADD 
	CONSTRAINT PK_ProviderDataExplorerCodeHierarchy PRIMARY KEY CLUSTERED
	(
		CodeStart,
		CodeEnd,
		CodeType
	);

END
GO

IF OBJECT_ID('rpt.ProviderAnalyticsCodeMapping', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsCodeMapping

GO

IF OBJECT_ID('rpt.ProviderDataExplorerCodeMapping') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerCodeMapping
(
	CodeStart VARCHAR(20) NOT NULL,
	CodeEnd VARCHAR(20) NOT NULL,
	CodeType VARCHAR(50) NULL,
	CodeCategory VARCHAR(100) NULL,
	CodeSubCategory VARCHAR(20) NULL

)
	ALTER TABLE rpt.ProviderDataExplorerCodeMapping ADD 
	CONSTRAINT PK_ProviderDataExplorerCodeMapping PRIMARY KEY CLUSTERED
	(
		CodeStart,
		CodeEnd
	);
END
GO
		   
IF OBJECT_ID('rpt.ProviderAnalyticsPRCodeDataQuality', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsPRCodeDataQuality

GO

IF OBJECT_ID('rpt.ProviderDataExplorerPRCodeDataQuality','U') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerPRCodeDataQuality
(
	Code VARCHAR(50) NOT NULL,
	Description VARCHAR(1000) NULL,
	Comments VARCHAR(150) NULL,
	Category VARCHAR(150) NULL,
	SubCategory VARCHAR(150) NULL,
	MappedCode VARCHAR(50) NULL,
	ExceptionFlag VARCHAR(25) NULL
	)
	ALTER TABLE rpt.ProviderDataExplorerPRCodeDataQuality ADD 
	CONSTRAINT PK_ProviderDataExplorerPRCodeDataQuality PRIMARY KEY CLUSTERED
	(
		Code
	);

END
GO

IF OBJECT_ID('rpt.ProviderAnalyticsZipCode', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsZipCode

GO

IF OBJECT_ID('rpt.ProviderDataExplorerZipCode','U') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerZipCode
(
	ZipCode	VARCHAR(500) NOT NULL,
	ZipCodeType	VARCHAR(500) NULL,
	City VARCHAR(500) NULL,
	State VARCHAR(500) NULL,
	LocationType VARCHAR(500) NULL,
	Lat	FLOAT NULL,
	Long FLOAT NULL,
	Location VARCHAR(500) NULL,
	Decommisioned VARCHAR(500) NULL,
	TaxReturnsFiled VARCHAR(500) NULL,
	EstimatedPopulation	VARCHAR(500) NULL,
	TotalWages	VARCHAR(500) NULL
)	
	ALTER TABLE rpt.ProviderDataExplorerZipCode ADD 
	CONSTRAINT PK_ProviderDataExplorerZipCode PRIMARY KEY CLUSTERED
	(
		ZipCode
	);
END
GO

IF OBJECT_ID('rpt.ProviderAnalyticsZipCodeMSAvCBSA', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsZipCodeMSAvCBSA

GO

IF OBJECT_ID('rpt.ProviderDataExplorerZipCodeMSAvCBSA','U') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerZipCodeMSAvCBSA(
  	MSAState VARCHAR(50) NULL,
	MSAZipCode VARCHAR(50) NOT NULL,
	MSALocality VARCHAR(50) NULL,
	MSACarrier VARCHAR(50) NULL,
	MSAUrbanBlankRuralRSuperRuralB VARCHAR(50) NULL,
	CBSAState VARCHAR(50) NULL,
	CBSAZipCode VARCHAR(50) NOT NULL,
	CBSACarrier VARCHAR(50) NULL,
	CBSALocality VARCHAR(50) NULL,
	CBSAUrbanBlankRuralRSuperRuralB VARCHAR(50) NULL
)
	ALTER TABLE rpt.ProviderDataExplorerZipCodeMSAvCBSA ADD 
	CONSTRAINT PK_ProviderDataExplorerZipCodeMSAvCBSA PRIMARY KEY CLUSTERED	
	(
		MSAZipCode,
		CBSAZipCode
	);
END
GO


