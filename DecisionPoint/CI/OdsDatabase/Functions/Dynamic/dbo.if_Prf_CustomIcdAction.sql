IF OBJECT_ID('dbo.if_Prf_CustomIcdAction', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Prf_CustomIcdAction;
GO

CREATE FUNCTION dbo.if_Prf_CustomIcdAction(
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
	t.CustomIcdActionId,
	t.ProfileId,
	t.IcdVersionId,
	t.Action,
	t.StartDate,
	t.EndDate
FROM src.Prf_CustomIcdAction t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CustomIcdActionId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Prf_CustomIcdAction
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CustomIcdActionId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CustomIcdActionId = s.CustomIcdActionId
WHERE t.DmlOperation <> 'D';

GO


