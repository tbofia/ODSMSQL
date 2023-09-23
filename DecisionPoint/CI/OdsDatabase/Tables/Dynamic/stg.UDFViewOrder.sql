IF OBJECT_ID('stg.UDFViewOrder', 'U') IS NOT NULL
    DROP TABLE stg.UDFViewOrder;
BEGIN
    CREATE TABLE stg.UDFViewOrder
        (
          OfficeId INT NULL ,
          UDFIdNo INT NULL ,
          ViewOrder SMALLINT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
