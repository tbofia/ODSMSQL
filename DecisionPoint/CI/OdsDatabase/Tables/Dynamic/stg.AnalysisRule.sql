IF OBJECT_ID('stg.AnalysisRule', 'U') IS NOT NULL
    DROP TABLE stg.AnalysisRule;
BEGIN
    CREATE TABLE stg.AnalysisRule
        (
         AnalysisRuleId INT NULL
        ,Title VARCHAR(200) NULL
        ,AssemblyQualifiedName VARCHAR(200) NULL
        ,MethodToInvoke VARCHAR(50) NULL
        ,DisplayMessage NVARCHAR(200) NULL
        ,DisplayOrder INT NULL
        ,IsActive BIT NULL
        ,CreateDate DATETIMEOFFSET(7) NULL
        ,LastChangedOn DATETIMEOFFSET(7) NULL
        ,MessageToken NVARCHAR(200) NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
