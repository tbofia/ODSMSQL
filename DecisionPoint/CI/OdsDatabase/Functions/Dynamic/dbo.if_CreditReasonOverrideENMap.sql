IF OBJECT_ID('dbo.if_CreditReasonOverrideENMap', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_CreditReasonOverrideENMap;
GO

CREATE FUNCTION dbo.if_CreditReasonOverrideENMap(
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
	t.CreditReasonOverrideENMapId,
	t.CreditReasonId,
	t.OverrideEndnoteId
FROM src.CreditReasonOverrideENMap t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CreditReasonOverrideENMapId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CreditReasonOverrideENMap
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CreditReasonOverrideENMapId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CreditReasonOverrideENMapId = s.CreditReasonOverrideENMapId
WHERE t.DmlOperation <> 'D';

GO


