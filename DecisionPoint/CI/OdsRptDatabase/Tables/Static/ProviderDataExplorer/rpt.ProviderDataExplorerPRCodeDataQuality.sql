
IF OBJECT_ID('rpt.ProviderAnalyticsPRCodeDataQuality', 'U') IS NOT NULL
DROP TABLE rpt.ProviderAnalyticsPRCodeDataQuality

GO

IF OBJECT_ID('rpt.ProviderDataExplorerPRCodeDataQuality','U') IS NULL
BEGIN
CREATE TABLE rpt.ProviderDataExplorerPRCodeDataQuality
(
	Code VARCHAR(50) NOT NULL,
	Description VARCHAR(1000) NULL,
	Comments VARCHAR(150) NULL,
	Category VARCHAR(150) NULL,
	SubCategory VARCHAR(150) NULL,
	MappedCode VARCHAR(50) NULL,
	ExceptionFlag VARCHAR(25) NULL
	)
	ALTER TABLE rpt.ProviderDataExplorerPRCodeDataQuality ADD 
	CONSTRAINT PK_ProviderDataExplorerPRCodeDataQuality PRIMARY KEY CLUSTERED
	(
		Code
	);

END
GO
