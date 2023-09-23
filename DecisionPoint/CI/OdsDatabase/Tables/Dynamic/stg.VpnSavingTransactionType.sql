IF OBJECT_ID('stg.VpnSavingTransactionType', 'U') IS NOT NULL 
	DROP TABLE stg.VpnSavingTransactionType  
BEGIN
	CREATE TABLE stg.VpnSavingTransactionType
		(
		  VpnSavingTransactionTypeId INT NULL,
		  VpnSavingTransactionType VARCHAR (50) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

