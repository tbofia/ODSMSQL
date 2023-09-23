IF OBJECT_ID('stg.LossYearReport_EncounterTypeId', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_EncounterTypeId; 
BEGIN

	CREATE TABLE stg.LossYearReport_EncounterTypeId(
		OdsCustomerId INT NULL,
		BillIDNo INT NULL,
		EncounterTypeId INT NULL,
		RunDate DATETIME NOT NULL
	);

END
GO


