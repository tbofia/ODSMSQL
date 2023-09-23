IF OBJECT_ID('dbo.if_BillsOverride', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_BillsOverride;
GO

CREATE FUNCTION dbo.if_BillsOverride(
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
	t.BillsOverrideID,
	t.BillIDNo,
	t.LINE_NO,
	t.UserId,
	t.DateSaved,
	t.AmountBefore,
	t.AmountAfter,
	t.CodesOverrode,
	t.SeqNo
FROM src.BillsOverride t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillsOverrideID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillsOverride
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillsOverrideID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillsOverrideID = s.BillsOverrideID
WHERE t.DmlOperation <> 'D';

GO


