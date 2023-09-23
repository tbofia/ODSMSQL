IF OBJECT_ID('stg.TreatmentCategoryRange', 'U') IS NOT NULL
DROP TABLE stg.TreatmentCategoryRange
BEGIN
	CREATE TABLE stg.TreatmentCategoryRange (
		TreatmentCategoryRangeId int NULL
	   ,TreatmentCategoryId tinyint NULL
	   ,StartRange varchar(7) NULL
	   ,EndRange varchar(7) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
