IF OBJECT_ID('dbo.if_lkp_TS', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_lkp_TS;
GO

CREATE FUNCTION dbo.if_lkp_TS(
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
	t.ShortName,
	t.StartDate,
	t.EndDate,
	t.LongName,
	t.Global,
	t.AnesMedDirect,
	t.AffectsPricing,
	t.IsAssistantSurgery,
	t.IsCoSurgeon
FROM src.lkp_TS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ShortName,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.lkp_TS
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ShortName,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ShortName = s.ShortName
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D';

GO


