IF OBJECT_ID('adm.AppVersion', 'U') IS NULL
BEGIN

    CREATE TABLE adm.AppVersion
        (
            AppVersionId INT IDENTITY(1, 1) ,
            AppVersion VARCHAR(10) NULL ,
            AppVersionDate DATETIME2(7) NULL,
			ProductKey VARCHAR(100) NULL
        );

    ALTER TABLE adm.AppVersion ADD 
    CONSTRAINT PK_AppVersion PRIMARY KEY CLUSTERED (AppVersionId);

END
GO

-- Add Product Key Column
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'adm.AppVersion')
						AND NAME = 'ProductKey' )
	BEGIN
		ALTER TABLE adm.AppVersion ADD ProductKey VARCHAR(100) NULL ;
	END ; 
GO
