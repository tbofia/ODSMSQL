IF OBJECT_ID('stg.CLAIMS', 'U') IS NOT NULL
    DROP TABLE stg.CLAIMS;
BEGIN
    CREATE TABLE stg.CLAIMS
        (
         ClaimIDNo INT NULL
        ,ClaimNo VARCHAR(MAX) NULL
        ,DateLoss DATETIME NULL
        ,CV_Code VARCHAR(2) NULL
        ,DiaryIndex INT NULL
        ,LastSaved DATETIME NULL
        ,PolicyNumber VARCHAR(50) NULL
        ,PolicyHoldersName VARCHAR(30) NULL
        ,PaidDeductible MONEY NULL
        ,STATUS VARCHAR(1) NULL
        ,InUse VARCHAR(100) NULL
        ,CompanyID INT NULL
        ,OfficeIndex INT NULL
        ,AdjIdNo INT NULL
        ,PaidCoPay MONEY NULL
        ,AssignedUser VARCHAR(15) NULL
        ,Privatized SMALLINT NULL
        ,PolicyEffDate DATETIME NULL
        ,Deductible MONEY NULL
        ,LossState VARCHAR(2) NULL
        ,AssignedGroup INT NULL
        ,CreateDate DATETIME NULL
        ,LastChangedOn DATETIME NULL
        ,AllowMultiCoverage BIT NULL
        ,DmlOperation CHAR(1) NOT NULL
        );
END; 
GO
