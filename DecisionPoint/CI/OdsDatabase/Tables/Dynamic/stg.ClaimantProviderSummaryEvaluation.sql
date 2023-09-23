IF OBJECT_ID('stg.ClaimantProviderSummaryEvaluation', 'U') IS NOT NULL
    DROP TABLE stg.ClaimantProviderSummaryEvaluation;
BEGIN
    CREATE TABLE stg.ClaimantProviderSummaryEvaluation
        (
         ClaimantProviderSummaryEvaluationId INT NULL
        ,ClaimantHeaderId INT NULL
        ,EvaluatedAmount DECIMAL(19, 4) NULL
        ,MinimumEvaluatedAmount DECIMAL(19, 4) NULL
        ,MaximumEvaluatedAmount DECIMAL(19, 4) NULL
        ,Comments VARCHAR(255) NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END;
GO
