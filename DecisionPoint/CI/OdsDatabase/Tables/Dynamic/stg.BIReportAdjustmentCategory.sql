IF OBJECT_ID('stg.BIReportAdjustmentCategory', 'U') IS NOT NULL 
	DROP TABLE stg.BIReportAdjustmentCategory  
BEGIN
	CREATE TABLE stg.BIReportAdjustmentCategory
		(
		  BIReportAdjustmentCategoryId INT NULL,
		  Name VARCHAR (50) NULL,
		  Description VARCHAR (500) NULL,
		  DisplayPriority INT NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

