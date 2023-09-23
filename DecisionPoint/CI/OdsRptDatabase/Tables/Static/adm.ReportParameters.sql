IF OBJECT_ID('adm.ReportParameters', 'U') IS NULL
BEGIN
CREATE TABLE adm.ReportParameters(
	ReportId int NOT NULL,
	ParameterName varchar(50) NOT NULL,
	ParameterDesc varchar(500) NULL,
	ParameterValue varchar(600) NULL,
	CreatedDate datetime NOT NULL DEFAULT GETDATE() )

	ALTER TABLE adm.ReportParameters ADD 
	CONSTRAINT PK_ReportParameters PRIMARY KEY CLUSTERED (
		ReportId ASC,
		ParameterName ASC)
END

GO

