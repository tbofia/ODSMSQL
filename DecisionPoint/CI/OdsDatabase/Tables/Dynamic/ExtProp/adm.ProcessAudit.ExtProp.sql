
-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of each table load',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key.  Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Process',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'Status' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Status of load.  When FI, load is complete.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ExtractRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records loaded into stg table (staging)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'UpdateRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'UpdateRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records updated in stg table (staging)',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'UpdateRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LoadRowCount' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadRowCount' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Number of records loaaded into src table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadRowCount' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ExtractDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time data was loaded into stg table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ExtractDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastUpdateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastUpdateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time record was last inserted or updated',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastUpdateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LoadDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time data was loaded into src table',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LoadDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time record was created',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.ProcessAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time record was last inserted or updated',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO

