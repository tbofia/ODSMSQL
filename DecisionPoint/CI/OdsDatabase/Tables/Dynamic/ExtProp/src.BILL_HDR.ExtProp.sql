
-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsPostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroupAudit',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsPostingGroupAuditId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to Customer',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date time record was created in the ODS',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsSnapshotDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Date and time of the snapshot from which the data was extracted.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsSnapshotDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsRowIsCurrent' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit that signals whether this is the currently active record for this primary key; that is, the latest version of the row.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsRowIsCurrent' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsHashbytesValue' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Hash value of the row.  This is used to determine whether a record has actually changed (e.g. kill-and-fill would cause records that didnt actually change to show as deltas).',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsHashbytesValue' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.BILL_HDR')
		AND ep.name = N'MS_Description'
		AND c.name = N'DmlOperation' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'I - Insert, U - Update, or D - Delete',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'BILL_HDR', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DmlOperation' --Column Name

GO

