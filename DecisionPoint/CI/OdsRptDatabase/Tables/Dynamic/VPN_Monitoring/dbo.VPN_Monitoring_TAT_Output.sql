
IF OBJECT_ID('dbo.VPN_Monitoring_TAT_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_TAT_Output(
	OdsCustomerId INT NOT NULL,
	StartOfMonth datetime NOT NULL,
	Client nvarchar(100) NOT NULL,
	BillIdNo int NOT NULL,
	ClaimIdNo int NOT NULL,
	SOJ varchar(2) NOT NULL,
	NetworkId int NOT NULL,
	NetworkName varchar(50) NOT NULL,
	SentDate datetime NOT NULL,
	ReceivedDate datetime NULL,
	HoursLockedToVPN int NOT NULL,
	TATInHours int NULL,
	TAT int NULL,
	BillCreateDate datetime NULL,
	ParNonPar nchar(10) NULL,
	SubNetwork varchar(50) NULL,
	AmtCharged money NULL,
	BillType nchar(10) NULL,
	Bucket varchar(50) NULL,
	ValueBucket varchar(50) NULL,
	RunDate datetime NULL);
END
GO

IF EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_TAT_Output')
                        AND NAME = 'LastUpdate' )
	IF NOT EXISTS ( SELECT  1
                FROM    sys.columns
                WHERE   object_id = OBJECT_ID(N'dbo.VPN_Monitoring_TAT_Output')
                        AND NAME = 'RunDate' )
    BEGIN
        EXEC sp_rename 'dbo.VPN_Monitoring_TAT_Output.LastUpdate', 'RunDate', 'COLUMN'; 
    END;
GO



