IF OBJECT_ID('dbo.if_Modifier', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Modifier;
GO

CREATE FUNCTION dbo.if_Modifier(
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
	t.Jurisdiction,
	t.Code,
	t.SiteCode,
	t.Func,
	t.Val,
	t.ModType,
	t.GroupCode,
	t.ModDescription,
	t.ModComment1,
	t.ModComment2,
	t.CreateDate,
	t.CreateUserID,
	t.ModDate,
	t.ModUserID,
	t.Statute,
	t.Remark1,
	t.RemarkQualifier1,
	t.Remark2,
	t.RemarkQualifier2,
	t.Remark3,
	t.RemarkQualifier3,
	t.Remark4,
	t.RemarkQualifier4,
	t.CBREReasonID
FROM src.Modifier t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Jurisdiction,
		Code,
		SiteCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Modifier
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Jurisdiction,
		Code,
		SiteCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Jurisdiction = s.Jurisdiction
	AND t.Code = s.Code
	AND t.SiteCode = s.SiteCode
WHERE t.DmlOperation <> 'D';

GO


