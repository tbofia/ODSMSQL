IF OBJECT_ID('dbo.MedicalCodeCutOffs', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.MedicalCodeCutOffs(
		CodeTypeID INT NOT NULL,
		CodeType VARCHAR(50) NULL,
		Code VARCHAR(50) NOT NULL,
		FormType VARCHAR(10) NOT NULL,
		MaxChargedPerUnit FLOAT NULL,
		MaxUnitsPerEncounter FLOAT NULL);
	ALTER TABLE dbo.MedicalCodeCutOffs ADD
	CONSTRAINT PK_MedicalCodeCutOffs PRIMARY KEY CLUSTERED (CodeTypeID ASC,	Code ASC,FormType ASC) 
END
GO 
