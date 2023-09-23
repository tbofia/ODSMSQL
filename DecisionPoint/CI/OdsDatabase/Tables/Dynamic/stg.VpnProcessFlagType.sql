IF OBJECT_ID('stg.VpnProcessFlagType', 'U') IS NOT NULL 
	DROP TABLE stg.VpnProcessFlagType  
BEGIN
	CREATE TABLE stg.VpnProcessFlagType
		(
		  VpnProcessFlagTypeId SMALLINT NULL,
		  VpnProcessFlagType VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

