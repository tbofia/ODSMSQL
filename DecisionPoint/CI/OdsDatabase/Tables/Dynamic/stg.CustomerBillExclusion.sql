IF OBJECT_ID('stg.CustomerBillExclusion', 'U') IS NOT NULL
DROP TABLE stg.CustomerBillExclusion
BEGIN
	CREATE TABLE stg.CustomerBillExclusion (
		  BillIdNo int  NULL
	     ,Customer nvarchar(50)  NULL
	     ,ReportID tinyint  NULL
		 ,CreateDate datetime  NULL
		 ,DmlOperation CHAR(1)  NULL
		)
END
GO
