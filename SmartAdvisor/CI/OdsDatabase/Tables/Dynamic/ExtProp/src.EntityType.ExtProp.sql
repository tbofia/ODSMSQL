

-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'src.EntityType')
		AND ep.name = N'MS_Description'
		AND c.name = N'EntityTypeKey' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'EntityType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'EntityTypeKey' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Key Column has been renamed in the ods as EntityTypeKey since it is a reerved keyword.',
	@level0type = N'SCHEMA',
	@level0name = N'src', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'EntityType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'EntityTypeKey' --Column Name


GO