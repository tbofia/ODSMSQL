
IF OBJECT_ID('stg.StateSettingsOregon', 'U') IS NOT NULL
DROP TABLE stg.StateSettingsOregon
BEGIN
	CREATE TABLE stg.StateSettingsOregon 
	(
		StateSettingsOregonId TINYINT NULL,
		ApplyOregonFeeSchedule BIT NULL,
		DmlOperation CHAR(1) NOT NULL
	)
END
GO

