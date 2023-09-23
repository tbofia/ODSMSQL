IF OBJECT_ID('stg.EvaluationSummaryHistory', 'U') IS NOT NULL 
	DROP TABLE stg.EvaluationSummaryHistory  
BEGIN
	CREATE TABLE stg.EvaluationSummaryHistory
		(
		  EvaluationSummaryHistoryId INT NULL,
		  DemandClaimantId INT NULL,
		  EvaluationSummary NVARCHAR (MAX) NULL,
		  CreatedBy NVARCHAR (50) NULL,
		  CreatedDate DATETIMEOFFSET NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

