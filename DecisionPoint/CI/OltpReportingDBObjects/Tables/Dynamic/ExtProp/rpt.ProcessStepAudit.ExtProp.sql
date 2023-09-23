
-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of each process step',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessStepAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key. Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to ProcessAudit',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ProcessStepId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ProcessStepId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to ProcessStep',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PreviousCheckpoint' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PreviousCheckpoint' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Checkpoint value for last successful extract',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PreviousCheckpoint' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CurrentCheckpoint' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CurrentCheckpoint' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Checkpoint value for current extract',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CurrentCheckpoint' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CompleteDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CompleteDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time extract was completed',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CompleteDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'TotalRowsAffected' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TotalRowsAffected' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Total number of rows extracted',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'TotalRowsAffected' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data and time data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'rpt.ProcessStepAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The last date and time the record was updated',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'ProcessStepAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO

