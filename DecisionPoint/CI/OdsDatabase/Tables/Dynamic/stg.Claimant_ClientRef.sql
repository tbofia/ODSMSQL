IF OBJECT_ID('stg.Claimant_ClientRef', 'U') IS NOT NULL
DROP TABLE stg.Claimant_ClientRef
BEGIN
	CREATE TABLE stg.Claimant_ClientRef (
		CmtIdNo INT NULL,
		CmtSuffix VARCHAR(50) NULL,
		ClaimIdNo INT NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
