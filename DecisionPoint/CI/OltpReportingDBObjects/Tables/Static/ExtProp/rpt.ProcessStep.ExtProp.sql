
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

