IF OBJECT_ID('dbo.if_CLAIMS', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CLAIMS;
GO

CREATE FUNCTION dbo.if_CLAIMS(
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
	t.ClaimIDNo,
	t.ClaimNo,
	t.DateLoss,
	t.CV_Code,
	t.DiaryIndex,
	t.LastSaved,
	t.PolicyNumber,
	t.PolicyHoldersName,
	t.PaidDeductible,
	t.Status,
	t.InUse,
	t.CompanyID,
	t.OfficeIndex,
	t.AdjIdNo,
	t.PaidCoPay,
	t.AssignedUser,
	t.Privatized,
	t.PolicyEffDate,
	t.Deductible,
	t.LossState,
	t.AssignedGroup,
	t.CreateDate,
	t.LastChangedOn,
	t.AllowMultiCoverage
FROM src.CLAIMS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CLAIMS
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIDNo = s.ClaimIDNo
WHERE t.DmlOperation <> 'D';

GO


