IF OBJECT_ID('stg.ModifierToProcedureCode', 'U') IS NOT NULL 
	DROP TABLE stg.ModifierToProcedureCode  
BEGIN
	CREATE TABLE stg.ModifierToProcedureCode
		(
		  ProcedureCode VARCHAR (5) NULL,
		  Modifier VARCHAR (2) NULL,
		  StartDate DATETIME2 (7) NULL,
		  EndDate DATETIME2 (7) NULL,
		  SojFlag SMALLINT NULL,
		  RequiresGuidelineReview BIT NULL,
		  Reference VARCHAR (255) NULL,
		  Comments VARCHAR (255) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

