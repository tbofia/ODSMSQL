
IF OBJECT_ID('stg.CustomEndnote', 'U') IS NOT NULL
DROP TABLE stg.CustomEndnote
BEGIN
	CREATE TABLE stg.CustomEndnote (
		CustomEndnote INT NULL,
        ShortDescription VARCHAR(50) NULL,
        LongDescription VARCHAR(500) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO


