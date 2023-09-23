
-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Types of data extracts supported by the ODS',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
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
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
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
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Data extract description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
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
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'DataExtractTypeCode' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'DataExtractTypeCode' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Alternate key.  This code is included in the control file name.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
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
	WHERE   major_id = OBJECT_ID(N'adm.DataExtractType')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsFullExtract' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsFullExtract' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'When true, files will include all records.  When false, files will only include records that may have changed since the last incremental run.',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'DataExtractType', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsFullExtract' --Column Name

GO

