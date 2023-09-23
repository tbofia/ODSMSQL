
-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Audit table that tracks the status of a posting group extract.',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupAuditId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupAuditId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key. Identity.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'PostingGroupId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'PostingGroupId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to PostingGroup',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'FK to DataExtractType',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'Status' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'Status' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Load status for posting group.  This will either be a number representing the step in the extract process, or FI for complete.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ChildDBCTVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBCTVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Change tracking version Id.  Used for checkpointing tables under change tracking.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBCTVersion' --Column Name

GO

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CoreDBCTVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBCTVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Change tracking version Id.  Used for checkpointing tables under change tracking in Core database.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBCTVersion' --Column Name

GO

-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ChildDBSiteInfoHistory' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBSiteInfoHistory' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Max value of SiteinforHistory..SiteinforHistorySeq. Used for checkpointing dev static tables.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBSiteInfoHistory' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CoreDBSiteInfoHistory' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBSiteInfoHistory' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Max value of SiteinforHistory..SiteinforHistorySeq in the HIM static database.  Used for checkpointing HIM static tables.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBSiteInfoHistory' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'ChildDBSnapshotName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBSnapshotName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The name of the database snapshot created for our data extraction process',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'ChildDBSnapshotName' --Column Name

GO

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CoreDBSnapshotName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBSnapshotName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The name of the database snapshot created for our data extraction process',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CoreDBSnapshotName' --Column Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'DBSnapshotServer' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DBSnapshotServer' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The name of the server on which our snapshot was created.  If the production server is an AOAG cluster, this will be one of the secondary servers.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DBSnapshotServer' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SADBVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SADBVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The Smart Advisor version of the OLTP',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SADBVersion' --Column Name

GO

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SAFSVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SAFSVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The Smart Advisor version of the Core Database',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SAFSVersion' --Column Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SnapshotCreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotCreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the snapshot database was created',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotCreateDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'SnapshotDropDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotDropDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The data and time the snapshot database was dropped.  This happens after all data is extracted successfully.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'SnapshotDropDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'CreateDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CreateDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time the record was added',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
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
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'LastChangeDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The last date and time the record was updated',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'LastChangeDate' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.PostingGroupAudit')
		AND ep.name = N'MS_Description'
		AND c.name = N'OdsVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Acs Ods version at the time this record was queued.',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'PostingGroupAudit', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'OdsVersion' --Column Name

GO

