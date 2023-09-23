IF OBJECT_ID('aw.if_ProvidedLink', 'IF') IS NOT NULL
    DROP FUNCTION aw.if_ProvidedLink;
GO

CREATE FUNCTION aw.if_ProvidedLink(
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
	t.ProvidedLinkId,
	t.Title,
	t.URL,
	t.OrderIndex
FROM src.ProvidedLink t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProvidedLinkId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProvidedLink
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProvidedLinkId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProvidedLinkId = s.ProvidedLinkId
WHERE t.DmlOperation <> 'D';

GO


