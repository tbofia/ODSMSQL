IF OBJECT_ID('stg.rsn_REASONS', 'U') IS NOT NULL
    DROP TABLE stg.rsn_REASONS;
BEGIN
    CREATE TABLE stg.rsn_REASONS
        (
         ReasonNumber INT NULL
        ,CV_Type VARCHAR(2) NULL
        ,ShortDesc VARCHAR(50) NULL
        ,LongDesc VARCHAR(MAX) NULL
        ,CategoryIdNo INT NULL
        ,COAIndex SMALLINT NULL
        ,OverrideEndnote INT NULL
        ,HardEdit SMALLINT NULL
        ,SpecialProcessing BIT NULL
        ,EndnoteActionId TINYINT NULL
        ,RetainForEapg BIT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
