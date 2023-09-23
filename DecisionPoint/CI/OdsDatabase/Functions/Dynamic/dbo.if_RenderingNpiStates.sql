IF OBJECT_ID('dbo.if_RenderingNpiStates', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_RenderingNpiStates;
GO

CREATE FUNCTION dbo.if_RenderingNpiStates(
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
	t.ApplicationSettingsId,
	t.State
FROM src.RenderingNpiStates t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ApplicationSettingsId,
		State,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RenderingNpiStates
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ApplicationSettingsId,
		State) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ApplicationSettingsId = s.ApplicationSettingsId
	AND t.State = s.State
WHERE t.DmlOperation <> 'D';

GO


