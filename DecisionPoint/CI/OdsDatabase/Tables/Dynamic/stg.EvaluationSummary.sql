IF OBJECT_ID('stg.EvaluationSummary', 'U') IS NOT NULL 
	DROP TABLE stg.EvaluationSummary  
BEGIN
	CREATE TABLE stg.EvaluationSummary
		(
		  DemandClaimantId INT NULL,
		  Details NVARCHAR (MAX) NULL,
		  CreatedBy NVARCHAR (50) NULL,
		  CreatedDate DATETIMEOFFSET NULL,
		  ModifiedBy NVARCHAR (50) NULL,
		  ModifiedDate DATETIMEOFFSET NULL,
		  EvaluationSummaryTemplateVersionId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

