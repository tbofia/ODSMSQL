IF OBJECT_ID('dbo.if_prf_CTGPenaltyLines', 'IF') IS NOT NULL
    DROP FUNCTION dbo.if_prf_CTGPenaltyLines;
GO

CREATE FUNCTION dbo.if_prf_CTGPenaltyLines(
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
	t.CTGPenLineID,
	t.ProfileId,
	t.PenaltyType,
	t.FeeSchedulePercent,
	t.StartDate,
	t.EndDate,
	t.TurnAroundTime
FROM src.prf_CTGPenaltyLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenLineID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenaltyLines
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenLineID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenLineID = s.CTGPenLineID
WHERE t.DmlOperation <> 'D';

GO


