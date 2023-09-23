
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

