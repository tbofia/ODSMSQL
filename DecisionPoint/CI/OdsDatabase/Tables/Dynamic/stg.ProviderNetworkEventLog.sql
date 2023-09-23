IF OBJECT_ID('stg.ProviderNetworkEventLog', 'U') IS NOT NULL
DROP TABLE stg.ProviderNetworkEventLog
BEGIN
CREATE TABLE stg.ProviderNetworkEventLog(
	IDField int NOT NULL,
	LogDate datetime NULL,
	EventId int NULL,
	ClaimIdNo int NULL,
	BillIdNo int NULL,
	UserId int NULL,
	NetworkId int NULL,
	FileName varchar(255) NULL,
	ExtraText varchar(1000) NULL,
	ProcessInfo smallint NULL,
	TieredTypeID smallint NULL,
	TierNumber smallint NULL,
	DmlOperation char(1) NOT NULL
		)
END
GO
