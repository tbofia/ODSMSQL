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
			IsActive BIT NOT NULL ,
			ProductKey VARCHAR(100) NOT NULL ,
			TargetPlatform VARCHAR(30) NOT NULL ,
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

-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.DataExtractType')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Types of data extracts supported by the ODS',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data extract description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeCode' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeCode' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Alternate key.  This code is included in the control file name.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeCode' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsFullExtract' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsFullExtract' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'When true, files will include all records.  When false, files will only include records that may have changed since the last incremental run.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsFullExtract' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroup')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'A logical grouping of tables that have to be dumped/loaded together. They represent the same point in time.',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroup')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Name of posting group',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroup', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupName' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupProcess')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupProcess' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Groups tables (processes) into posting groups (logical grouping of tables that have to be dumped/loaded together)',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupProcess' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupProcess')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupProcess', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroup.  Primary key.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupProcess', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupProcess')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupProcess', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'PK to Process.  Primary key.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupProcess', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupProcess')
		AND ep.name = N'MS_Description'
		AND c.name = N'Priority' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupProcess', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Priority' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Can be used to extract certain tables before others.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupProcess', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Priority' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.Process')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Stores information on each table to be extracted',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessDescription' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessDescription' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Description of the process (e.g. "Extract data for BILL_HDR")',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessDescription' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'BaseFileName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'BaseFileName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Included in the extract file name to identify which process it is associated with.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'BaseFileName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsSnapshot' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsSnapshot' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'If true, this means that a full extract is done even if these are incremental files.  We do this for dev and HIM static tables (unfortunately, we cant use change tracking because the tables periodically get dropped and recreated).  For incremental loads, the files will only have data if the associated checkpoint has changed (e.g. a new DPDU was applied); otherwise, they will be empty.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsSnapshot' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'FileExtension' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'FileExtension' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Extension given to the file.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'FileExtension' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsHimStatic' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsHimStatic' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'One of the tables managed by the HIM group.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsHimStatic' --Column Name

GO


-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStep')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Determines the SQL statement used to create our extract file based on DP version and type of data extract.',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStep')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessStepId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key. Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStep')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Process.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStep')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessStepDescription' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepDescription' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Description of process step.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepDescription' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStep')
		AND ep.name = N'MS_Description'
		AND c.name = N'Priority' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Priority' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Deprecated.  This used to determine the sequence in which the steps were run.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Priority' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStep')
		AND ep.name = N'MS_Description'
		AND c.name = N'FullSql' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'FullSql' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'SQL used for full extracts and static tables.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'FullSql' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStep')
		AND ep.name = N'MS_Description'
		AND c.name = N'IncrementalSql' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IncrementalSql' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'SQL used for incremental extracts (change tracking tables)',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IncrementalSql' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStep')
		AND ep.name = N'MS_Description'
		AND c.name = N'MinAppVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'MinAppVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The minimum DP version for which this record applies.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStep', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'MinAppVersion' --Column Name

GO

