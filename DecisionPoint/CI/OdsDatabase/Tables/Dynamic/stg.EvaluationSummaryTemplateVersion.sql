IF OBJECT_ID('stg.EvaluationSummaryTemplateVersion', 'U') IS NOT NULL 
	DROP TABLE stg.EvaluationSummaryTemplateVersion  
BEGIN
	CREATE TABLE stg.EvaluationSummaryTemplateVersion
		(
		  EvaluationSummaryTemplateVersionId INT NULL,
		  Template NVARCHAR (MAX) NULL,
		  TemplateHash VARBINARY(32) NULL,
		  CreatedDate DATETIMEOFFSET NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

