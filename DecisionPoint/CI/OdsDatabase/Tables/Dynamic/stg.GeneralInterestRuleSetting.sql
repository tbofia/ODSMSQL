IF OBJECT_ID('stg.GeneralInterestRuleSetting', 'U') IS NOT NULL
    DROP TABLE stg.GeneralInterestRuleSetting;
BEGIN
    CREATE TABLE stg.GeneralInterestRuleSetting
        (
         GeneralInterestRuleBaseTypeId TINYINT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO

