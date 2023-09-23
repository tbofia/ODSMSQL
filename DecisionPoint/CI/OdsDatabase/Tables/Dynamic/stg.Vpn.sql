IF OBJECT_ID('stg.Vpn', 'U') IS NOT NULL
DROP TABLE stg.Vpn
BEGIN
	CREATE TABLE stg.Vpn (
		VpnId SMALLINT NULL
		,NetworkName VARCHAR(50) NULL
		,PendAndSend BIT NULL
		,BypassMatching BIT NULL
		,AllowsResends BIT NULL
		,OdsEligible BIT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
