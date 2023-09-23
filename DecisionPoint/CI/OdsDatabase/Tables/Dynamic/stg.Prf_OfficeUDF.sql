IF OBJECT_ID('stg.Prf_OfficeUDF', 'U') IS NOT NULL
    DROP TABLE stg.Prf_OfficeUDF;
BEGIN
    CREATE TABLE stg.Prf_OfficeUDF
        (
          OfficeId INT NULL ,
          UDFIdNo INT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
