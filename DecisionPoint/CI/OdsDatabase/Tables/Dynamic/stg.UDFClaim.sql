IF OBJECT_ID('stg.UDFClaim', 'U') IS NOT NULL
    DROP TABLE stg.UDFClaim;
BEGIN
    CREATE TABLE stg.UDFClaim
        (
          ClaimIdNo INT NULL ,
          UDFIdNo INT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19,4) NULL ,
          UDFValueDate DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
