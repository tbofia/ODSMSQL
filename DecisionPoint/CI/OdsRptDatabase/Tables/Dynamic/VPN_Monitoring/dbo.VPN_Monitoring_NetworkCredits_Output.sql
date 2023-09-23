IF OBJECT_ID('dbo.VPN_Monitoring_NetworkCredits_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.VPN_Monitoring_NetworkCredits_Output
    (
        OdsCustomerId INT NOT NULL ,
        Customer VARCHAR(100) NOT NULL ,
        Period DATETIME NOT NULL ,
        SOJ VARCHAR(2) NULL ,
        CV_Type VARCHAR(10) NULL ,
        BillType VARCHAR(8) NULL ,
        Network VARCHAR(50) NULL ,
        Company VARCHAR(50) NULL ,
        Office VARCHAR(40) NULL ,
        ActivityFlagDesc VARCHAR(50) NULL ,
        CreditReasonDesc VARCHAR(100) NULL ,
        Credits MONEY NULL ,
        RunDate DATETIME NULL
    ); 
END

GO





