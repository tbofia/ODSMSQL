IF OBJECT_ID('dbo.if_Vpn_Billing_History', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Vpn_Billing_History;
GO

CREATE FUNCTION dbo.if_Vpn_Billing_History(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 t.OdsPostingGroupAuditId,
	t.OdsCustomerId,
	t.OdsCreateDate,
	t.OdsSnapshotDate,
	t.OdsRowIsCurrent,
	t.OdsHashbytesValue,
	t.DmlOperation,
	t.Customer,
	t.TransactionID,
	t.Period,
	t.ActivityFlag,
	t.BillableFlag,
	t.Void,
	t.CreditType,
	t.Network,
	t.BillIdNo,
	t.Line_No,
	t.TransactionDate,
	t.RepriceDate,
	t.ClaimNo,
	t.ProviderCharges,
	t.DPAllowed,
	t.VPNAllowed,
	t.Savings,
	t.Credits,
	t.NetSavings,
	t.SOJ,
	t.seqno,
	t.CompanyCode,
	t.VpnId,
	t.ProcessFlag,
	t.SK,
	t.DATABASE_NAME,
	t.SubmittedToFinance,
	t.IsInitialLoad,
	t.VpnBillingCategoryCode
FROM src.Vpn_Billing_History t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TransactionID,
		Period,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Vpn_Billing_History
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TransactionID,
		Period) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TransactionID = s.TransactionID
	AND t.Period = s.Period
WHERE t.DmlOperation <> 'D';

GO


