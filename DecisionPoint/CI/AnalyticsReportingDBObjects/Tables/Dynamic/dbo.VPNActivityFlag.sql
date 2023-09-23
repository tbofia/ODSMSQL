IF OBJECT_ID('dbo.VPNActivityFlag', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.VPNActivityFlag(
		Activity_Flag VARCHAR(1) NOT NULL,
		AF_Description VARCHAR(50) NULL,
		AF_ShortDesc VARCHAR(50) NULL,
		Data_Source VARCHAR(5) NULL,
		Default_Billable BIT NULL,
		Credit BIT NULL);
		
	ALTER TABLE dbo.VPNActivityFlag 
	ADD CONSTRAINT PK_VPNActivityFlag PRIMARY KEY CLUSTERED (Activity_Flag)
END
GO
