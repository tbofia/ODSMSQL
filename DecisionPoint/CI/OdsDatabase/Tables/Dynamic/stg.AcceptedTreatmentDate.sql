IF OBJECT_ID('stg.AcceptedTreatmentDate', 'U') IS NOT NULL
DROP TABLE stg.AcceptedTreatmentDate
BEGIN
	CREATE TABLE stg.AcceptedTreatmentDate (
		AcceptedTreatmentDateId int NULL
	   ,DemandClaimantId int  NULL
	   ,TreatmentDate datetimeoffset(7) NULL
	   ,Comments varchar(255) NULL
	   ,TreatmentCategoryId tinyint NULL
	   ,LastUpdatedBy varchar(15) NULL
	   ,LastUpdatedDate datetimeoffset(7) NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
