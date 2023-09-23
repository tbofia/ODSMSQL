IF OBJECT_ID('stg.AdjusterPendGroup', 'U') IS NOT NULL 
	DROP TABLE stg.AdjusterPendGroup  
BEGIN
	CREATE TABLE stg.AdjusterPendGroup
		(
		  ClaimSysSubset CHAR (4) NULL,
		  Adjuster VARCHAR (25) NULL,
		  PendGroupCode VARCHAR (12) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

