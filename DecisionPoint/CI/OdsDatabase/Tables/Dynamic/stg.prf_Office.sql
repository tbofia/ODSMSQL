IF OBJECT_ID('stg.prf_Office', 'U') IS NOT NULL
    DROP TABLE stg.prf_Office;
BEGIN
    CREATE TABLE stg.prf_Office
        (
         CompanyId INT NULL
        ,OfficeId INT NULL
        ,OfcNo VARCHAR(4) NULL
        ,OfcName VARCHAR(40) NULL
        ,OfcAddr1 VARCHAR(30) NULL
        ,OfcAddr2 VARCHAR(30) NULL
        ,OfcCity VARCHAR(30) NULL
        ,OfcState VARCHAR(2) NULL
        ,OfcZip VARCHAR(12) NULL
        ,OfcPhone VARCHAR(20) NULL
        ,OfcDefault SMALLINT NULL
        ,OfcClaimMask VARCHAR(50) NULL
        ,OfcTinMask VARCHAR(50) NULL
        ,Version SMALLINT NULL
        ,OfcEdits INT NULL
        ,OfcCOAEnabled SMALLINT NULL
        ,CTGEnabled SMALLINT NULL
        ,LastChangedOn DATETIME NULL
        ,AllowMultiCoverage BIT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
