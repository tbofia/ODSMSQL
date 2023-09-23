IF OBJECT_ID('stg.GeneralInterestRuleBaseType', 'U') IS NOT NULL
    DROP TABLE stg.GeneralInterestRuleBaseType;

CREATE TABLE stg.GeneralInterestRuleBaseType
(
    GeneralInterestRuleBaseTypeId TINYINT NULL,
    GeneralInterestRuleBaseTypeName VARCHAR(50) NULL,
    DmlOperation CHAR(1) NOT NULL
);

GO
