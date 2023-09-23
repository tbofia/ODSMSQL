IF OBJECT_ID('stg.Rsn_Reasons_3rdParty', 'U') IS NOT NULL
	DROP TABLE stg.Rsn_Reasons_3rdParty
BEGIN
	CREATE TABLE stg.Rsn_Reasons_3rdParty 
		(
		ReasonNumber INT NULL,
		ShortDesc VARCHAR(50) NULL,
		LongDesc VARCHAR(MAX) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
