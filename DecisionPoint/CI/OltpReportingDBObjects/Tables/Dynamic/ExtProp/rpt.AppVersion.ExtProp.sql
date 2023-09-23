
-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'rpt.AppVersion')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'This table stores a record for each version deployed to the database, along with the date and time of deployment',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersionId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key; Identity',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersion' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersion' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'ODS version; the forrmat is x.x.x[.x]',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersion' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'rpt.AppVersion')
		AND ep.name = N'MS_Description'
		AND c.name = N'AppVersionDate' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionDate' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'The date and time this record was inserted into the AppVersion table',
	@level0type = N'SCHEMA',
	@level0name = N'rpt', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'AppVersion', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'AppVersionDate' --Column Name

GO

