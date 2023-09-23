IF OBJECT_ID('stg.ProviderCluster', 'U') IS NOT NULL
    DROP TABLE stg.ProviderCluster;
BEGIN
    CREATE TABLE stg.ProviderCluster
        (
			PvdIDNo INT  NULL, 
			OrgOdsCustomerId INT  NULL,
			MitchellProviderKey VARCHAR(200) NULL,
			ProviderClusterKey VARCHAR(200) NULL,
			ProviderType VARCHAR(30) NULL,
			DmlOperation CHAR(1) NOT NULL
        )
END
GO

