IF OBJECT_ID('stg.Provider_ClientRef', 'U') IS NOT NULL
DROP TABLE stg.Provider_ClientRef
BEGIN
	CREATE TABLE stg.Provider_ClientRef (
			PvdIdNo INT NULL,
			ClientRefId VARCHAR(50) NULL,
			ClientRefId2 VARCHAR(100) NULL,
			DmlOperation CHAR(1) NOT NULL
		)
END
GO
