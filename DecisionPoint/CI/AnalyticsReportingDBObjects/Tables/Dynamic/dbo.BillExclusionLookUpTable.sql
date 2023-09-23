IF OBJECT_ID('dbo.BillExclusionLookUpTable', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.BillExclusionLookUpTable (
		ReportID TINYINT NOT NULL
		,ReportName NVARCHAR(100) NOT NULL
		);

	ALTER TABLE dbo.BillExclusionLookUpTable ADD 
	CONSTRAINT PK_BillExclusionLookUpTable PRIMARY KEY CLUSTERED (ReportID ASC);
END
GO

