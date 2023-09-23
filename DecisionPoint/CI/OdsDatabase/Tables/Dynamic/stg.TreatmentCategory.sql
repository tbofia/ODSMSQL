IF OBJECT_ID('stg.TreatmentCategory', 'U') IS NOT NULL
DROP TABLE stg.TreatmentCategory
BEGIN
	CREATE TABLE stg.TreatmentCategory (
		TreatmentCategoryId tinyint NULL
	   ,Category varchar(50) NULL
	   ,Metadata nvarchar(max) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
