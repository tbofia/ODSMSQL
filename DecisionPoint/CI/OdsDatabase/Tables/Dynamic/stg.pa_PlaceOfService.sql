IF OBJECT_ID('stg.pa_PlaceOfService', 'U') IS NOT NULL
DROP TABLE stg.pa_PlaceOfService
BEGIN
	CREATE TABLE stg.pa_PlaceOfService (
		POS SMALLINT NULL,
		Description VARCHAR(255) NULL,
		Facility SMALLINT NULL,
		MHL SMALLINT NULL,
		PlusFour SMALLINT NULL,
		Institution INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
