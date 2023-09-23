IF OBJECT_ID('stg.BIReportAdjustmentCategoryMapping', 'U') IS NOT NULL 
	DROP TABLE stg.BIReportAdjustmentCategoryMapping  
BEGIN
	CREATE TABLE stg.BIReportAdjustmentCategoryMapping
		(
		  BIReportAdjustmentCategoryId INT NULL,
		  Adjustment360SubCategoryId INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

