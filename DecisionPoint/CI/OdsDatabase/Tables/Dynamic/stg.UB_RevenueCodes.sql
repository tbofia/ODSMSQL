IF OBJECT_ID('stg.UB_RevenueCodes', 'U') IS NOT NULL
DROP TABLE stg.UB_RevenueCodes
BEGIN
	CREATE TABLE stg.UB_RevenueCodes (
		RevenueCode VARCHAR(4) NULL
	   ,StartDate DATETIME NULL
	   ,EndDate DATETIME NULL
	   ,PRC_DESC VARCHAR(MAX) NULL
	   ,Flags INT NULL
	   ,Vague VARCHAR(1) NULL
	   ,PerVisit SMALLINT NULL
	   ,PerClaimant SMALLINT NULL
	   ,PerProvider SMALLINT NULL
	   ,BodyFlags INT NULL
	   ,DrugFlag SMALLINT NULL
	   ,CurativeFlag SMALLINT NULL
	   ,RevenueCodeSubCategoryId TINYINT NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END 
GO


