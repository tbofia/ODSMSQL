IF OBJECT_ID('dbo.if_PractitionerChild', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_PractitionerChild;
GO

CREATE FUNCTION dbo.if_PractitionerChild(
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
	t.SiteCode,
	t.NPI,
	t.Qualifier,
	t.IssuingState,
	t.SubSeq,
	t.SecondaryID,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID
FROM src.PractitionerChild t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SiteCode,
		NPI,
		Qualifier,
		IssuingState,
		SubSeq,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PractitionerChild
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SiteCode,
		NPI,
		Qualifier,
		IssuingState,
		SubSeq) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SiteCode = s.SiteCode
	AND t.NPI = s.NPI
	AND t.Qualifier = s.Qualifier
	AND t.IssuingState = s.IssuingState
	AND t.SubSeq = s.SubSeq
WHERE t.DmlOperation <> 'D';

GO


