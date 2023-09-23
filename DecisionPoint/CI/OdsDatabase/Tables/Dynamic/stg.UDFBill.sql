IF OBJECT_ID('stg.UDFBill', 'U') IS NOT NULL
    DROP TABLE stg.UDFBill;
BEGIN
    CREATE TABLE stg.UDFBill
        (
          BillIdNo INT NULL ,
          UDFIdNo INT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19,4) NULL ,
          UDFValueDate DATETIME NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO

