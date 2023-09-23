IF OBJECT_ID('dbo.ProcedureCodeAnalysis_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.ProcedureCodeAnalysis_Output(
	OdsCustomerId INT NOT NULL,
	ReportName varchar(50) NULL,
	DisplayName varchar(255) NULL,
	Code varchar(50) NULL,
	[Desc] varchar(max) NULL,
	MajorGroup varchar(200) NULL,
	CoverageType varchar(20) NULL,
	CoverageTypeDesc varchar(100) NULL,
	FormType varchar(20) NULL,
	[State] varchar(20) NULL,
	County varchar(50) NULL,
	Company varchar(100) NULL,
	Office varchar(100) NULL,
	[Year] int NULL,
	[Quarter] varchar(8) NULL,
	DateQuarter varchar(20) NULL,
	TotalCharged money NULL,
	IndTotalCharged money NULL,
	TotalAllowed money NULL,
	IndTotalAllowed money NULL,
	ClaimCnt int NULL,
	IndClaimCnt int NULL,
	ClaimantCnt int NULL,
	IndClaimantCnt int NULL,
	TotalReduction money NULL,
	IndTotalReduction money NULL,
	TotalBills int NULL,
	IndTotalBills int NULL,
	TotalLines int NULL,
	IndTotalLines int NULL,
	TotalUnits int NULL,
	IndTotalUnits int NULL,
	RunDate datetime NOT NULL DEFAULT GETDATE() 
);
END
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.ProcedureCodeAnalysis_Output')
                        AND NAME = 'CreateDate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.ProcedureCodeAnalysis_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.ProcedureCodeAnalysis_Output.CreateDate', 'RunDate', 'COLUMN'; 
    END;
GO




