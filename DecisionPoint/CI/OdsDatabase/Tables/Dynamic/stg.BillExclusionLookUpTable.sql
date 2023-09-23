IF OBJECT_ID('stg.BillExclusionLookUpTable', 'U') IS NOT NULL
DROP TABLE stg.BillExclusionLookUpTable
BEGIN
	CREATE TABLE stg.BillExclusionLookUpTable (
		  ReportID tinyint  NULL
	     ,ReportName nvarchar(100)  NULL
		 ,DmlOperation CHAR(1)  NULL
		)
END
GO
