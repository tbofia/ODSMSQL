IF OBJECT_ID('stg.EncounterType', 'U') IS NULL
    BEGIN
        CREATE TABLE stg.EncounterType
            (
			  EncounterTypeId TINYINT NULL
	           ,EncounterTypePriority TINYINT NULL
	           ,[Description] VARCHAR(100) NULL
	           ,NarrativeInformation VARCHAR(max) NULL
			 ,DmlOperation CHAR(1) NOT NULL
          	)
END
GO




