
IF OBJECT_ID('stg.StateSettingsOregonCoverageType', 'U') IS NOT NULL
DROP TABLE stg.StateSettingsOregonCoverageType
BEGIN
	CREATE TABLE stg.StateSettingsOregonCoverageType 
	(
		StateSettingsOregonId TINYINT NULL,
		CoverageType VARCHAR(2) NULL,
		DmlOperation CHAR(1) NOT NULL
	)
END
GO

