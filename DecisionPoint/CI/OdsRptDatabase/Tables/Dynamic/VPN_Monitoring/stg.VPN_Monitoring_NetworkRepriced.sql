IF OBJECT_ID('stg.VPN_Monitoring_NetworkRepriced', 'U') IS NOT NULL
DROP TABLE stg.VPN_Monitoring_NetworkRepriced
BEGIN
    CREATE TABLE stg.VPN_Monitoring_NetworkRepriced
        (
            StartOfMonth DATETIME NULL ,
            ReportYear INT NULL ,
            ReportMonth INT NULL ,
            OdsCustomerId INT  NULL ,
            SOJ VARCHAR(2) NULL , --
            NetworkName VARCHAR(50) NULL ,
            BillType VARCHAR(8) NULL ,
            CV_Type VARCHAR(2)  NULL ,
            Company VARCHAR(50)  NULL ,
            Office VARCHAR(40)  NULL ,
            InNetworkCharges MONEY NULL ,
            InNetworkAmountAllowed MONEY NULL ,
            Savings MONEY NULL ,
            VPNAllowed MONEY NULL ,
            Credits MONEY NULL ,
            NetSavings MONEY NULL ,
            DateTimeStamp DATETIME NULL
        )
END
GO

