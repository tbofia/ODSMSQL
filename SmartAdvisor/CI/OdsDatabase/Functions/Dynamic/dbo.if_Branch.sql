IF OBJECT_ID('dbo.if_Branch', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Branch;
GO

CREATE FUNCTION dbo.if_Branch(
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
	t.BranchSeq,
	t.Name,
	t.ExternalID,
	t.BranchID,
	t.LocationCode,
	t.AdminKey,
	t.Address1,
	t.Address2,
	t.City,
	t.State,
	t.Zip,
	t.PhoneNum,
	t.FaxNum,
	t.ContactName,
	t.TIN,
	t.StateTaxID,
	t.DIRNum,
	t.ModUserID,
	t.ModDate,
	t.RuleFire,
	t.FeeRateCntrlEx,
	t.FeeRateCntrlIn,
	t.SalesTaxExempt,
	t.EffectiveDate,
	t.TerminationDate
FROM src.Branch t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimSysSubSet,
		BranchSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Branch
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimSysSubSet,
		BranchSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimSysSubSet = s.ClaimSysSubSet
	AND t.BranchSeq = s.BranchSeq
WHERE t.DmlOperation <> 'D';

GO


