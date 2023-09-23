USE [VPNAnalyticsDev]
GO

SELECT  vph.OdsPostingGroupAuditId ,
        vph.OdsCustomerId ,
        vph.OdsCreateDate ,
        vph.OdsSnapshotDate ,
        vph.OdsRowIsCurrent ,
        vph.OdsHashbytesValue ,
        vph.DmlOperation ,
        c.CustomerName ,
        vph.Period ,
        vph.Network ,
        vph.BillIdNo ,
        CASE WHEN vph.ActivityFlag IN ( 'S', 'M' )
             THEN SUM(vph.ProviderCharges)
        END AS INNNetworkCharges ,
        CASE WHEN vph.ActivityFlag IN ( 'S', 'M' ) THEN SUM(vph.DPAllowed)
        END AS INNNetworkDPAllowed ,
        CASE WHEN vph.ActivityFlag IN ( 'S', 'M' ) THEN SUM(vph.VPNAllowed)
        END AS VPNAllowed ,
        CASE WHEN vph.ActivityFlag IN ( 'S', 'M' ) THEN SUM(vph.Savings)
        END AS Savings ,
        CASE WHEN vph.ActivityFlag IN ( 'C', 'D', 'P', 'R', 'V' )
             THEN SUM(vph.Credits)
        END AS Credits ,
        SUM(vph.NetSavings) AS NetSavings ,
        vph.SOJ ,
        vph.CompanyCode ,
        vph.VpnId
FROM    dbo.Vpn_Billing_History vph
        JOIN dbo.Customer c ON c.CustomerId = vph.OdsCustomerId
WHERE   NOT EXISTS ( SELECT 1
                     FROM   dbo.VPNODSBillableFlags vpf
                     WHERE  vpf.OdsCustomerId = vph.OdsCustomerId
                            AND vpf.SOJ = vph.SOJ
                            AND vpf.NetworkID = vph.VpnId
                            AND vpf.ActivityFlag = vph.ActivityFlag )
GROUP BY vph.OdsPostingGroupAuditId ,
        vph.OdsCustomerId ,
        vph.OdsCreateDate ,
        vph.OdsSnapshotDate ,
        vph.OdsRowIsCurrent ,
        vph.OdsHashbytesValue ,
        vph.DmlOperation ,
        c.CustomerName ,
        vph.Period ,
        vph.Network ,
        vph.BillIdNo ,
        vph.ActivityFlag ,
        vph.SOJ ,
        vph.CompanyCode ,
        vph.VpnId


