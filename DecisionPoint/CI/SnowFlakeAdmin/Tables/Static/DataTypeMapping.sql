

IF OBJECT_ID('adm.dataTypeMapping', 'U') IS NULL
    BEGIN
CREATE TABLE adm.dataTypeMapping(
	SqlServerDataType varchar(100) NULL,
	SnowflakeDataType varchar(100) NULL
) 
	END
GO

