IF OBJECT_ID('stg.ProviderSpecialty', 'U') IS NOT NULL
DROP TABLE stg.ProviderSpecialty
BEGIN
	CREATE TABLE stg.ProviderSpecialty (
		ProviderId INT NULL,
        SpecialtyCode VARCHAR(50) NULL,       
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
