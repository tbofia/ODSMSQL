
-- --------------------------------------------------
-- Creating Table Description in Extended Property
-- --------------------------------------------------

IF EXISTS ( SELECT  1
	FROM    sys.extended_properties
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND name = N'MS_Description'
		AND minor_id = 0)
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer' --Table Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'AcsOds customers',    --Table Description
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer' --Table Name

GO



-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND ep.name = N'MS_Description'
		AND c.name = N'CustomerId' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerId' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Primary key',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerId' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND ep.name = N'MS_Description'
		AND c.name = N'CustomerName' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerName' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Name of customer',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerName' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND ep.name = N'MS_Description'
		AND c.name = N'CustomerDatabase' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerDatabase' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Name of customers production database',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'CustomerDatabase' --Column Name

GO


-- --------------------------------------------------
-- Creating Column Description in Extended Property
-- --------------------------------------------------


IF EXISTS ( SELECT  1
	FROM    sys.extended_properties ep
	INNER JOIN sys.columns c ON ep.major_id = c.object_id
                                    AND ep.minor_id = c.column_id
	WHERE   major_id = OBJECT_ID(N'adm.Customer')
		AND ep.name = N'MS_Description'
		AND c.name = N'IsActive' )
EXEC sys.sp_dropextendedproperty @name = N'MS_Description',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsActive' --Column Name

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
	@value = N'Bit signals whether customer is currently active',
	@level0type = N'SCHEMA',
	@level0name = N'adm', --Schema Name
	@level1type = N'TABLE',
	@level1name = N'Customer', --Table Name
	@level2type = N'COLUMN',
	@level2name = N'IsActive' --Column Name

GO

