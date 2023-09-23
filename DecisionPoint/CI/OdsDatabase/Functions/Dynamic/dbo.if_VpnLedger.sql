IF OBJECT_ID('dbo.if_VpnLedger', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_VpnLedger;
GO

CREATE FUNCTION dbo.if_VpnLedger(
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
	t.TransactionID,
	t.TransactionTypeID,
	t.BillIdNo,
	t.Line_No,
	t.Charged,
	t.DPAllowed,
	t.VPNAllowed,
	t.Savings,
	t.Credits,
	t.HasOverride,
	t.EndNotes,
	t.NetworkIdNo,
	t.ProcessFlag,
	t.LineType,
	t.DateTimeStamp,
	t.SeqNo,
	t.VPN_Ref_Line_No,
	t.SpecialProcessing,
	t.CreateDate,
	t.LastChangedOn,
	t.AdjustedCharged
FROM src.VpnLedger t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TransactionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnLedger
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TransactionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TransactionID = s.TransactionID
WHERE t.DmlOperation <> 'D';

GO


