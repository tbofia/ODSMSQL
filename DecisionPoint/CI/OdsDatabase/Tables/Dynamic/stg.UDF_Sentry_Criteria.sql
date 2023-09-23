IF OBJECT_ID('stg.UDF_Sentry_Criteria', 'U') IS NOT NULL
    DROP TABLE stg.UDF_Sentry_Criteria;
BEGIN
    CREATE TABLE stg.UDF_Sentry_Criteria
        (
          UdfIdNo INT NULL ,
          CriteriaID INT NULL ,
          ParentName VARCHAR(50) NULL ,
          Name VARCHAR(50) NULL ,
          Description VARCHAR(1000) NULL ,
          Operators VARCHAR(50) NULL ,
          PredefinedValues VARCHAR(MAX) NULL ,
          ValueDataType VARCHAR(50) NULL ,
          ValueFormat VARCHAR(50) NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
