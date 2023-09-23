IF OBJECT_ID('stg.VpnBillingCategory', 'U') IS NOT NULL
DROP TABLE stg.VpnBillingCategory
BEGIN
CREATE TABLE stg.VpnBillingCategory (
		VpnBillingCategoryCode char(1) NOT NULL,
		VpnBillingCategoryDescription varchar(30) NULL,
		DmlOperation char(1) NOT NULL
		)
END
GO
