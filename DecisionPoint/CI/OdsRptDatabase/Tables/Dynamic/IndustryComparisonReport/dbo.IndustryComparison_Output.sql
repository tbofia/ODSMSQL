IF OBJECT_ID('dbo.IndustryComparison_Output', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.IndustryComparison_Output
            (
              OdsCustomerId INT,
			  ReportName VARCHAR(50) NULL ,
              DisplayName VARCHAR(255) NULL ,
              Code VARCHAR(50) NULL ,
              [Desc] VARCHAR(MAX) NULL ,
              MajorGroup VARCHAR(200) NULL ,
              CoverageType VARCHAR(20) NULL ,
              CoverageTypeDesc VARCHAR(100) NULL ,
              FormType VARCHAR(20) NULL ,
              State VARCHAR(20) NULL ,
              County VARCHAR(50) NULL ,
              ProviderSpecialty VARCHAR(100) NULL ,
              ProviderSpecialty_Desc VARCHAR(MAX) NULL ,
              ProviderType VARCHAR(100) NULL ,
              ProviderType_Desc VARCHAR(MAX) NULL ,
              Year INT NULL ,
              Quarter VARCHAR(8) NULL ,
              DateQuarter DATETIME NULL ,
              TotalCharged MONEY NULL ,
              IndTotalCharged MONEY NULL ,
              TotalAllowed MONEY NULL ,
              IndTotalAllowed MONEY NULL ,
              ClaimCnt INT NULL ,
              IndClaimCnt INT NULL ,
              ClaimantCnt INT NULL ,
              IndClaimantCnt INT NULL ,
              TotalReduction MONEY NULL ,
              IndTotalReduction MONEY NULL ,
              TotalBills INT NULL ,
              IndTotalBills INT NULL ,
              TotalLines INT NULL ,
              IndTotalLines INT NULL ,
              TotalUnits NUMERIC(9,2) NULL ,
              IndTotalUnits NUMERIC(9,2) NULL ,
              RunDate DATETIME DEFAULT GETDATE() NOT NULL
            );
    END;
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.IndustryComparison_Output')
                        AND NAME = 'CreateDate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.IndustryComparison_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.IndustryComparison_Output.CreateDate', 'RunDate', 'COLUMN'; 
    END;
GO



