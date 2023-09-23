IF OBJECT_ID('dbo.if_RuleType', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RuleType;
GO

CREATE FUNCTION dbo.if_RuleType(
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
	t.RuleTypeID,
	t.Name,
	t.Description
FROM src.RuleType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleTypeID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RuleType
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleTypeID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleTypeID = s.RuleTypeID
WHERE t.DmlOperation <> 'D';

GO


