IF OBJECT_ID('adm.Customer', 'U') IS NULL
    BEGIN
        CREATE TABLE adm.Customer(
			CustomerId INT NOT NULL,
			CustomerName VARCHAR(100) NOT NULL,
			CustomerDatabase VARCHAR(255) NOT NULL,
			EbtCompCode CHAR(2) NULL,
			ServerName VARCHAR(255),
			IsActive BIT NOT NULL,
			IsSelfHosted INT NOT NULL,
			IsFromDecisionPoint INT NOT NULL,
			IsLoadedDaily INT NOT NULL,
			UseForReporting INT NOT NULL,
			IncludeInIndustry INT NOT NULL
            );

        ALTER TABLE adm.Customer ADD 
        CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED (CustomerId);
    END
GO
