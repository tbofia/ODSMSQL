IF OBJECT_ID('stg.UDFProvider', 'U') IS NOT NULL
    DROP TABLE stg.UDFProvider;
BEGIN
    CREATE TABLE stg.UDFProvider
        (
          PvdIdNo INT NULL ,
          UDFIdNo INT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19,4) NULL ,
          UDFValueDate DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
