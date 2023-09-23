IF OBJECT_ID('rpt.DataExtractType', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.DataExtractType
        (
            DataExtractTypeId TINYINT NOT NULL ,
            DataExtractTypeName VARCHAR(50) NOT NULL,
			DataExtractTypeCode VARCHAR(4) NOT NULL,
			IsFullExtract	BIT NOT NULL,
			FullLoadVersion VARCHAR(20) NULL,
			IsFullLoadDifferential BIT NULL
        );

    ALTER TABLE rpt.DataExtractType ADD 
    CONSTRAINT PK_DataExtractType PRIMARY KEY CLUSTERED (DataExtractTypeId);
END
GO
