IF OBJECT_ID('stg.UDFClaimant', 'U') IS NOT NULL
    DROP TABLE stg.UDFClaimant;
BEGIN
    CREATE TABLE stg.UDFClaimant
        (
          CmtIdNo INT NULL ,
          UDFIdNo INT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19,4) NULL ,
          UDFValueDate DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
