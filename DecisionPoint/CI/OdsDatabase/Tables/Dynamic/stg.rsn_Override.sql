IF OBJECT_ID('stg.rsn_Override', 'U') IS NOT NULL
DROP TABLE stg.rsn_Override
BEGIN
	CREATE TABLE stg.rsn_Override (
		ReasonNumber INT NULL
		,ShortDesc VARCHAR(50) NULL
		,LongDesc VARCHAR(MAX) NULL
		,CategoryIdNo SMALLINT NULL
		,ClientSpec SMALLINT NULL
		,COAIndex SMALLINT NULL
		,NJPenaltyPct DECIMAL(9, 6) NULL
		,NetworkID INT NULL
		,SpecialProcessing BIT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
