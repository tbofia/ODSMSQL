
IF OBJECT_ID('adm.ReportCommand', 'U') IS NULL
    BEGIN
		CREATE TABLE adm.ReportCommand 
		  (
			ReportID INT NOT NULL,
			ReportName VARCHAR(100) NOT NULL,
			CommandID INT NOT NULL,
			CommandName VARCHAR(100) NOT NULL,
			CommandString VARCHAR(MAX) NULL,
			Argument VARCHAR(250) NULL,
			);
		ALTER TABLE adm.ReportCommand ADD 
        CONSTRAINT PK_ReportCommand PRIMARY KEY CLUSTERED (ReportID,CommandID);
    END
    
 GO
 