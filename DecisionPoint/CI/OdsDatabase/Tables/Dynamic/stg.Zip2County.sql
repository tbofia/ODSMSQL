IF OBJECT_ID('stg.Zip2County', 'U') IS NOT NULL
DROP TABLE stg.Zip2County
BEGIN
    CREATE TABLE stg.Zip2County(
        Zip VARCHAR(5) NULL
        ,County VARCHAR(50) NULL
        ,State VARCHAR(2) NULL
        ,DmlOperation CHAR(1) NOT NULL
        )
END
GO
