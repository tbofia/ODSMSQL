
-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Stores information on each file to be loaded',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
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
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
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
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessDescription' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessDescription' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Description of process',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
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
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'TargetSchemaName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TargetSchemaName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Schema of the table that stores this data',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TargetSchemaName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'TargetTableName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TargetTableName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Name of the table that stores this data',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TargetTableName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroup',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'LoadGroup' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadGroup' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Within a posting group, processes are broken into load groups that run concurrently.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadGroup' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'HashFunctionType' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'HashFunctionType' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'SHA1 (1) or MD5 (2)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'HashFunctionType' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsActive' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsActive' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this process is active',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsActive' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Process')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsSnapshot' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsSnapshot' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'If true, incremental files include the entire table; that is, we have to derive the changes by comparing to the last state of this table.  We have to do this for tables that cant use change tracking (dev and HIM static tables).',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Process', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsSnapshot' --Column Name

GO

