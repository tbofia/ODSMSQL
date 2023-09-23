IF OBJECT_ID('dbo.if_Provider_Rendering', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_Provider_Rendering;
GO

CREATE FUNCTION dbo.if_Provider_Rendering(
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
	t.PvdIDNo,
	t.RenderingAddr1,
	t.RenderingAddr2,
	t.RenderingCity,
	t.RenderingState,
	t.RenderingZip
FROM src.Provider_Rendering t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider_Rendering
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIDNo = s.PvdIDNo
WHERE t.DmlOperation <> 'D';

GO


