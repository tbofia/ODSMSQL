
IF OBJECT_ID('rpt.ProviderAnalyticsCodeHierarchy', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsCodeHierarchy

GO

IF OBJECT_ID('rpt.ProviderDataExplorerCodeHierarchy','U') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerCodeHierarchy(
	CodeStart VARCHAR(50) NOT NULL,
	CodeEnd VARCHAR(50) NOT NULL,
	Category VARCHAR(200) NULL,
	SubCategory VARCHAR(200) NULL,
	Description VARCHAR(250) NULL,
	CodeType VARCHAR(50) NOT NULL,
	IsCodeNumeric bit NULL
)
	ALTER TABLE rpt.ProviderDataExplorerCodeHierarchy ADD 
	CONSTRAINT PK_ProviderDataExplorerCodeHierarchy PRIMARY KEY CLUSTERED
	(
		CodeStart,
		CodeEnd,
		CodeType
	);

END
GO
