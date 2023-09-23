IF OBJECT_ID('stg.Provider_Rendering', 'U') IS NOT NULL
    DROP TABLE stg.Provider_Rendering;
BEGIN
    CREATE TABLE stg.Provider_Rendering
        (
          PvdIDNo INT NULL ,
          RenderingAddr1 VARCHAR(55) NULL ,
          RenderingAddr2 VARCHAR(55) NULL ,
          RenderingCity VARCHAR(30) NULL ,
          RenderingState VARCHAR(2) NULL ,
          RenderingZip VARCHAR(12) NULL ,
		  DmlOperation CHAR(1) NOT NULL
        );
END
GO
