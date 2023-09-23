IF OBJECT_ID('stg.InjuryNature', 'U') IS NULL
    BEGIN
        CREATE TABLE stg.InjuryNature
            (
			  InjuryNatureId TINYINT NULL
	           ,InjuryNaturePriority TINYINT NULL
	           ,[Description] VARCHAR(100) NULL
	           ,NarrativeInformation VARCHAR(max) NULL
			 ,DmlOperation CHAR(1) NOT NULL
          	)
END
GO




