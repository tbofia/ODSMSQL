IF OBJECT_ID('stg.ny_Specialty', 'U') IS NOT NULL 
	DROP TABLE stg.ny_Specialty  
BEGIN
	CREATE TABLE stg.ny_Specialty
		(
		  RatingCode VARCHAR (12) NULL,
		  Desc_ VARCHAR (70) NULL,
		  CbreSpecialtyCode VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

