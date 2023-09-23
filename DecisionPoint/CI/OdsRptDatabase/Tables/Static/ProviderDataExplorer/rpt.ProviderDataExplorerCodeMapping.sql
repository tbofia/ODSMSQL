
IF OBJECT_ID('rpt.ProviderAnalyticsCodeMapping', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsCodeMapping

GO

IF OBJECT_ID('rpt.ProviderDataExplorerCodeMapping') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerCodeMapping
(
	CodeStart VARCHAR(20) NOT NULL,
	CodeEnd VARCHAR(20) NOT NULL,
	CodeType VARCHAR(50) NULL,
	CodeCategory VARCHAR(100) NULL,
	CodeSubCategory VARCHAR(20) NULL

)
	ALTER TABLE rpt.ProviderDataExplorerCodeMapping ADD 
	CONSTRAINT PK_ProviderDataExplorerCodeMapping PRIMARY KEY CLUSTERED
	(
		CodeStart,
		CodeEnd
	);
END
GO
		   