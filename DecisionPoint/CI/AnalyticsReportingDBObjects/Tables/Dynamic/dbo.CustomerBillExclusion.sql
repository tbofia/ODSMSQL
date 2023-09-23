IF OBJECT_ID('dbo.CustomerBillExclusion', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.CustomerBillExclusion (
		BIllIdNo INT NOT NULL
		,Customer NVARCHAR(50) NOT NULL
		,ReportID TINYINT NOT NULL
		,CreateDate DATETIME NULL
		);
		
	ALTER TABLE dbo.CustomerBillExclusion ADD
	CONSTRAINT PK_CustomerBillExclusion PRIMARY KEY CLUSTERED (BIllIdNo ASC,Customer ASC,ReportID ASC);
END
GO


-- Add CreateDate column to dbo.CustomerBillExclusion
IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.CustomerBillExclusion')
                        AND NAME = 'CreateDate' )
BEGIN
    ALTER TABLE dbo.CustomerBillExclusion ADD CreateDate datetime DEFAULT Getdate()  
END
GO


