IF OBJECT_ID('adm.ReportJob', 'U') IS NULL
BEGIN
CREATE TABLE adm.ReportJob(
	ReportID int NOT NULL,
	ReportJobName varchar(255) NULL,
	SourceDatabaseName varchar(255) NOT NULL,
	EmailTo varchar(255) NOT NULL,
	CustomerListType int NOT NULL,
	RunType int NOT NULL,
	SnapshotDate datetime NULL,
	Priority int NOT NULL,
	Enabled int NOT NULL,
	RunWeekDay int NULL,
	IsDaily int NULL,
	IsWeekly int NULL,
	IsMonthly int NULL,
	IsQuarterly int NULL
)

 ALTER TABLE adm.ReportJob ADD 
        CONSTRAINT PK_ReportJob PRIMARY KEY CLUSTERED (ReportID);
END

GO
