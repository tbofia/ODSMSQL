IF OBJECT_ID('stg.ZipCode', 'U') IS NOT NULL
    DROP TABLE stg.ZipCode;

BEGIN
    CREATE TABLE stg.ZipCode
        (
         ZipCode VARCHAR(5) NULL
        ,PrimaryRecord BIT NULL
        ,STATE VARCHAR(2) NULL
        ,City VARCHAR(30) NULL
        ,CityAlias VARCHAR(30) NULL
        ,County VARCHAR(30) NULL
        ,Cbsa VARCHAR(5) NULL
        ,CbsaType VARCHAR(5) NULL
        ,ZipCodeRegionId TINYINT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
