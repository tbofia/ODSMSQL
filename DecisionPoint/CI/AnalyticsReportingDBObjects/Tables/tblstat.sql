IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN

CREATE TABLE dbo.Customers(
	Custid INT NOT NULL,
	Name VARCHAR(100) NULL,
	Customer VARCHAR(100) NULL,
	CrossReference VARCHAR(100) NULL,
	IndustryComparisonFlag INT NULL,
	VPN BIT NULL,
	AdjusterWorkspaceServiceRequestFlag BIT NULL);
	
ALTER TABLE dbo.Customers ADD 
CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED (Custid);

END
GO
IF OBJECT_ID('rpt.DataExtractType', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.DataExtractType
        (
            DataExtractTypeId TINYINT NOT NULL ,
            DataExtractTypeName VARCHAR(50) NOT NULL,
			DataExtractTypeCode VARCHAR(4) NOT NULL,
			IsFullExtract	BIT NOT NULL,
			FullLoadVersion VARCHAR(20) NULL,
			IsFullLoadDifferential BIT NULL
        );

    ALTER TABLE rpt.DataExtractType ADD 
    CONSTRAINT PK_DataExtractType PRIMARY KEY CLUSTERED (DataExtractTypeId);
END
GO
IF OBJECT_ID('rpt.PostingGroup', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.PostingGroup
        (
            PostingGroupId TINYINT NOT NULL ,
            PostingGroupName VARCHAR(50) NOT NULL
        );

    ALTER TABLE rpt.PostingGroup ADD 
    CONSTRAINT PK_PostingGroup PRIMARY KEY CLUSTERED (PostingGroupId);
END
GO
IF OBJECT_ID('rpt.PostingGroupProcess', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.PostingGroupProcess
        (
            PostingGroupId TINYINT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            Priority TINYINT NOT NULL
        );

    ALTER TABLE rpt.PostingGroupProcess ADD 
    CONSTRAINT PK_PostingGroupProcess PRIMARY KEY CLUSTERED (PostingGroupId, ProcessId);
END
GO
IF OBJECT_ID('rpt.Process', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.Process
        (
            ProcessId SMALLINT NOT NULL ,
            ProcessDescription VARCHAR(100) NOT NULL ,
            BaseFileName VARCHAR(100) NOT NULL ,
			IsSnapshot BIT NOT NULL ,
			FileExtension VARCHAR(3) NOT NULL ,
			IsHimStatic BIT NOT NULL ,
			ProductKey VARCHAR(100) NOT NULL ,
			FileColumnDelimiter VARCHAR(3) NOT NULL ,
			MinODSVersion VARCHAR(20) NOT NULL
        );

    ALTER TABLE rpt.Process ADD 
    CONSTRAINT PK_EtlProcess PRIMARY KEY CLUSTERED (ProcessId);
END
GO
IF OBJECT_ID('rpt.ProcessStep', 'U') IS NULL
BEGIN
-- Note: FullSql and IncrementalSql here can't be VARCHAR(MAX) because
-- 1) I'm using xp_cmdshell to generate the text files via bcp, and the
--	bcp command string I pass can't exceed VARCHAR(8000), and
-- 2) I'm storing the query value in a String variable in SSIS, which
--	is limited to 8000 characters.
-- If we decided in the future that 8000 characters isn't sufficient, I'll have to write
-- to write a custom script task in SSIS to read in VARCHAR(MAX) and dump to file.
    CREATE TABLE rpt.ProcessStep
        (
            ProcessStepId INT NOT NULL ,
            ProcessId SMALLINT NOT NULL ,
            ProcessStepDescription VARCHAR(100) NULL ,
            Priority TINYINT NOT NULL ,
            FullSql VARCHAR(8000) NULL ,
            IncrementalSql VARCHAR(8000) NULL ,
            MinAppVersion VARCHAR(10) NULL
        );

    ALTER TABLE rpt.ProcessStep ADD 
    CONSTRAINT PK_ProcessStep PRIMARY KEY CLUSTERED (ProcessStepId);
END
GO
IF OBJECT_ID('rpt.Product', 'U') IS NULL
BEGIN

	CREATE TABLE rpt.Product(
		ProductKey      VARCHAR(100) NOT NULL,
		Name            VARCHAR(100) NOT NULL
		);

	ALTER TABLE rpt.Product 
	ADD CONSTRAINT PK_Product PRIMARY KEY CLUSTERED (ProductKey);

END

GRANT SELECT ON rpt.Product TO MedicalUserRole;

GO
IF OBJECT_ID('rpt.StatusCode', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.StatusCode
        (
            Status VARCHAR(2) NOT NULL ,
            ShortDescription VARCHAR(100) NOT NULL ,
            LongDescription VARCHAR(MAX) NOT NULL 
			        );

    ALTER TABLE rpt.StatusCode ADD 
    CONSTRAINT PK_StatusCode PRIMARY KEY CLUSTERED (Status);
END
GO
