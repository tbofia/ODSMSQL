IF OBJECT_ID('stg.ny_pharmacy', 'U') IS NOT NULL
DROP TABLE stg.ny_pharmacy
BEGIN
	CREATE TABLE stg.ny_pharmacy (
		NDCCode VARCHAR(13) NULL
		,StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,Description VARCHAR(125) NULL
		,Fee MONEY NULL
		,TypeOfDrug SMALLINT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
