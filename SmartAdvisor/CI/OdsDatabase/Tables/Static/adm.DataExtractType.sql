IF OBJECT_ID('adm.DataExtractType', 'U') IS NULL
BEGIN
    CREATE TABLE adm.DataExtractType
        (
            DataExtractTypeId TINYINT NOT NULL ,
            DataExtractTypeName VARCHAR(50) NOT NULL,
			DataExtractTypeCode VARCHAR(4) NOT NULL,
			IsFullExtract	BIT NOT NULL
        );

    ALTER TABLE adm.DataExtractType ADD 
    CONSTRAINT PK_DataExtractType PRIMARY KEY CLUSTERED (DataExtractTypeId);
END
GO
