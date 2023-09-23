IF OBJECT_ID('stg.ProviderSpecialtyToProvType', 'U') IS NOT NULL
DROP TABLE stg.ProviderSpecialtyToProvType
BEGIN
CREATE TABLE stg.ProviderSpecialtyToProvType(
	ProviderType VARCHAR(20) NULL,
	ProviderType_Desc VARCHAR(80) NULL,
	Specialty VARCHAR(20) NULL,
	Specialty_Desc VARCHAR(80) NULL,
	CreateDate DATETIME NULL,
	ModifyDate DATETIME NULL,
	LogicalDelete CHAR(1) NULL,
	DmlOperation CHAR(1) NULL
)
END
GO

