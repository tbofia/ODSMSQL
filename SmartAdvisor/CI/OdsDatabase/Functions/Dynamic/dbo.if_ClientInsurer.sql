IF OBJECT_ID('dbo.if_ClientInsurer', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_ClientInsurer;
GO

CREATE FUNCTION dbo.if_ClientInsurer(
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
	t.ClientCode,
	t.InsurerType,
	t.EffectiveDate,
	t.InsurerSeq,
	t.TerminationDate
FROM src.ClientInsurer t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClientCode,
		InsurerType,
		EffectiveDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClientInsurer
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClientCode,
		InsurerType,
		EffectiveDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClientCode = s.ClientCode
	AND t.InsurerType = s.InsurerType
	AND t.EffectiveDate = s.EffectiveDate
WHERE t.DmlOperation <> 'D';

GO


