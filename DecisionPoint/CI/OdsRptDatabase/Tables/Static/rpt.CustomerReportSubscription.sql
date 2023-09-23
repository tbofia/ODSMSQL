IF OBJECT_ID('rpt.CustomerReportSubscription', 'U') IS NULL
BEGIN
CREATE TABLE rpt.CustomerReportSubscription(
	ReportID INT NOT NULL,
	CustomerId INT NOT NULL,
	IsActive BIT NOT NULL,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NULL
);
END
GO


