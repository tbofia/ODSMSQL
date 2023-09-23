IF OBJECT_ID('rpt.Product', 'U') IS NULL
BEGIN

	CREATE TABLE rpt.Product(
		ProductKey      VARCHAR(100) NOT NULL,
		Name            VARCHAR(100) NOT NULL
		);

	ALTER TABLE rpt.Product 
	ADD CONSTRAINT PK_Product PRIMARY KEY CLUSTERED (ProductKey);

END

GRANT SELECT ON rpt.Product TO MedicalUserRole;

GO
