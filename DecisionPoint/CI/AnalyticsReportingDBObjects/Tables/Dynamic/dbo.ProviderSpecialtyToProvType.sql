IF OBJECT_ID('dbo.ProviderSpecialtyToProvType', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.ProviderSpecialtyToProvType (
		ProviderType VARCHAR(20) NOT NULL
		,ProviderType_Desc VARCHAR(80) NULL
		,Specialty VARCHAR(20) NOT NULL
		,Specialty_Desc VARCHAR(80) NULL
		,CreateDate DATETIME NOT NULL
		,ModifyDate DATETIME NULL
		,LogicalDelete CHAR(1) NOT NULL
		);

	ALTER TABLE dbo.ProviderSpecialtyToProvType ADD 
	CONSTRAINT PK_ProviderSpecialtyToProvType PRIMARY KEY CLUSTERED (ProviderType,Specialty);
END
GO

