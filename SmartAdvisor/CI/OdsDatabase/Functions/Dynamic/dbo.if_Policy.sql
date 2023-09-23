IF OBJECT_ID('dbo.if_Policy', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Policy;
GO

CREATE FUNCTION dbo.if_Policy(
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
	t.ClaimSysSubSet,
	t.PolicySeq,
	t.Name,
	t.ExternalID,
	t.PolicyID,
	t.AdminKey,
	t.LocationCode,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.FaxNum,
	t.EffectiveDate,
	t.TerminationDate,
	t.TIN,
	t.StateTaxID,
	t.DeptIndusRelNum,
	t.EqOppIndicator,
	t.ModUserID,
	t.ModDate,
	t.MCOFlag,
	t.MCOStartDate,
	t.FeeRateCtrlEx,
	t.CreateBy,
	t.FeeRateCtrlIn,
	t.CreateDate,
	t.SelfInsured,
	t.NAICSCode,
	t.MonthlyPremium,
	t.PPOProfileSiteCode,
	t.PPOProfileID,
	t.SalesTaxExempt,
	t.ReceiptHandlingCode,
	t.TxNonSubscrib,
	t.SubdivisionName,
	t.PolicyCoPayAmount,
	t.PolicyCoPayPct,
	t.PolicyDeductible,
	t.PolicyLimitAmount,
	t.PolicyTimeLimit,
	t.PolicyLimitWarningPct,
	t.PolicyLimitResult,
	t.URProfileID
FROM src.Policy t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		PolicySeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Policy
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		PolicySeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.PolicySeq = s.PolicySeq
WHERE t.DmlOperation <> 'D';

GO


