IF OBJECT_ID('stg.PlaceOfServiceDictionary','U') IS NOT NULL
DROP TABLE stg.PlaceOfServiceDictionary
BEGIN
	CREATE TABLE stg.PlaceOfServiceDictionary (
		PlaceOfServiceCode SMALLINT NULL
	    ,[Description] VARCHAR(255) NULL
	    ,Facility SMALLINT NULL
	    ,MHL SMALLINT NULL
	    ,PlusFour SMALLINT NULL
	    ,Institution INT NULL
	    ,StartDate DATETIME2(7) NULL
	    ,EndDate DATETIME2(7) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END 
GO


