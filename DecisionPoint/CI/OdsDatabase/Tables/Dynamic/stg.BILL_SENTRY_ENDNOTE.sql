IF OBJECT_ID('stg.BILL_SENTRY_ENDNOTE', 'U') IS NOT NULL
    DROP TABLE stg.BILL_SENTRY_ENDNOTE;
BEGIN
    CREATE TABLE stg.BILL_SENTRY_ENDNOTE
        (
          BillID INT NULL ,
          Line INT NULL ,
          RuleID INT NULL ,
          PercentDiscount REAL NULL ,
          ActionId SMALLINT NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
